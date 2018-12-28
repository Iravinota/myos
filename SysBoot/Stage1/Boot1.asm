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
;   Command: nasm -f bin Boot1.asm -o Boot1.bin
;            partcopy Boot1.bin 0 200 -f0
;*******************************************************************************************

bits 16                 ; tell nasm to generate 16bit mode code. Useless
org 0                   ; assume this binary file will be loaded at 0x00 memory

; some boot sector code

times 510-($-$$) db 0   ; $ represents the current line, $$ represents the first line
dw 0xAA55               ; A bootable signature

