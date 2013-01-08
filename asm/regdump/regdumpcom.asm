; .COM register dumper

; Ange Albertini, BSD Licence, 2012-2013

org 100h

%macro printstr 1
    pusha
    mov dx, %1
    mov ah, 9
    int 21h
    popa
%endmacro

    pusha
    pushf

    printstr header
    printstr general

    mov cx, 9

printregloop:
    printstr pipes
    pop ax
    call print16
    loop printregloop

    printstr pipes
    printstr return
    printstr return

    printstr segments

    printstr pipes
    push cs
    pop ax
    call print16

    printstr pipes
    push ds
    pop ax
    call print16

    printstr pipes
    push es
    pop ax
    call print16

    printstr pipes
    push fs
    pop ax
    call print16

    printstr pipes
    push ss
    pop ax
    call print16

    printstr pipes
    push gs
    pop ax
    call print16

    printstr pipes
    printstr return

    int 20h

align 10h int3

printhexnibble:
    push ax
    and al, 0fh
    cmp al, 9
    jg alpha
digit:
    add al, '0'
    jmp print
alpha:
    add al, 'a' - 10

print:
    ;mov ah, 0eh
    ;int 10h
    int 29h
    pop ax
    retn

print8:
    ror al, 4
    call printhexnibble
    ror al, 4
    call printhexnibble
    retn

print16:
    push ax
    ror ax, 8
    call print8
    ror ax, 8
    call print8
    pop ax
    retn

align 10h db 0

return: db 0ah, "$"

pipes:
    db "|| "
    db "$"

header:
    db "Register dumper DOS 0.1b - Ange Albertini - BSD Licence 2013", 0ah, 0ah, "$"

general:
    db " * general registers", 0ah
    db "|| Flags || || DI || SI || BP || SP || BX || DX || CX || AX ||", 0ah
    db "$"

segments:
    db "* selectors", 0ah
    db "|| CS || DS || ES || FS || SS || GS ||", 0ah
    db "$"
