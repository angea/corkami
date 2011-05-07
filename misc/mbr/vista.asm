org 7c00h
NEWBASE equ 600h

start:
    xor ax, ax
    mov ss, ax
    mov sp, start
    mov es, ax
    mov ds, ax
    mov si, start
    mov di, 600h
    mov cx, 200h
    cld
    rep movsb
    push ax
    push 61Ch
    retf

next:
    sti
    mov cx, 4
    mov bp, 7BEh

loc_7C23:
    cmp byte [bp+0], 0
    jl short loc_7C34

    jnz loc_7D3D

    add bp, 10h
    loop loc_7C23

    int 18h

loc_7C34:
    mov [bp+0], dl
    push bp
    mov byte [bp+11h], 5
    mov byte [bp+10h], 0
    mov ah, 41h ; 'A'
    mov bx, 55AAh
    int 13h

    pop bp
    jb short loc_7C59

    cmp bx, 0AA55h
    jnz short loc_7C59

    test cx, 1
    jz short loc_7C59

    inc byte [bp+10h]

loc_7C59:
    pushad
    cmp byte [bp+10h], 0
    jz short loc_7C87

    push 0
    push word [bp+8]
    push 0
    push  start
    push 1
    push 10h
    mov ah, 42h ; 'B'
    mov dl, [bp+0]
    mov si, sp
    int 13h

    lahf
    add sp, 10h
    sahf
    jmp short loc_7C9B


loc_7C87:
    mov ax, 201h
    mov bx, start
    mov dl, [bp+0]
    mov dh, [bp+1]
    mov cl, [bp+2]
    mov ch, [bp+3]
    int 13h    ; read sectors

loc_7C9B:
    popad
    jnb short loc_7CBD
    dec byte [bp+11h]
    jnz loc_7CB2

    cmp byte [bp+0], 80h
    jz loc_7D38

    mov dl, 80h ; '€'
    jmp short loc_7C34


loc_7CB2:
    push bp
    xor ah, ah
    mov dl, [bp+0]
    int 13h    ; reset disk system
    pop bp
    jmp short loc_7C59


loc_7CBD:
    cmp word [ds:marker], 0AA55h
    jnz loc_7D33

    push word [bp+0]
    call sub_7D55

    jnz loc_7CE4
    mov al, 0D1h
    out 64h, al
    call sub_7D55

    mov al, 0DFh
    out 60h, al
    call sub_7D55

    mov al, 0FFh
    out 64h, al
    call sub_7D55

loc_7CE4:
    mov ax, 0BB00h
    int 1Ah
    and eax, eax
    jnz short loc_7D29

    cmp ebx, 41504354h
    jnz short loc_7D29

    cmp cx, 102h
    jb short loc_7D29

    push 0BB07h
    push 200h
    push 8
    push ebx
    push ebx
    push ebp
    push 0
    push start
    popad
    push 0
    pop es
    int 1Ah

loc_7D29:
    pop dx
    xor dh, dh
    jmp far 0:start

    int 18h

loc_7D33:
    mov al, [ds:7db7h-7600h]
    jmp short loc_7D40


loc_7D38:
    mov al, [ds:7B6h]
    jmp short loc_7D40


loc_7D3D:
    mov al, [ds:7B5h]

loc_7D40:
    xor ah, ah
    add ax, 700h
    mov si, ax

loc_7D47:
    lodsb

loc_7D48:
    cmp al, 0
    jz short loc_7D48
    mov bx, 7
    mov ah, 0Eh
    int 10h

    jmp short loc_7D47



sub_7D55:
    sub cx, cx

loc_7D57:
    in al, 64h
    jmp short $+2
    and al, 2
    loopne loc_7D57
    and al, 2
    retn


aInvalidPartiti db 'Invalid partition table',0
aErrorLoadingOp db 'Error loading operating system',0
aMissingOperati db 'Missing operating system',0
    db    0
    db    0
    db    0
    db  62h
    db  7Ah
    db  99h
    db 0D4h
    db  34h
    db 0A0h
    db  2Eh
    db    0
    db    0
    db  80h
    db  20h
    db  21h
    db    0
    db    7
    db 0FEh
    db 0FFh
    db 0FFh
    db    0
    db    8
    db    0
    db    0
    db    0
    db  88h
    db  82h
    db    1

align 1feh, db 0
marker    dw 0AA55h

;CHECKSUM a3a326815750838886b9a53ffa4b4a12
