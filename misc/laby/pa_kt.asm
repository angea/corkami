; pa_kt's maze implementation, initially submitted @ http://www.pouet.scene.org/prod.php?which=61261
; with more comments and 2 bytes removed
; 0fa1ace602bcf2d7f0b0ea2b516ce4e08a10a03f

; "striped" maze in 63 bytes.
; Remove this part:
;   test cl, 40h
;   jnz next
; to generate full-width maze (with shitty looking artifacts).
;
; Inspired by 'laby' by Ange Albertini: http://pouet.net/prod.php?which=61163
;
; pk
; twitter.com/pa_kt
; gdtr.wordpress.com

bits 16

org 100h

MODE_320_200 equ 13h
INT_VIDEO equ 10h

VIDEOBUFFER equ 0A000h

BLACK equ 0
WHITE equ 15

TAPS  equ 0b400h

start:
; graphical mode initialization
    mov al, MODE_320_200
    int INT_VIDEO

    mov al, 0fh

; point segments to video buffer
    push VIDEOBUFFER
    pop ds

    ;mov dx, SEED
    ;xor di, di
    mov ebp, ((320 << 16) + 1) * 2 ; higher word to move vertically, lower word to move horizontally
    ;call dfs
    ;ret

dfs:
    rol ebp, 16   ; switch vertical/horizontal

    ; Linear feedback shift register, from Wikipedia

rnd:
    shr dx, 1     ; get lsb, ie the output bit
    jnc no_xor    ; only apply toggle mask if output bit is 1
    xor dx, TAPS
    neg bp        ; switch scanning direction
no_xor:
    ; lfsr end

    mov bx, bp
check:
    cmp byte [di + bx], ah
    jnz next
    lea cx, [di + bx]
    test cl, 40h
    jnz next

connect:
    push di
    mov byte [di+bx], al
    sar bx, 1
    mov byte [di+bx], al
    add di, bp
    call dfs
    pop di
next:
    dec dl
    jnz dfs
    ret
