; a one-solution maze generator
; 16b .COM in x86 assembler

; TODO: the RNG is quite bloated, yet seems not very random.

; Ange Albertini BSD licence 2013

bits 16

org 100h
SCREENWIDTH equ 320

VIDEOBUFFER equ 0A000h

MODE_320_200 equ 13h

PORT_TIMER equ 40h

INT_VIDEO equ 10h
INT_KEYPRESS equ 16h
INT_EXIT equ 20h

W equ 64

COUNTER equ 2 * W + 3
SEED equ COUNTER + 2

COLOR_BLACK equ 0
COLOR_WHITE equ 15

start:
; graphical mode initialization
    ; mov ah, 0 ; unneeded
    mov al, MODE_320_200
    int INT_VIDEO

; seed initialization

    in ax, 40h ; thx herm1t

    ; push 0            ; alternative - thx solar designer
    ; pop ds
    ; mov ax,[46ch]

; point segments to video buffer
    push VIDEOBUFFER
    pop es
    push es
    pop ds

;variable initialization on video buffer to save code
    mov [SEED], ax
    mov word [COUNTER], (W - 1) * (W - 1) - 1

; drawing the 4 external walls

    ; top
    xor di, di
    mov al, COLOR_WHITE
    push 2 * W + 1
    pop dx
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
    dec cx
    jnz wall_loop


; drawing start and end points
    mov di, 1 + 2 * SCREENWIDTH
    stosb

    ; the first 'main' point
    stosb

    ; end point
    mov di, 2 * W - 1 + (2 * W - 2) * SCREENWIDTH
    stosb


; main algo loop
pick_a_point:

    ; we pick a pixel on even coordinates

    call random
    shl ax, 1
    add ax, 2
    mov si, ax      ; X

    call random
    shl ax, 1
    add ax, 2
    mov dx, SCREENWIDTH
    mul dx
    add si, ax      ; Y

    ; si now points to the start pixel in video
    cmp byte [si], COLOR_WHITE
    jnz pick_a_point

    ; now we pick a random direction to scan
    call random
    mov dx, SCREENWIDTH ; default, vertical scan
    test al, 1h
    jnz V
    mov dx, 1 ; horizontal
V:

    ; positive or negative progression ?
    test al, 2h
    jnz P
    neg dx ; negative
P:

    ; dx now contains the increment for the target pixel to check
    add si, dx
    add si, dx

    cmp byte [si], COLOR_BLACK
    jnz pick_a_point

    ; draw the 2 pixels line between both dots
    mov byte [si], COLOR_WHITE
    sub si, dx
    mov byte [si], COLOR_WHITE

    dec word [COUNTER]
    jnz pick_a_point

; end

;    mov dword [SEED], 0 ; graphical clean-up  - not necessary

;    ; pause - not necessary
;    xor ax, ax
;    int INT_KEYPRESS

;    int INT_EXIT ; exit
    retn    ; saving one byte


; worst part of it - getting a correct RNG in 16b...
random:
    mov	ax, [SEED]
    mov	dx, 8405h
    mul	dx
    inc ax

    cmp word [SEED], ax
    jnz keep_seed
    mov ah, dl
;    inc ax

keep_seed:
    mov	word [SEED], ax
    mov ax, dx

    mov dx, 2 * W - 6 ; not sure why - 6 yet  --  entropy-related?
    mul dx
    mov ax, dx
    retn
