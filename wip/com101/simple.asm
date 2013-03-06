; a simple hello world .COM

; Ange Albertini, BSD Licence, 2013

org 100h ; standard loaded address
bits 16 ; ouch :p

DISPLAY_STRING equ 9h
TERMINATE_WITH_RETURN_CODE equ 4ch

MAIN_DOS_API equ 21h

    ; DATA is with mixed with CODE
    push cs  ; = mov ds, cs
    pop  ds

    ; printf("Hello World!\r\n\r")
    mov  dx, msg
    mov  ah, DISPLAY_STRING
    int  MAIN_DOS_API

    ; return 1;
    mov  ax, TERMINATE_WITH_RETURN_CODE << 8 | 1
    int  MAIN_DOS_API

msg db 'Hello World!', 0dh, 0dh, 0ah, '$' ; DOS string are $-terminated
