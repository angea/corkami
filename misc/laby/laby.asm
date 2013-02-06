; a one-solution maze generator
; 16b .COM in x86 assembler

; thanks to herm1t, Solar Designer, qkumba

; Ange Albertini BSD licence 2013

bits 16

org 100h

MODE_320_200 equ 13h
INT_VIDEO equ 10h

PORT_TIMER equ 40h

VIDEOBUFFER equ 0A000h

SCREENWIDTH equ 320

W equ 64

COLOR_BLACK equ 0
COLOR_WHITE equ 15

start:
; graphical mode initialization
    mov al, MODE_320_200
    int INT_VIDEO

; seed initialization

    in ax, 40h

    ; push 0
    ; pop ds
    ; mov ax,[46ch]

    xchg ax, bp ; bp = seed

; point segments to video buffer
    push VIDEOBUFFER
    pop es
    push es
    pop ds

; drawing the 4 external walls

    ; top
    xor di, di
    mov al, COLOR_WHITE
    mov dx, 2 * W + 1
    mov cx, dx
    rep stosb

    ; bottom
    mov di, SCREENWIDTH * (2 * W)
    mov cx, dx
    rep stosb

    ; left & right
    xor di, di
    mov cx, dx

wall_loop:
    stosb
    add di, 2 * W - 1
    stosb
    add di, SCREENWIDTH - (2 * W + 1)
    loop wall_loop

; drawing start and end points
    mov di, 1 + 2 * SCREENWIDTH
    stosb

    ; the first 'main' point
    stosb

    ; end point
    mov di, 2 * W - 1 + (2 * W - 2) * SCREENWIDTH
    stosb

    ; cx = counter of remaining transitions to draw
    mov cx, (W - 1) * (W - 1) - 1

; main algo loop
pick_a_point:

    ; we pick a pixel on even coordinates

    call random
    xchg ax, si      ; X

    call random
    ;mov dx, SCREENWIDTH
    mul dx
    xchg bx, ax     ; Y

    ; bx+si now points to the start pixel in video
    cmp byte [bx + si], COLOR_WHITE
    jnz pick_a_point

    ; now we pick a random direction to scan
    call random

    ; horizontal or vertical ?
    ; default, vertical scan
    test al, 2h
    jnz V

    ; horizontal
    cwd ; risky?
    inc dx
V:

    ; positive or negative progression ?
    test al, 4h
    jnz P

    neg dx ; negative
P:

    ; dx now contains the increment for the target pixel to check
    add si, dx
    add si, dx

    cmp byte [bx + si], COLOR_BLACK
    jnz pick_a_point

    ; draw the 2 pixels line between both dots
    mov byte [bx + si], COLOR_WHITE
    sub si, dx ; go back half way
    mov byte [bx + si], COLOR_WHITE

    loop pick_a_point

; end - using the random return to end the program

random:
    mov ax, bp
    mov dx, 8405h
    mul dx
    inc ax

    cmp bp, ax
    jnz keep_seed
    mov ah, dl

keep_seed:
    xchg ax, bp
    xchg ax, dx

    mov dx, 2 * W - 6 ; not sure why '- 6' yet  --  entropy-related?
    mul dx
    xchg dx, ax       ; we want the upper part of the mul

    ; common to most/all random calls
    inc ax
    add ax, ax

    mov dx, SCREENWIDTH
    retn
