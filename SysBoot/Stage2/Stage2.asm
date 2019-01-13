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
    call    InstallGDT
    sti

    ; get the physical memory size (KB) and set it to 'multiboot_info' struct
    xor     eax, eax
    xor     ebx, ebx
    call    BiosGetMemorySize64MB   ; Memory.inc, Physical memory
    push	eax
	mov		eax, 64
	mul		ebx
	mov		ecx, eax
	pop		eax
	add		eax, ecx
	add		eax, 1024		; the routine doesnt add the KB between 0-1MB; add it

	mov		dword [boot_info+multiboot_info.memoryHi], 0
	mov		dword [boot_info+multiboot_info.memoryLo], eax



    hlt

