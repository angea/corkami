; TinyEXE HelloWorld
; simple EXE (non PE) helloworld, with a minimal amount of information

%include '..\consts.asm'
bits 16

istruc IMAGE_DOS_HEADER
    at IMAGE_DOS_HEADER.e_magic, db 'MZ'
;    at IMAGE_DOS_HEADER.e_cblp, db LAST_BYTE   ; not strictly needed
    at IMAGE_DOS_HEADER.e_cp, dw PAGES
    at IMAGE_DOS_HEADER.e_cparhdr, dw dos_stub >> 4

; code start must be paragraph-aligned
align 10h, db 0
dos_stub:
    push    cs
    pop     ds
    jmp next
; those 2 need to be zero
    at IMAGE_DOS_HEADER.e_ip, dw 0
    at IMAGE_DOS_HEADER.e_cs, dw 0
next:
    mov     dx, dos_msg - dos_stub
    mov     ah, 9
    int     21h
    mov     ax, 4c01h
    int     21h
dos_msg:
    db 'Hello World!$'
iend

PAGES equ $ >> 6
LAST_BYTE equ $

; Ange Albertini 2010