; TinyEXE
; simple EXE (non PE) with a minimal amount of information

%include '..\consts.asm'
bits 16

istruc IMAGE_DOS_HEADER
    at IMAGE_DOS_HEADER.e_magic, db 'MZ'
    at IMAGE_DOS_HEADER.e_cp, dw PAGES
    at IMAGE_DOS_HEADER.e_cparhdr, dw dos_stub >> 4
; those 2 need to be zero
    at IMAGE_DOS_HEADER.e_ip, dw 0
    at IMAGE_DOS_HEADER.e_cs, dw 0
align 10h, db 0
dos_stub:
    mov     ax, 4c01h
    int     21h
iend

PAGES equ $ >> 6

; Ange Albertini 2010