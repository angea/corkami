start:
    xor ax, ax
    mov ss, ax
    mov sp,  start
    sti
    push ax
    pop es
    push ax
    pop ds
    cld
    mov si,  next
    mov di, 61Bh
    push ax
    push di
    mov cx, 1E5h
    rep movsb
    retf


next:
    mov si, 7BEh
    mov cl, 4

loc_7C20:
    cmp [si], ch
    jl short loc_7C2D
    jnz short loc_7C3B
    add si, 10h
    loop loc_7C20
    int 18h

loc_7C2D:
    mov dx, [si]
    mov bp, si

loc_7C31:
    add si, 10h
    dec cx
    jz short loc_7C4D
    cmp [si], ch
    jz short loc_7C31

loc_7C3B:
    mov si, 710h

loc_7C3E:
    dec si

loc_7C3F:
         ; seg000:7CBAj
    lodsb
    cmp al, 0
    jz short loc_7C3E
    mov bx, 7
    mov ah, 0Eh
    int 10h    ; - VIDEO - WRITE CHARACTER AND ADVANCE CURSOR (TTY WRITE)
         ; AL = character, BH = display page (alpha modes)
         ; BL = foreground color (graphics modes)

loc_7C4B:
    jmp short loc_7C3F


loc_7C4D:
    mov [bp+25h], ax
    xchg ax, si
    mov al, [bp+4]
    mov ah, 6
    cmp al, 0Eh
    jz short loc_7C6B
    mov ah, 0Bh
    cmp al, 0Ch
    jz short loc_7C65
    cmp al, ah
    jnz short loc_7C8F
    inc ax

loc_7C65:
    mov byte [bp+25h], 6
    jnz short loc_7C8F

loc_7C6B:
    mov bx, 55AAh
    push ax
    mov ah, 41h ; 'A'
    int 13h    ; DISK -
    pop ax
    jb short loc_7C8C
    cmp bx, 0AA55h
    jnz short loc_7C8C
    test cl, 1
    jz short loc_7C8C
    mov ah, al
    mov [bp+24h], dl
    mov word ds:6A1h, 1EEBh

loc_7C8C:
    mov [bp+4], ah

loc_7C8F:
    mov di, 0Ah

loc_7C92:
    mov ax, 201h
    mov bx, sp
    xor cx, cx
    cmp di, 5
    jg short loc_7CA1
    mov cx, [bp+25h]

loc_7CA1:
    add cx, [bp+2]
    int 13h    ; read sectores

loc_7CA6:
    jb short loc_7CD1
    mov si, 746h
    cmp ds:word_7DFE, 0AA55h
    jz short loc_7D0D
    sub di, 5
    jg short loc_7C92

loc_7CB8:
    test si, si
    jnz short loc_7C3F
    mov si, 727h
    jmp short loc_7C4B

    cbw
    xchg ax, cx
    push dx
    cwd
    add ax, [bp+8]
    adc dx, [bp+0Ah]
    call sub_7CE0
    pop dx
    jmp short loc_7CA6


loc_7CD1:
    dec di
    jz short loc_7CB8
    xor ax, ax
    int 13h    ; reset disk system
    jmp short loc_7C92

    db 6 dup(0)



sub_7CE0 proc near
    push si
    xor si, si
    push si
    push si
    push dx
    push ax
    push es
    push bx
    push cx
    mov si, 10h
    push si
    mov si, sp
    push ax
    push dx
    mov ax, 4200h
    mov dl, [bp+24h]
    int 13h    ; DISK -
    pop dx
    pop ax
    lea sp, [si+10h]
    jb short loc_7D0B

loc_7D01:
    inc ax
    jnz short loc_7D05
    inc dx

loc_7D05:
    add bh, 2
    loop loc_7D01
    clc

loc_7D0B:
    pop si
    retn
sub_7CE0 endp ; sp = -10h



loc_7D0D:
    jmp short loc_7D83

aInvalidPartiti db 'Invalid partition table',0
aErrorLoadingOp db 'Error loading operating system',0
aMissingOperati db 'Missing operating system',0
    db 24h dup(0)


loc_7D83:
    mov di, sp
    push ds
    push di
    mov si, bp
    retf

    db 34h dup(0), 80h, 2 dup(1), 0, 0Bh, 7Fh, 0BFh, 0FDh
    db 3Fh, 3 dup(0), 0C1h, 40h, 5Eh, 31h dup(0)
word_7DFE dw 0AA55h
