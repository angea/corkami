%include 'consts.inc'

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
    mov cx, SHORTLEN
    rep movsw
    jmp far 0:next - (start - NEWBASE)

next:
    mov si, PARTITIONS - (start - NEWBASE)
    mov bl, 4

next_block:
    cmp byte [si], BOOTABLE
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

PARTITIONS:
istruc PARTITION ; #1
	at PARTITION.state,       db BOOTABLE
	at PARTITION.CHSfirst,    db 1, 1, 0
	at PARTITION.type,        db FAT32
	at PARTITION.CHSlast,     db 7Fh, 0BFh, 0FDh,
	at PARTITION.StartSector, dd 3Fh
	at PARTITION.Size,        dd 5e40c1h
iend

istruc PARTITION ; #2
iend
istruc PARTITION ; #3
iend
istruc PARTITION ; #4
iend

word_7DFE dw MARKER

;CHECKSUM 0929fe998d0da55b96c69c6febb01401
