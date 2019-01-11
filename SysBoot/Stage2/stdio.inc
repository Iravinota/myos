;*************************************************
;	stdio.inc
;		-Input/Output routines
;
;	OS Development Series
;*************************************************

%ifndef __STDIO_INC_67343546FDCC56AAB872_INCLUDED__
%define __STDIO_INC_67343546FDCC56AAB872_INCLUDED__

;************************************************;
;	Puts16 ()
;		-Prints a null terminated string
;	DS:SI => 0 terminated string
;************************************************;

bits	16

Puts16:
		pusha				; save registers
.Loop1:
		lodsb				; load next byte from string from SI to AL
		or	al, al			; Does AL=0?
		jz	Puts16Done		; Yep, null terminator found-bail out
		mov	ah, 0eh			; Nope-Print the character
		int	10h			    ; invoke BIOS
		jmp	.Loop1			; Repeat until null terminator found
Puts16Done:
		popa				; restore registers
		ret				    ; we are done, so return

;==========================================================
;	 video macros - 32 bits
;==========================================================

bits 32

%define		VIDMEM	0xB8000			; video memory
%define		COLS	80			    ; width and height of screen
%define		LINES	25
%define		CHAR_ATTRIB 14			; character attribute (White text on black background)

_CurX db 0					        ; current x/y location
_CurY db 0

;**************************************************;
;	Putch32 ()
;		- Prints a character to screen
;	BL => Character to print
;**************************************************;

bits 32

Putch32:

	pusha
	mov	edi, VIDMEM

	xor	eax, eax		; clear eax

	; y * screen width

	mov	ecx, COLS*2		; Mode 7 has 2 bytes per char, so its COLS*2 bytes per line
	mov	al, byte [_CurY]	; get y pos
	mul	ecx			; multiply y*COLS
	push	eax			; save eax--the multiplication

	; now add _CurX * 2

	mov	al, byte [_CurX]	; multiply _CurX by 2 because it is 2 bytes per char
	mov	cl, 2
	mul	cl
	pop	ecx			; pop y*COLS result
	add	eax, ecx

	; add the position to draw to the base of vid memory

	xor	ecx, ecx
	add	edi, eax		; add it to the base address

	; watch for new line

	cmp	bl, 0x0A		; is it a newline character?
	je	.Row			; yep--go to next row

	; print the character

	mov	dl, bl			; Get character
	mov	dh, CHAR_ATTRIB		; the character attribute
	mov	word [edi], dx		; write to video display

	; go to next location

	inc	byte [_CurX]		; go to next character
	jmp	.done			; nope, bail out

.Row:
	mov	byte [_CurX], 0		; go back to col 0
	inc	byte [_CurY]		; go to next row

.done:
	popa
	ret


%endif ;__STDIO_INC_67343546FDCC56AAB872_INCLUDED__