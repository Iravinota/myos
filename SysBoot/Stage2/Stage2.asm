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
;       copy /Y KRNLDR.SYS  A:\
;*******************************************************

bits    16
org     0x0500

start:
    jmp main

;*******************************************************
;	Pre-include files
;*******************************************************

%include "stdio.inc"			; basic i/o routines

;*******************************************************
;	Data Section
;*******************************************************

LoadingMsg db 0x0D, 0x0A, "Searching for Operating System...", 0x00

main:
    cli                         ; If there is no cli, will print LoadingMsg all the time

    xor ax, ax
    mov ds, ax
    mov si, LoadingMsg
    call Puts16

    hlt

