;*******************************************************************************************
;	Boot1.asm
;		- A Simple Bootloader
;
;	Eric - at 2018.12.28
;   
;   Reference: https://www.nasm.us/doc/
;              http://www.brokenthorn.com/Resources/OSDevIndex.html
;              https://thestarman.pcministry.com/asm/bochs/bochsdbg.html
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




;*********************************************
;	Bootloader Entry Point
;*********************************************

main: 
            mov ax, 0x07c0
			mov ds, ax			; set ds to 0x07c0, then the DS:SI==>0x07c0:0x0000-msg

			mov si, msg			; msg has the offset of 0x0000
			call Print
			
			cli
            hlt

msg	db	"Welcome to My Operating System!", 0

; Padding to 512 bytes
times 510-($-$$) db 0   ; $ represents the current line, $$ represents the first line
dw 0xAA55               ; A bootable signature

