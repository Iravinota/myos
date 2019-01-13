;*************************************************
;	Memory.inc
;		-Basic memory routines. Eric - Physical Memory
;
;	OS Development Series
;
;   Ref: Int 15/AX=E801h: http://www.ctyme.com/intr/rb-1739.htm
;        http://www.brokenthorn.com/Resources/OSDev17.html
;*************************************************

%ifndef __MEMORY_INC_67343546FDCC56AAB872_INCLUDED__
%define __MEMORY_INC_67343546FDCC56AAB872_INCLUDED__

bits 16

;---------------------------------------------
;	Get memory size for >64M configuations
;	ret\ ax=KB between 1MB and 16MB
;	ret\ bx=number of 64K blocks above 16MB
;	ret\ bx=0 and ax= -1 on error
;---------------------------------------------

BiosGetMemorySize64MB:
	push	ecx
	push	edx
	xor		ecx, ecx
	xor		edx, edx
	mov		ax, 0xe801
	int		0x15	
	jc		.error
	cmp		ah, 0x86		;unsupported function
	je		.error
	cmp		ah, 0x80		;invalid command
	je		.error
	jcxz	.use_ax			;bios may have stored it in ax,bx or cx,dx. test if cx is 0
	mov		ax, cx			;its not, so it should contain mem size; store it
	mov		bx, dx

.use_ax:
	pop		edx				;mem size is in ax and bx already, return it
	pop		ecx
	ret

.error:
	mov		ax, -1
	mov		bx, 0
	pop		edx
	pop		ecx
	ret

%endif