;*********************************************
;	Boot1.asm
;		- A Simple Bootloader
;
;	Eric
;*********************************************

bits 16     ; we are in bit 16 real mode

times 510-($-$$) db 0
dw 0xAA55

