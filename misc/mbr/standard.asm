org 7c00h
NEWBASE equ 600h
MBRLEN equ 100h
MARKER equ 0AA55h

start:
    cli
    xor ax, ax ;ORIGINAL 33 c0
    mov ss, ax
    mov sp, start
    mov si, sp ;ORIGINAL 8B F4
    push ax
    pop es
    push ax
    pop ds
    sti
    cld
    mov di, 600h
    mov cx, 100h
    repne movsw
    jmp far 0:61Dh

    mov si, 7dbeh - 7600h
    mov bl, 4

loc_7C22:
    cmp byte [si], 80h ; '€'
    jz short loc_7C35

    cmp byte [si], 0
    jnz short InvalidPartition

    add si, 10h
    dec bl
    jnz short loc_7C22

    int 18h

loc_7C35:
    mov dx, [si]
    mov cx, [si+2]
    mov bp, si ;ORIGINAL 8B ee

loc_7C3C:
    add si, 10h
    dec bl
    jz short loc_7C5D

    cmp byte [si], 0
    jz short loc_7C3C

InvalidPartition:
    mov si,  aInvalidPartiti - 7600h ; "Invalid partition table"

nextchar:
    lodsb
    cmp al, 0
    jz short endloop

    push si
    mov bx, 7
    mov ah, 0Eh
    int 10h    ; - VIDEO - WRITE CHARACTER AND ADVANCE CURSOR (TTY WRITE)
         ; AL = character, BH = display page (alpha modes)
         ; BL = foreground color (graphics modes)
    pop si
    jmp short nextchar

endloop:
    jmp short endloop

loc_7C5D:
    mov di, 5

loc_7C60:
    mov bx,  start
    mov ax, 201h
    push di
    int 13h    ; read sectores

    pop di
    jnb short missingos
    xor ax, ax ;ORIGINAL 33 C0
    int 13h    ; reset disk system

    dec di
    jnz short loc_7C60
    mov si,  aErrorLoadingOp - 7600h ; "Error loading operating system"
    jmp short nextchar


missingos:
    mov si,  aMissingOperati - 7600h ; "Missing operating system"
    mov di,  marker
    cmp word [di], 0AA55h
    jnz short nextchar
    mov si, bp ;ORIGINAL 8B F5
    jmp far 0:start

aInvalidPartiti db 'Invalid partition table',0
aErrorLoadingOp db 'Error loading operating system',0
aMissingOperati db 'Missing operating system',0
    times 0E3h db 0
    db 80h, 1, 1, 0, 0Bh, 7Fh, 0BFh, 0FDh, 3Fh, 0,0,0
    db 0C1h, 40h, 5Eh
    times 31h db 0

marker    dw 0AA55h

;CHECKSUM 5d5cf631a79d9b4c792f3bb759ddf904