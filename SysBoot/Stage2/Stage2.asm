;*******************************************************
;    Stage2.asm
;        Stage2 Bootloader
;
;    OS Development Series
;
;   Eric at 2019-01-11
;   
;   Command: 
;       nasm Stage2.asm -o KRNLDR.SYS [or] nasm -f bin Stage2.asm -o KRNLDR.SYS
;       copy /Y KRNLDR.SYS  A:\
;*******************************************************

bits    16
org     0x0500

start:
    jmp main

;*******************************************************
;    Pre-include files
;*******************************************************

%include "stdio.inc"            ; basic i/o routines
%include "bootinfo.inc"         ; multiboot_info struct
%include "A20.inc"              ; call _EnableA20
%include "Gdt.inc"              ; call InstallGDT
%include "Memory.inc"           ; Physical Memory information
%include "Fat12.inc"            ; Fat12 formatted floppy disk
%include "common.inc"           ; Define ImageName and Kernal's base address

;*******************************************************
;    Data Section
;*******************************************************

LoadingMsg db 0x0D, 0x0A, "Searching for Operating System...", 0x00
msgFailure db 0x0D, 0x0A, "*** FATAL: Missing or corrupt KRNL32.EXE. Press Any Key to Reboot.", 0x0D, 0x0A, 0x0A, 0x00

; Eric - Initialize an instance of 'multiboot_info' struct, which has been defined in bootinfo.inc
boot_info:
    istruc multiboot_info
        at multiboot_info.flags,                dd 0
        at multiboot_info.memoryLo,             dd 0
        at multiboot_info.memoryHi,             dd 0
        at multiboot_info.bootDevice,           dd 0
        at multiboot_info.cmdLine,              dd 0
        at multiboot_info.mods_count,           dd 0
        at multiboot_info.mods_addr,            dd 0
        at multiboot_info.syms0,                dd 0
        at multiboot_info.syms1,                dd 0
        at multiboot_info.syms2,                dd 0
        at multiboot_info.mmap_length,          dd 0
        at multiboot_info.mmap_addr,            dd 0
        at multiboot_info.drives_length,        dd 0
        at multiboot_info.drives_addr,          dd 0
        at multiboot_info.config_table,         dd 0
        at multiboot_info.bootloader_name,      dd 0
        at multiboot_info.apm_table,            dd 0
        at multiboot_info.vbe_control_info,     dd 0
        at multiboot_info.vbe_mode_info,        dw 0
        at multiboot_info.vbe_interface_seg,    dw 0
        at multiboot_info.vbe_interface_off,    dw 0
        at multiboot_info.vbe_interface_len,    dw 0
    iend

;*******************************************************
;    Entry Point
;*******************************************************

main:
    cli                         ; If there is no cli, will print LoadingMsg all the time

    ; Eric - print some information to indicate this code is running
    xor     ax, ax
    mov     ds, ax
    mov     si, LoadingMsg
    call    Puts16

    ;-------------------------------;
    ;   Setup segments and stack    ;
    ;-------------------------------;

    xor     ax, ax
    mov     ds, ax
    mov     es, ax
    mov     ss, ax
    mov     sp, 0xFFFF              ; stack begins at 0x9000-0xFFFF

    sti

    mov     [boot_info+multiboot_info.bootDevice], dl
    
    call    _EnableA20              ; A20.inc, we can access more than 20 address lines
    call    InstallGDT              ; Gdt.inc. GDT is in some place above 0x0500 (gdtr stores its address)
    sti

    ; Eric - Get the physical memory size (KB) and set it to 'multiboot_info' struct
    xor     eax, eax
    xor     ebx, ebx
    call    BiosGetMemorySize64MB   ; Memory.inc, Physical memory
    push	eax
	mov		eax, 64
	mul		ebx
	mov		ecx, eax
	pop		eax
	add		eax, ecx
	add		eax, 1024		        ; the routine doesnt add the KB between 0-1MB; add it
	mov		dword [boot_info+multiboot_info.memoryHi], 0
	mov		dword [boot_info+multiboot_info.memoryLo], eax

    ; Eric - Now we get the physical memory size from BIOS. But not all of this memory is available to us.
    ; Get memory map to 0000:1000. What's the use?
    mov		eax, 0x0
	mov		es, ax                  ; Eric - NOT: mov ds, ax
	mov		di, 0x1000
	call	BiosGetMemoryMap        ; Memory.inc, memory map

    ; Load file 'ImageName' into memory EBX:EBP(0000:3000)
    call    LoadRoot                ; Fat12.inc. Load RootDirecoryTable into 0x2E00 - tmp use
    mov     ebx, 0
    mov     ebp, IMAGE_RMODE_BASE   ; common.inc. 0x3000
    mov 	esi, ImageName          ; common.inc, KRNL32.EXE
	call    LoadFile		        ; load another file who's name is 'ImageName' into 0x3000
    mov   	dword [ImageSize], ecx  ; ECX is files size in sectors
    cmp		ax, 0                   ; LoadFile is sucess if ax is 0
    je		EnterStage3
    mov		si, msgFailure
	call   	Puts16
	mov		ah, 0

    ;-------------------------------;
	;   Go into pmode               ;
	;-------------------------------;

EnterStage3:

    cli                             ; clear interrupts
    mov eax, cr0                    ; set bit 0 in cr0 -- **enter pmode**
    or  eax, 1
    mov cr0, eax

    jmp CODE_DESC:Stage3            ; Gdt.inc, CODE_DESC is 0x8, code descriptor
                                    ; After this far jump, CS is set to 0x0008, which is the CODE descriptor in GDT.
                                    ; And EIP is set to Stage3 

    ; Note: Do NOT re-enable interrupts! Doing so will triple fault!
	; We will fix this in Stage 3.

    ; Eric - After enter Protected Mode, we use Descriptor:Address instead of segment:offset for addressing

;******************************************************
;	ENTRY POINT FOR STAGE 3
;******************************************************

bits 32

BadImage db "*** FATAL: Invalid or corrupt kernel image. Halting system.", 0

Stage3:

    ;-------------------------------;
	;   Set registers. We will use Descriptor:Address for addressing
	;-------------------------------;

	mov	ax, DATA_DESC		; set data segments to data selector (0x10)
	mov	ds, ax
	mov	ss, ax
	mov	es, ax
	mov	esp, 9000h		    ; stack begins from 90000h

    call	ClrScr32        ; stdio.inc, clean the screen, but the cursor is not moved

    hlt

