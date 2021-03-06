;*************************************************
;	Gdt.inc
;		-GDT Routines
;
;	OS Development Series
;*************************************************

%ifndef __GDT_INC_67343546FDCC56AAB872_INCLUDED__
%define __GDT_INC_67343546FDCC56AAB872_INCLUDED__

bits	16

;*******************************************
; InstallGDT()
;	- Install our GDT
;   Eric - load GDT to GDTR register (load GDT address to GDTR register)
;          When use GDT, we use it's offset to GDT:
;               0x00 - null segment (NULL_DESC)
;               0x08 - code segment (CODE_DESC)
;               ox10 - data segment (DATA_DESC)
;*******************************************

InstallGDT:

	cli                  ; clear interrupts
	pusha                ; save registers
	lgdt 	[toc]        ; load GDT into GDTR register.
	sti	                 ; enable interrupts
	popa                 ; restore registers
	ret	                 ; All done!

;*******************************************
; Global Descriptor Table (GDT)
; Eric - each GDT item has 64bites(8 Bytes)
;*******************************************

gdt_data: 
	dd 0                ; null descriptor
	dd 0 

; gdt code:	            ; code descriptor
	dw 0FFFFh           ; limit low
	dw 0                ; base low
	db 0                ; base middle
	db 10011010b        ; access, Eric ----1---b, the 43th bit, set to 1 is code segment
	db 11001111b        ; granularity
	db 0                ; base high

; gdt data:	            ; data descriptor
	dw 0FFFFh           ; limit low (Same as code)10:56 AM 7/8/2007
	dw 0                ; base low
	db 0                ; base middle
	db 10010010b        ; access, Eric ----0---b, the 43th bit, set to 0 is data segment
	db 11001111b        ; granularity
	db 0                ; base high
	
end_of_gdt:
toc: 
	dw end_of_gdt - gdt_data - 1 	; limit (Size of GDT)
	dd gdt_data 			        ; base of GDT


; give the descriptor offsets names
%define NULL_DESC 0                 ; null descriptor
%define CODE_DESC 0x8               ; code descriptor
%define DATA_DESC 0x10              ; data descriptor

%endif ;__GDT_INC_67343546FDCC56AAB872_INCLUDED__
