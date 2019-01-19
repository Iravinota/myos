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

%include "Paging.inc"           ; Enable Paging. Must below btis 32 function

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
    call    UpdateCur       ; Eric - Update cursor to some position

    call    EnablePaging    ; Paging.inc. cr3 stores the PageTable's base address. cr0's 31 bit set to 1 means using paging.

CopyImage:
    mov	eax, dword [ImageSize]  ; common.inc
    movzx	ebx, word [bpbBytesPerSector]   ; Floppy16.inc included by Fat12.inc
    mul	ebx
    mov	ebx, 4
    div	ebx
    ; move from DS:SI(DATA_DESC(0):0x3000) to ES:DI(DATA_DESC(0):0xC000-0000). 
    ; This is Descriptor:Address addressing, DATA_DESC is data selector, which denotes 0
    ; When addressing, it will use Paging. Virtual address 0x3000 is mapped to physicall address 0x3000, and virtual address 0xC000-0000 is mapped to physicall address 0x10-0000
    ; So, the value in physical address 0x3000 is copied to 0x10-0000
    cld
    mov esi, IMAGE_RMODE_BASE   ; common.inc. Move from
    mov	edi, IMAGE_PMODE_BASE
    mov	ecx, eax
    rep	movsd                   ; copy image to its protected mode address. Eric - move from DS:SI -> ES:DI

TestImage:
    mov    ebx, [IMAGE_PMODE_BASE+60]   ; Eric - IMAGE_DOS_HEADER.e_lfanew, pointer to _IMAGE_NT_HEADERS
    add    ebx, IMAGE_PMODE_BASE    ; ebx now points to file sig (PE00)
    mov    esi, ebx
    mov    edi, ImageSig
    cmpsw                           ; compare word at DS:SI with ES:DI
    je     EXECUTE
    mov	   ebx, BadImage
    call   Puts32
    cli
    hlt

ImageSig db 'PE'

EXECUTE:

    ;---------------------------------------;
	;   Execute Kernel
	;---------------------------------------;

    ; parse the programs header info structures to get its entry point
    
    ; In TestImage, ebx now is pointed to _IMAGE_IN_HEADERS
    add     ebx, 4              ; skip _IMAGE_IN_HEADERS.Signature
    add     ebx, 20             ; skip _IMAGE_IN_HEADERS.FileHeader (IMAGE_FILE_HEADER)
;    mov     eax, [ebx]          ; the ebx points to _IMAGE_IN_HEADERS.OptionalHeader (_IMAGE_OPTIONAL_HEADER)
    add     ebx, 16             ; _IMAGE_OPTIONAL_HEADER.AddressOfEntryPoint
    mov		ebp, dword [ebx]	; get entry point offset in code section
    add		ebx, 12             ; _IMAGE_OPTIONAL_HEADER.ImageBase. image base is offset 8 bytes from entry point
    mov		eax, dword [ebx]	; add image base
	add		ebp, eax            ; Eric - ebp is now ImageBase+AddressOfEntryPoint
    cli

    ; http://www.brokenthorn.com/Resources/OSDevMulti.html -- Machine State
    mov		eax, 0x2badb002		; multiboot specs say eax should be this
	mov		ebx, 0
	mov		edx, [ImageSize]

    push	dword boot_info
	call	ebp               	; Execute Kernel. PE file's Entry point is stored in ebp
	add		esp, 4

    cli
    hlt

;-- header information format for PE files -------------------

;typedef struct _IMAGE_DOS_HEADER {  // DOS .EXE header
;    USHORT e_magic;         // Magic number (Should be MZ
;    USHORT e_cblp;          // Bytes on last page of file
;    USHORT e_cp;            // Pages in file
;    USHORT e_crlc;          // Relocations
;    USHORT e_cparhdr;       // Size of header in paragraphs
;    USHORT e_minalloc;      // Minimum extra paragraphs needed
;    USHORT e_maxalloc;      // Maximum extra paragraphs needed
;    USHORT e_ss;            // Initial (relative) SS value
;    USHORT e_sp;            // Initial SP value
;    USHORT e_csum;          // Checksum
;    USHORT e_ip;            // Initial IP value
;    USHORT e_cs;            // Initial (relative) CS value
;    USHORT e_lfarlc;        // File address of relocation table
;    USHORT e_ovno;          // Overlay number
;    USHORT e_res[4];        // Reserved words
;    USHORT e_oemid;         // OEM identifier (for e_oeminfo)
;    USHORT e_oeminfo;       // OEM information; e_oemid specific
;    USHORT e_res2[10];      // Reserved words
;    LONG   e_lfanew;        // File address of new exe header
;  } IMAGE_DOS_HEADER, *PIMAGE_DOS_HEADER;

;typedef struct _IMAGE_NT_HEADERS {
;    DWORD Signature;
;    IMAGE_FILE_HEADER FileHeader;
;    IMAGE_OPTIONAL_HEADER OptionalHeader;
;} IMAGE_NT_HEADERS, *PIMAGE_NT_HEADERS;

;typedef struct _IMAGE_FILE_HEADER {
;    USHORT  Machine;
;    USHORT  NumberOfSections;
;    ULONG   TimeDateStamp;
;    ULONG   PointerToSymbolTable;
;    ULONG   NumberOfSymbols;
;    USHORT  SizeOfOptionalHeader;
;    USHORT  Characteristics;
;} IMAGE_FILE_HEADER, *PIMAGE_FILE_HEADER;

;struct _IMAGE_OPTIONAL_HEADER {
;    //
;    // Standard fields.
;    //
;    USHORT  Magic;
;    UCHAR   MajorLinkerVersion;
;    UCHAR   MinorLinkerVersion;
;    ULONG   SizeOfCode;
;    ULONG   SizeOfInitializedData;
;    ULONG   SizeOfUninitializedData;
;    ULONG   AddressOfEntryPoint;			<< IMPORTANT!
;    ULONG   BaseOfCode;
;    ULONG   BaseOfData;
;    //
;    // NT additional fields.
;    //
;    ULONG   ImageBase;
;    ULONG   SectionAlignment;
;    ULONG   FileAlignment;
;    USHORT  MajorOperatingSystemVersion;
;    USHORT  MinorOperatingSystemVersion;
;    USHORT  MajorImageVersion;
;    USHORT  MinorImageVersion;
;    USHORT  MajorSubsystemVersion;
;    USHORT  MinorSubsystemVersion;
;    ULONG   Reserved1;
;    ULONG   SizeOfImage;
;    ULONG   SizeOfHeaders;
;    ULONG   CheckSum;
;    USHORT  Subsystem;
;    USHORT  DllCharacteristics;
;    ULONG   SizeOfStackReserve;
;    ULONG   SizeOfStackCommit;
;    ULONG   SizeOfHeapReserve;
;    ULONG   SizeOfHeapCommit;
;    ULONG   LoaderFlags;
;    ULONG   NumberOfRvaAndSizes;
;    IMAGE_DATA_DIRECTORY DataDirectory[IMAGE_NUMBEROF_DIRECTORY_ENTRIES];
;} IMAGE_OPTIONAL_HEADER, *PIMAGE_OPTIONAL_HEADER;