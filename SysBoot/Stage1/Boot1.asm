;*******************************************************************************************
;	Boot1.asm
;		- A Simple Bootloader
;
;	Eric - at 2018.12.28
;   
;   Reference: https://www.nasm.us/doc/
;              http://www.brokenthorn.com/Resources/OSDevIndex.html
;              https://thestarman.pcministry.com/asm/bochs/bochsdbg.html
;              https://en.wikipedia.org/wiki/BIOS_interrupt_call - BIOS call list
;              http://www.ctyme.com/rbrown.htm - Interrupt Table
;
;   Command: nasm Boot1.asm -o Boot1.bin [OR] nasm -f bin Boot1.asm -o Boot1.bin
;            partcopy Boot1.bin 0 200 -f0
;*******************************************************************************************

bits 16                 ; tell nasm to generate 16bit mode code. Useless
org 0x0000              ; we will set registers later

; boot sector code
start:
    jmp main

;*********************************************
;	BIOS Parameter Block
;*********************************************

; BPB Begins 3 bytes from start. We do a far jump, which is 3 bytes in size.
; If you use a short jump, add a "nop" after it to offset the 3rd byte.
; Eric - The windows MBR and Boot record information

bpbOEM                  DB "My OS   "
bpbBytesPerSector       DW 512
bpbSectorsPerCluster 	DB 1
bpbReservedSectors 	    DW 1
bpbNumberOfFATs 	    DB 2
bpbRootEntries 	        DW 224
bpbTotalSectors 	    DW 2880
bpbMedia 		        DB 0xf0  ;; 0xF1
bpbSectorsPerFAT 	    DW 9
bpbSectorsPerTrack 	    DW 18
bpbHeadsPerCylinder 	DW 2
bpbHiddenSectors 	    DD 0
bpbTotalSectorsBig      DD 0
bsDriveNumber 	        DB 0
bsUnused 		        DB 0
bsExtBootSignature 	    DB 0x29
bsSerialNumber	        DD 0xa0a1a2a3
bsVolumeLabel 	        DB "MOS FLOPPY "
bsFileSystem 	        DB "FAT12   "

;************************************************;
;	Prints a string
;	DS:SI ==> 0 terminated string
;   DS:SI addressing, the same as DS<<4 + SI
;************************************************;
Print:
	lodsb						; load next byte from string from SI to AL
	or	al, al					; Does AL=0?
	jz	PrintDone				; Yep, null terminator found-bail out
	mov	ah, 0eh					; Nope-Print the character
	int	10h                     ; Eric - Interrupt 0x10 - Video teletype output
	jmp	Print					; Repeat until null terminator found
PrintDone:
	ret						    ; we are done, so return

absoluteSector db 0x00
absoluteHead   db 0x00
absoluteTrack  db 0x00

;************************************************;
; Convert CHS to LBA
; LBA = (cluster - 2) * sectors per cluster
;************************************************;

ClusterLBA:
          sub     ax, 0x0002                          ; zero base cluster number
          xor     cx, cx
          mov     cl, BYTE [bpbSectorsPerCluster]     ; convert byte to word
          mul     cx
          add     ax, WORD [datasector]               ; base data sector
          ret

;************************************************;
; Convert LBA to CHS
; AX=>LBA Address to convert
;
; absolute sector = (logical sector / sectors per track) + 1
; absolute head   = (logical sector / sectors per track) MOD number of heads
; absolute track  = logical sector / (sectors per track * number of heads)
;
;************************************************;

LBACHS:
          xor     dx, dx                              ; prepare dx:ax for operation
          div     WORD [bpbSectorsPerTrack]           ; calculate
          inc     dl                                  ; adjust for sector 0
          mov     BYTE [absoluteSector], dl
          xor     dx, dx                              ; prepare dx:ax for operation
          div     WORD [bpbHeadsPerCylinder]          ; calculate
          mov     BYTE [absoluteHead], dl
          mov     BYTE [absoluteTrack], al
          ret

;************************************************;
; Reads a series of sectors
; CX=>Number of sectors to read
; AX=>Starting sector
; ES:BX=>Buffer to read to
;************************************************;

