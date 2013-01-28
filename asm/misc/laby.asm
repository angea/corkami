; a one-solution maze generator
; 16b .COM in x86 assembler

; Ange Albertini BSD licence 2013

; TODO: FIXME!

bits 16

SCREENWIDTH equ 320

VIDEOBUFFER equ 0A000h

MODE_320_200 equ 13h

PORT_TIMER equ 40h

INT_VIDEO equ 10h
INT_KEYPRESS equ 16h
INT_EXIT equ 20h

W equ 64

WHITE equ 15
    ;mov ah, 0
    mov al, MODE_320_200
    int INT_VIDEO

    push VIDEOBUFFER
    pop es

    xor di, di
    mov al, WHITE
    mov cx, 2 * W + 1
    rep stosb

    mov di, SCREENWIDTH * (2 * W)
    mov cx, 2 * W + 1
    rep stosb

    xor di, di
    mov cx, 2 * W + 1
wall_loop:
    stosb
    add di, 2 * W ; +1 already done via stosb
    stosb
    add di, SCREENWIDTH - (2 * W + 2)
    dec cx
    jnz wall_loop

    mov di, 1 + 2 * SCREENWIDTH
    stosb

    mov di, 2 * W + (2 * W - 2) * SCREENWIDTH
    stosb

labyloop:
    call bruterand
    mov cx, ax
    shl cx, 1
    add cx, 2

    call bruterand
    shl ax, 2
    add ax, 2
    mov bx, SCREENWIDTH
    mul bx
    mul cx

    mov di, cx
    lodsb
    cmp al, WHITE
    jnz labyloop

    dec di

    mov cx, SCREENWIDTH ; default, vertical scan
    in ax, PORT_TIMER
    test al, 1
    jnz V
    mov cx, 1 ; horizontal
V:

    test al, 2
    jnz P
    neg cx ; negative
P:

    mov bx, di
    mov dx, cx
    shl cx, 2
    add di, cx
    lodsb
    cmp ax, WHITE
    jnz labyloop
    
    mov di, bx
    
    add di, dx
    mov al, WHITE
    stosb
    dec di
    add di, dx
    stosb
    
    dec word [counter]
    jnz labyloop

end_:
    int INT_KEYPRESS

    int INT_EXIT

bruterand:
    in ax, PORT_TIMER ; randomizer
    cmp ax, W - 1
    jg bruterand
    retn

counter:
    dw (W - 1) * (W - 1) - 1
