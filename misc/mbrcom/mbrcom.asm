; a simple hello world .COM/MBR polyglot

; compile with: yasm -o mbr.com mbrcom.asm

; Ange Albertini, BSD Licence, 2014

org 100h ; standard loaded address for COM, MBR are loaded at 7c00h

DELTA equ 7c00h - 100h
bits 16

PRINT_CHAR equ 0eh

DISPLAY_STRING equ 9h
TERMINATE_WITH_RETURN_CODE equ 4ch

BIOS equ 10h
MAIN_DOS_API equ 21h

; lets test if we execute from 100h or 7c00h
    call $+5
target:
    pop ax
    cmp ax, target
    jz  com
    jmp mbr

com:
    ; print("COM!\r\n\r")
    mov dx, commsg
    mov ah, DISPLAY_STRING
    int MAIN_DOS_API

    ; return 1;
ERRORCODE equ 1
    mov ax, (TERMINATE_WITH_RETURN_CODE << 8) | ERRORCODE
    int MAIN_DOS_API

mbr:
    ; print("MBR!\r\n\r")
    mov si, mbrmsg + DELTA

print_char:
    lodsb
    cmp al, 0
    je  return
    mov ah, PRINT_CHAR
    int BIOS
    jmp print_char

return:
    jmp $

commsg db 'COM!', 0dh, 0ah, '$' ; DOS string are $-terminated
mbrmsg db 'MBR!', 0dh, 0ah, 0

times 200h - 2 - ($ - $$) db 0
    db 55h, 0aah
