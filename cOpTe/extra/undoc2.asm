%include '../header.inc'

%macro __ 0
	align 8, db 90h
%endmacro

EntryPoint:
	db 0f1h			; icebp

	db 0d6h			; setalc

	db 66h
	bswap eax

;	db 0c0h, 0f0h		; sal

;		db 90h

;	smsw eax

	db 0f7h, 0c8h		; test
		dd 90909090h

	db 0fh, 1eh, 84h, 0c0h	; nop [eax+eax*8], eax
		dd 90909090h

	db 0fh, 20h		; mov eax, cr2
		db 90h

;%IMPORTS

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE
SUBSYSTEM equ 2
