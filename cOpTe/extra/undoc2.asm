%include '../header.inc'

%macro __ 0
;	align 16, db 90h
%endmacro
;%IMPORTS

EntryPoint:
	db 0f1h			; icebp
__

	db 0d6h			; setalc
__

	db 0c0h, 0f0h		; sal
		db 90h
__

	db 0f7h, 0c8h		; test
		dd 90909090h

__

	db 0fh, 1eh, 84h, 0c0h	; nop [eax+eax*8], eax
		dd 90909090h
__
	db 0fh, 20h
		db 90h
__
	smsw eax
__
	db 66h
	bswap eax


SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE
SUBSYSTEM equ 2
