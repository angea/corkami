org 7c00h
NEWBASE equ 600h

start:
    xor ax, ax
    mov ss, ax
    mov sp,  start
    mov es, ax
    mov ds, ax
    mov si,  start
    mov di, NEWBASE
    mov cx, 200h
    cld
    rep movsb
    push ax
    push next - start + NEWBASE
    retf

next:
    sti
    mov cx, 4
    mov bp, 7BEh

loc_7C23:
    cmp byte [bp+0], 0
    jl short loc_7C34
    jnz loc_7D3B
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
    int 13h    ; DISK -
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
    push large 0
    push large dword ptr [bp+8]
    push 0
    push  start
    push 1
    push 10h
    mov ah, 42h ; 'B'
    mov dl, [bp+0]
    mov si, sp
    int 13h    ; DISK -
    lahf
    add sp, 10h
    sahf
    jmp short loc_7C9B


loc_7C87:
    mov ax, 201h
    mov bx,  start
    mov dl, [bp+0]
    mov dh, [bp+1]
    mov cl, [bp+2]
    mov ch, [bp+3]
    int 13h    ; read sectores

loc_7C9B:
    popad
    jnb short loc_7CBB
    dec byte [bp+11h]
    jnz short loc_7CB0
    cmp byte [bp+0], 80h ; '€'
    jz loc_7D36
    mov dl, 80h ; '€'
    jmp short loc_7C34


loc_7CB0:
    push bp
    xor ah, ah
    mov dl, [bp+0]
    int 13h    ; reset disk system
    pop bp
    jmp short loc_7C59


loc_7CBB:
    cmp ds:word_7DFE, 0AA55h
    jnz short loc_7D31
    push word [bp+0]
    call sub_7D56
    jnz short loc_7CE2
    cli
    mov al, 0D1h ; 'Ñ'
    out 64h, al    ; AT Keyboard controller 8042.
    call sub_7D56
    mov al, 0DFh ; 'ß'
    out 60h, al    ; AT Keyboard controller 8042.
    call sub_7D56
    mov al, 0FFh
    out 64h, al    ; AT Keyboard controller 8042.
         ; Reset the keyboard and start internal diagnostics
    call sub_7D56
    sti

loc_7CE2:
    mov ax, 0BB00h
    int 1Ah
    and eax, eax
    jnz short loc_7D27
    cmp ebx, 'APCT'
    jnz short loc_7D27
    cmp cx, 102h
    jb short loc_7D27
    push large 0BB07h
    push large 200h
    push large 8
    push ebx
    push ebx
    push ebp
    push large 0
    push large  start
    popad
    push 0
    pop es
    int 1Ah

loc_7D27:
    pop dx
    xor dh, dh
    jmp far ptr start

    db 0CDh ; Í
    db  18h


loc_7D31:
    mov al, [ds:7B7h]
    jmp errorprint

loc_7D36:
    mov al, [ds:7B6h]
    jmp errorprint


loc_7D3B:
    mov al, [ds:7B5h]

errorprint:
    xor ah, ah
    add ax, 700h
    mov si, ax

nextchar:
    lodsb
    cmp al, 0
    jz short endloop
    mov bx, 7
    mov ah, 0Eh
    int 10h    ; - VIDEO - WRITE CHARACTER AND ADVANCE CURSOR (TTY WRITE)
         ; AL = character, BH = display page (alpha modes)
         ; BL = foreground color (graphics modes)
    jmp short nextchar

endloop:
    hlt
    jmp short endloop

sub_7D56 proc near
    sub cx, cx

loc_7D58:
    in al, 64h    ; AT Keyboard controller 8042.
    jmp short $+2
    and al, 2
    loopne loc_7D58
    and al, 2
    retn

aInvalidPartiti db 'Invalid partition table',0
aErrorLoadingOp db 'Error loading operating system',0
aMissingOperati db 'Missing operating system',0
    db    0
    db    0
    db 63h, 7Bh, 9Ah, 0D4h, 34h, 0A0h, 2Eh, 2 dup(0), 80h
    db 20h, 21h, 0, 7, 0DFh, 13h, 0Ch, 0, 8, 3 dup(0), 20h
    db 3, 2 dup(0), 0DFh, 14h, 0Ch, 7, 0FEh, 2 dup(0FFh)

align 1feh, db 0

word_7DFE dw 0AA55h
