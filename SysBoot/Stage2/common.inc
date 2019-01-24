%ifndef _COMMON_INC_INCLUDED
%define _COMMON_INC_INCLUDED

; where the kernel is to be loaded to in protected mode
%define IMAGE_PMODE_BASE 0xC0000000		; vitural address 0xC000-0000(3G) mapped to real address 0x10-0000(1M)

; where the kernel is to be loaded to in real mode
%define IMAGE_RMODE_BASE 0x3000

; kernel name
ImageName     db "KRNL32  EXE"      ; KRNL32.EXE

ImageSize     db 0                  ; file size in sectors

%endif