ReadSectors:
     .MAIN:
          mov     di, 0x0005                          ; five retries for error
     .SECTORLOOP:
          push    ax
          push    bx
          push    cx
          call    LBACHS                              ; convert starting sector to CHS
          mov     ah, 0x02                            ; BIOS read sector
          mov     al, 0x01                            ; read one sector
          mov     ch, BYTE [absoluteTrack]            ; track
          mov     cl, BYTE [absoluteSector]           ; sector
          mov     dh, BYTE [absoluteHead]             ; head
          mov     dl, BYTE [bsDriveNumber]            ; drive
          int     0x13                                ; invoke BIOS - read sector
          jnc     .SUCCESS                            ; test for read error
          xor     ax, ax                              ; BIOS reset disk
          int     0x13                                ; invoke BIOS - reset disk
          dec     di                                  ; decrement error counter
          pop     cx
          pop     bx
          pop     ax
          jnz     .SECTORLOOP                         ; attempt to read again
          int     0x18
     .SUCCESS:
          mov     si, msgProgress
          call    Print
          pop     cx
          pop     bx
          pop     ax
          add     bx, WORD [bpbBytesPerSector]        ; queue next buffer
          inc     ax                                  ; queue next sector
          loop    .MAIN                               ; read next sector
          ret


;*********************************************
;	Bootloader Entry Point
;*********************************************

main: 

    ;----------------------------------------------------
    ; code located at 0000:7C00, adjust segment registers to 07C0:0000
    ;----------------------------------------------------

		cli					; Eric - Clear Interrupt Flag(IF) in EFLAGS register; interrupts disabled when interrupt flag cleared
		
		mov ax, 0x07c0
		mov ds, ax			; set ds to 0x07c0, then the DS:SI==>0x07c0:0x0000-msg
		mov es, ax			; Ref: <<64-IA-32 architectures software developer-1-Basic architecture.pdf>> - 3.4.2 Segment Registers
		mov fs, ax
		mov gs, ax

	;----------------------------------------------------
    ; create stack
    ;----------------------------------------------------

		mov ax, 0
		mov ss, ax
		mov sp, 0xFFFF
		sti					; Eric - Set Interrupt Flag(IF) in EFLAGS register; external, maskable interrupts enabled at the end of the next instruction

		mov [bootdevice], dl

    ;----------------------------------------------------
    ; Load root directory table - Eric - 
    ; Eric - FAT12/16 formatted disk sectors:
    ; |Boot Sector|Extra Reserved Sectors|File Allocation Table 1|File Allocation Table 2|*Root Directory*|Data Region contains files and directories|
    ;----------------------------------------------------

    LOAD_ROOT:
    ; compute size of root directory and store in "cx"

        xor     cx, cx
        xor     dx, dx
        mov     ax, 0x0020                           ; 32 byte directory entry
        mul     WORD [bpbRootEntries]                ; total size of directory
        div     WORD [bpbBytesPerSector]             ; sectors used by directory
        xchg    ax, cx
        
    ; compute location of root directory and store in "ax"

        mov     al, BYTE [bpbNumberOfFATs]            ; number of FATs
        mul     WORD [bpbSectorsPerFAT]               ; sectors used by FATs
        add     ax, WORD [bpbReservedSectors]         ; adjust for bootsector
        mov     WORD [datasector], ax                 ; base of root directory
        add     WORD [datasector], cx
        
    ; read root directory into memory (Eric - 07C0:0200)

        mov     bx, 0x0200                            ; copy root dir above bootcode
        call    ReadSectors
		
		
        
        hlt

bootdevice  db 0x00
datasector  dw 0x0000
cluster     dw 0x0000
ImageName   db "KRNLDR  SYS"
msgCRLF     db 0x0D, 0x0A, 0x00
msgProgress db ".", 0x00
msg	db	"Welcome to My Operating System!", 0

; Padding to 512 bytes
times 510-($-$$) db 0   ; $ represents the current line, $$ represents the first line
dw 0xAA55               ; A bootable signature

