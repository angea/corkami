org 7c00h
NEWBASE equ 600h
MBRLEN equ 100h
MARKER equ 0AA55h
bits 16

start:
    cli
    xor ax, ax                              ;ORIGINAL 33 c0
    mov ss, ax
    mov sp, start
    mov si, sp                              ;ORIGINAL 8b f4
    push ax
    pop es
    push ax
    pop ds
    sti

    cld
    mov di, start - (start - NEWBASE)
    mov cx, MBRLEN
    rep movsw
    jmp far 0:next - (start - NEWBASE)

next:
    mov si, BIOS - (start - NEWBASE)
    mov bl, 4

next_block:
    cmp byte [si], 80h
    jz short loc_7C35
    cmp byte [si], 0                        ;ORIGINAL 82 3c 00
    jnz short errorPartition
    add si, 10h
    dec bl
    jnz next_block
    int 18h

loc_7C35:
    mov dx, [si]
    mov cx, [si+2]
    mov bp, si                              ;ORIGINAL 8b ee

loc_7C3C:
    add si, 10h
    dec bl
    jz short loc_7C5E
    cmp byte [si], 0                        ;ORIGINAL 82 3c 00
    jz short loc_7C3C

errorPartition:
    mov si, aInvalidPartiti - (start - NEWBASE)

print:
    xor ch, ch                              ;ORIGINAL 32 ed
    lodsb
    mov cl, al                              ;ORIGINAL 8a c8

nextchar:
    lodsb
    push si
    mov bx, 7
    mov ah, 0Eh
    int 10h

    pop si
    loop nextchar

endloop:
    jmp short endloop


loc_7C5E:
    mov di, 5

loc_7C61:
    mov bx, start
    mov ax, 2 * 100h + 1
    push di
    int 13h

    pop di
    jnb MissingOS

    xor ax, ax                              ;ORIGINAL 33 c0
    int 13h

    dec di
    jnz loc_7C61

    mov si, aErrorLoadingOp - (start - NEWBASE)
    jmp print


MissingOS:
    mov si, aMissingOperati - (start - NEWBASE)
    cmp word [word_7DFE], MARKER
    jnz print

    mov si, bp                              ;ORIGINAL 8b f5
    jmp far 00:start

aInvalidPartiti db 23,'Invalid partition table'
aErrorLoadingOp db 30,'Error loading operating system'
aMissingOperati db 24,'Missing operating system'
aAuthorDavidLit db 'Author - David Litton',0

    times 0CDh db 0
BIOS:
    db 80h, 1, 1, 0, 0Bh, 7Fh, 0BFh, 0FDh, 3Fh, 0,0,0
    db 0C1h, 40h, 5Eh
times 31h db 0
word_7DFE dw MARKER

;CHECKSUM 0929fe998d0da55b96c69c6febb01401
