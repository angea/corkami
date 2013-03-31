; a one-solution maze generator
; 16b .COM in x86 assembler

; thanks to herm1t, Solar Designer, qkumba, Rrrola

%define RANDOM
%define CLEANUP

; Ange Albertini BSD licence 2013

bits 16

org 100h

SET_VIDEO_MODE equ 0
MODE_T_640_400 equ 2
MODE_320_200 equ 13h
INT_VIDEO equ 10h

READ_INPUT equ 0
INT_KEYBOARD equ 16h

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
    ; by default: horizontal scan
    test al, 2h
    jnz V

    ; horizontal
    cwd ; risky?
    inc dx

V:
    ; positive or negative progression ?
    ; by default: negative
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

%ifdef RANDOM
    ; seed re-initialization (4 bytes)
    in ax, 40h
    xor bp, ax
%endif

    loop pick_a_point


%ifdef CLEANUP
    ; wait for keypress (4 bytes)
    xor ax, ax ; mov ah, READ_INPUT
    int INT_KEYBOARD

    ; graphical clean-up (5 bytes)
    mov ax,  (SET_VIDEO_MODE << 8) + MODE_T_640_400
    int INT_VIDEO
%endif

; end - using the random return to end the program
    ; ret

random:
    imul bp, 07bfbh
    inc bp

    mov ax, W - 1  ; 0..FFFF -> 0..W-2
    mul bp
    xchg dx, ax

    inc ax
    add ax, ax
    mov dx, SCREENWIDTH
    retn
