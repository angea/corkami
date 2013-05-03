; labyrinth generator - 45 bytes version by Rrrola http://www.pouet.scene.org/prod.php?which=61261#c645429
; sha1 199f362a67f33c618e18ca315a267ddd73e2616d 

bits 16

org 100h

MODE_320_200 equ 13h
INT_VIDEO equ 10h

; cx = ffh, bx = 0, ds:0 = CD 20 FF 9F; si = 100h

    mov al, MODE_320_200
    int INT_VIDEO

    lds dx, [bx]  ; ds = 9FFFh, dx = 20CDh
    inc bx        ; bx = 1
    mov dl, 6     ; dx = 2006h
    mov ax, 0FEC0h

new_point:
    xchg ax, bx
    push si
    imul cx, 233 ; prime, etc...
    js next

    neg ax
    lea di, [bx + si]
    lea si, [bx + di]
    cmp [si], dl
    bt si, dx
    jbe next

    mov [si], dl
    mov [di], dl
    call new_point

next:
    pop si
    dec ch
    loopne new_point
    retn
