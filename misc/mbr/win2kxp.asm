%include 'consts.inc'

org 7c00h
bits 16

start:
    xor ax, ax                              ;ORIGINAL 33 c0
    mov ss, ax
    mov sp, start
    sti
    push ax
    pop es
    push ax
    pop ds
    cld
    mov si, next
    mov di, next - start + NEWBASE
    push ax
    push di
    mov cx, 1E5h
    rep movsb
    retf

next:
    mov bp, 7BEh
    mov cl, 4

loc_7C20:
    cmp [bp], ch
    jl loc_7C2E

    jnz loc_7C3A

    add bp, 10h
    loop loc_7C20

    int 18h

loc_7C2E:
    mov si, bp                              ;ORIGINAL 8B f5

loc_7C30:
    add si, 10h
    dec cx
    jz short loc_7C4F

    cmp [si], ch
    jz short loc_7C30

loc_7C3A:
    mov al, [7B5h]

loc_7C3D:
    mov ah, 7
    mov si, ax                              ;ORIGINAL 8b f0

loc_7C41:
    lodsb

endloop:
    cmp al, 0
    jz endloop
    mov bx, 7
    mov ah, 0Eh
    int 10h    ; - VIDEO - WRITE CHARACTER AND ADVANCE CURSOR (TTY WRITE)
         ; AL = character, BH = display page (alpha modes)
         ; BL = foreground color (graphics modes)
    jmp loc_7C41


loc_7C4F:
    mov [bp + 10h], cl
    call sub_7C9B

    jnb short loc_7C81

loc_7C57:
    inc byte [bp + 10h]
    cmp byte [bp + 4], 0Bh
    jz short loc_7C6B

    cmp byte [bp + 4], 0Ch
    jz short loc_7C6B

    mov al, [7B6h]
    jnz short loc_7C3D

loc_7C6B:
    add byte [bp + 2], 6
    add word [bp + 8], 6
    adc word [bp + 0Ah], 0
    call sub_7C9B

    jnb short loc_7C81

    mov al, [7B6h]
    jmp short loc_7C3D


loc_7C81:
    cmp word [marker], 0AA55h
    jz loc_7C94

    cmp byte [bp + 10h], 0
    jz  loc_7C57

    mov al, [7B7h]
    jmp loc_7C3D


loc_7C94:
    mov di, sp                              ;ORIGINAL 8b fc
    push ds
    push di
    mov si, bp                              ;ORIGINAL 8b f5
    retf

sub_7C9B:
    mov di, 5
    mov dl, [bp + 0]
    mov ah, 8
    int 13h

    jb short loc_7CCA

    mov al, cl                              ;ORIGINAL 8a c1
    and al, 3Fh
    cbw
    mov bl, dh                              ;ORIGINAL 8a de
    mov bh, ah                              ;ORIGINAL 8a fc
    inc bx
    mul bx
    mov dx, cx                              ;ORIGINAL 8b d1
    xchg dl, dh                             ;ORIGINAL 86 d6
    mov cl, 6
    shr dh, cl
    inc dx
    mul dx
    cmp [bp + 0Ah], dx
    ja short loc_7CE6

    jb short loc_7CCA

    cmp [bp + 8], ax
    jnb short loc_7CE6

loc_7CCA:
    mov ax, 201h
    mov bx, start
    mov cx, [bp + 2]
    mov dx, [bp + 0]
    int 13h    ; read sectores

    jnb locret_7D2B

    dec di
    jz locret_7D2B

    xor ah, ah                              ;ORIGINAL 32 e4
    mov dl, [bp + 0]
    int 13h    ; reset disk system

    jmp loc_7CCA


loc_7CE6:
    mov dl, [bp + 0]
    pusha
    mov bx, 55AAh
    mov ah, 41h ; 'A'
    int 13h    ; DISK -

    jb short loc_7D29

    cmp bx, 0AA55h
    jnz short loc_7D29

    test cl, 1
    jz short loc_7D29

    popa

loc_7CFF:
    pusha
    push 0
    push 0
    push word [bp + 0Ah]
    push word [bp + 8]
    push 0
    push  start
    push 1
    push 10h
    mov ah, 42h ; 'B'
    mov si, sp                              ;ORIGINAL 8B f4
    int 13h    ; DISK -

    popa
    popa
    jnb locret_7D2B

    dec di
    jz locret_7D2B

    xor ah, ah                              ;ORIGINAL 32 e4
    mov dl, [bp + 0]
    int 13h    ; reset disk system
    jmp loc_7CFF


loc_7D29:
    popa
    stc

locret_7D2B:
    retn

aInvalidPartiti db 'Invalid partition table',0
aErrorLoadingOp db 'Error loading operating system',0
aMissingOperati db 'Missing operating system',0
times 39h db 0
db 2Ch, 44h, 63h, 0A8h, 0E1h, 0A8h, 0E1h, 0,0
bios:
    db 80h, 1,1, 0, 7, 7Fh, 0BFh, 0FDh, 3Fh, 0,0,0
    db 0C1h, 40h, 5Eh

align 1feh, db 0
marker dw MARKER

;CHECKSUM c9e04cf50e134fe0ae322b220861cb85
