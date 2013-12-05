; EXE HelloWorld
; simple EXE (non PE) helloworld, with an independant header

%include '..\..\consts.asm'
bits 16

istruc IMAGE_DOS_HEADER
    at IMAGE_DOS_HEADER.e_magic,   db 'MZ'

    at IMAGE_DOS_HEADER.e_cp,      dw PAGES

    at IMAGE_DOS_HEADER.e_cparhdr, dw dos_stub >> 4

    at IMAGE_DOS_HEADER.e_ip,      dw 0
    at IMAGE_DOS_HEADER.e_cs,      dw 0

    iend

align 10h, db 0
dos_stub:
    push    cs
    pop     ds
    mov     dx, dos_msg - dos_stub
    mov     ah, 9
    int     21h
    mov     ax, 4c01h
    int     21h
dos_msg:
    db 'Hello World!$'

PAGES equ $ >> 6
LAST_BYTE equ $

; Ange Albertini, BSD Licence 2013