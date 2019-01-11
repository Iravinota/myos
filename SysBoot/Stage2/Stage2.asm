;*******************************************************
;	Stage2.asm
;		Stage2 Bootloader
;
;	OS Development Series
;
;   Eric at 2019-01-11
;   
;   Command: 
;       nasm Stage2.asm -o KRNLDR.SYS [or] nasm -f bin Stage2.asm -o KRNLDR.SYS
;       copy KRNLDR.SYS  A:\
;*******************************************************

bits    16
org     0x0500

start:
    jmp main

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

LoadingMsg db 0x0D, 0x0A, "Searching for Operating System...", 0x00

main:
    cli                         ; If there is no cli, will print LoadingMsg all the time

    xor ax, ax
    mov ds, ax
    mov si, LoadingMsg
    call Print

    hlt

