org 7c00h
bits 16

start:
    jmp next

word_7C02 dw 14h
word_7C04 dw 0
word_7C06 dw 60h
a7May81 db ' 7-May-81',0
times 01fh db 0

next:
    cli
    mov ax, cs
    mov ds, ax
    mov dx, 0
    mov ss, dx
    mov sp, start
    sti

    mov ax, [word_7C06]
    mov ds, ax
    mov es, ax
    mov dx, 0
    mov ax, dx                              ;ORIGINAL 8b c2
    int 13h

    jb loc_7C90

loc_7C4F:
    call sub_7CAA
    jb  loc_7C4F

    mov cx, [cs:word_7C02]
    push cx
    mov bx, 0
    xor dx, dx                              ;ORIGINAL 33 d2
    mov cx, 8
    mov si, 1
    push si
    mov al, 1

loc_7C68:
    mov ah, 2
    int 13h

    jb  loc_7C90

    pop si
    pop ax
    call sub_7D5A
    sub ax, si                              ;ORIGINAL 2b c6
    jz  loc_7C8B

    inc ch
    mov cl, 1
    mov si, 8
    cmp ax, si                              ;ORIGINAL 3b c6
    jnb loc_7C86

    mov si, ax                              ;ORIGINAL 8b f0
    jmp loc_7C87

loc_7C86:
    xchg    ax, si

loc_7C87:
    push si
    push ax
    jmp loc_7C68

loc_7C8B:
    jmp far [cs:word_7C04]

loc_7C90:
    mov si, aDiskBootFailur
    mov ax, mark
    push ax

print:
    xor bh, bh                              ;ORIGINAL 32 FF

loc_7C99:
    lodsb
    and al, 7Fh
    jz locret_7CA9
    push si
    mov ah, 0Eh
    mov bx, 7
    int 10h

    pop si
    jmp loc_7C99

locret_7CA9:
    retn

sub_7CAA:
    mov bx, 0
    mov cx, 4
    mov ax, 201h
    int 13h

    push ds
    jb  error

    mov ax, cs
    mov ds, ax
    mov di, 0
    mov cx, 0Bh

or_loop:
    or byte [es:di], 20h ; ' '
    or byte [word es:di + 20h], 20h ; ' '
    inc di
    loop or_loop

    mov di, 0
    mov si, aIbmbioCom
    mov cx, 0Bh
    cld
    repe cmpsb
    jnz error

    mov di, 20h
    mov si, aIbmdosCom
    mov cx, 0Bh
    repe cmpsb
    jnz error

    pop ds
    retn

error:
    mov si, aNonSystemDiskO
    call print
    mov ah, 0
    int 16h

    pop ds
    stc
    retn

aNonSystemDiskO db 0Dh,0Ah
    db 'Non-System disk or disk erro'
    db 0F2h ; ò
aReplaceAndStri db 0Dh,0Ah
    db 'Replace and strike any key when read'
    db 0F9h ; ù
    db 0Dh,0Ah,0
mark:
    db 0CDh
    db  18h
aDiskBootFailur db 0Dh,0Ah
    db 'Disk Boot failurå',0Dh,0Ah,0


sub_7D5A:
    push ax
    push dx
    mov ax, si                              ;ORIGINAL 8b c6
    mov di, 200h
    mul di
    add bx, ax                              ;ORIGINAL 03 d8
    pop dx
    pop ax
    retn

author db 'Robert O',27h,'Rear'
    db  20h
aIbmbioCom  db 'ibmbio  com'
    db 0B0h
aIbmdosCom  db 'ibmdos  com'
 dw 0C9B0h
times 71h db 0

;CHECKSUM a0749d47a38db244ce140b27464ed49a
