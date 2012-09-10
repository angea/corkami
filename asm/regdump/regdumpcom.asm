; broken .COM register dumper

; Ange Albertini, BSD Licence, 2012

IMAGE_SCN_CNT_CODE               equ 000000020h
IMAGE_SCN_CNT_INITIALIZED_DATA   equ 000000040h

%include 'consts.inc'
%define iround(n, r) (((n + (r - 1)) / r) * r)

IMAGEBASE equ 4000000h
org IMAGEBASE

SECTIONALIGN EQU 1000h
FILEALIGN EQU 200h

DOS_HEADER:
    .e_magic       dw 'MZ'
    .e_cblp        dw 090h
    .e_cp          dw 1
    .e_crlc        dw 0
    .e_cparhdr     dw (dos_stub - DOS_HEADER) >> 4 ; defines MZ stub entry point
    .e_minalloc    dw 0
    .e_maxalloc    dw 0
    .e_ss          dw 0
    .e_sp          dw 0
    .e_csum        dw 0
    .e_ip          dw 0
    .e_cs          dw 0
    .e_lfarlc      dw 040h
    .e_ovno        dw 0
    .e_res         dw 0,0,0,0
    .e_oemid       dw 0
    .e_oeminfo     dw 0
    .e_res2        times 10 dw 0
        align 03ch, db 0    ; in case we change things in DOS_HEADER
    .e_lfanew      dd 0

align 010h, db 0
dos_stub:
bits 16
    mov word [old_sp - dos_stub], sp
    mov sp, stub_end - dos_stub
    pusha
    pushf
    push    cs
    pop     ds
;    mov     dx, dos_msg - dos_stub
;    mov     ah, 9 ; print
;    int     21h
;Flags || || EDI || ESI || EBP || ESP || EBX || EDX || ECX || EAX ||", 0ah, "||||||||||||||||||||||||||", 0ah, 0

next_reg:
    pusha
    mov dx, ' '
    mov ah, 2
    int 21h
    popa

    pop bx
    mov cx, 4
nextnibble:
    rol bx, 4
    mov dx, bx
    and dx, 7
    cmp dx, 9
    jg hex_char

    add dx, '0'
    jmp printchar

hex_char:
    add dx, 'A'
printchar

    mov ah, 2
    int 21h


    dec cx
    jnz nextnibble

    dec word [counter - dos_stub]
    jnz next_reg

    mov     ax, 4c01h
    int     21h
counter dw 9
old_sp dw 0

dos_msg db ' # patching PE (16b dos stub)', 0dh, 0dh, 0ah, '$'
align 16, db 0
stub_end:
