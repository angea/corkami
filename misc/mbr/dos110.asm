org 7c00h
bits 16

start:
    jmp next
    nop

word_7C03 dw 8
word_7C05 dw 14h
times 20h db 0

reset:
    int 19h

next:
    cli
    mov ax, cs
    mov ds, ax
    xor dx, dx                              ;ORIGINAL 33 d2
    mov ss, dx
    mov sp, start
    sti

    mov ax, 60h
    mov ds, ax
    mov es, ax
    xor dx, dx                              ;ORIGINAL 33 d2
    mov ax, dx                              ;ORIGINAL 8b c2
    int 13h

    jb loc_7CAE

    call sub_7CCD
    jb reset

    cmp word [cs:word_7C03], 8
    jz loc_7C58

    mov byte [cs:byte_7D64], 2

loc_7C58:
    mov bx, 0
    mov cx, [cs:word_7C03]
    push cx
    mov al, 9
    sub al, cl                              ;ORIGINAL 2a c1
    mov ah, 0
    mov si, ax                              ;ORIGINAL 8b f0

loc_7C69:
    push si
    xor dx, dx                              ;ORIGINAL 33 d2
    xor ax, ax                              ;ORIGINAL 33 c0
    mov al, ch                              ;ORIGINAL 8a c5
    div byte [cs:byte_7D64]
    mov ch, al                              ;ORIGINAL 8a e8
    mov dh, ah                              ;ORIGINAL 8a f4
    mov ax, si                              ;ORIGINAL 8b c6
    mov ah, 2
    int 13h

    jb loc_7CAE

    pop si
    pop cx
    sub [cs:word_7C05], si
    jz loc_7CA9

    mov ax, si                              ;ORIGINAL 8b c6
    mul word [cs:word_7D65]
    add bx, ax                              ;ORIGINAL 03 d8
    inc ch
    mov cl, 1
    push cx
    mov si, 8
    cmp si, [cs:word_7C05]
    jl loc_7CA7

    mov si, [cs:word_7C05]

loc_7CA7:
    jmp loc_7C69


loc_7CA9:
    jmp far 60h:0

loc_7CAE:
    mov si, failure
    call print

loc_7CB4:
    jmp loc_7CB4

print:
    xor bh, bh                              ;ORIGINAL 32 ff

loc_7CB8:
    db 2eh                                  ; lodsb doesn't accept operands with Yasm
        lodsb
    and al, 7Fh
    jz locret_7CC9

    push si
    mov ah, 0Eh
    mov bx, 7
    int 10h

    pop si
    jmp loc_7CB8


locret_7CC9:
    retn

    jmp start

sub_7CCD:
    mov bx, 0
    mov cx, 4
    mov ax, 201h
    int 13h

    push ds
    jb error

    mov ax, cs
    mov ds, ax
    mov di, 0
    mov cx, 0Bh

or_loop:
    or byte [es:di], 20h
    or byte [es:di+20h], 20h
    inc di
    loop or_loop

    mov di, 0
    mov si, aIbmbioCom
    mov cx, 0Bh
    cld
    repe cmpsb
    jnz error

    mov di, 20h ; ' '
    mov si, aIbmdosCom
    mov cx, 0Bh
    repe cmpsb
    jnz error

    pop ds
    retn

error:
    mov si, replace
    call print
    mov ah, 0
    int 16h

    pop ds
    stc
    retn

replace db 0Dh,0Ah
    db 'Non-System disk or disk error',0Dh,0Ah
    db 'Replace and strike any key when ready',0Dh,0Ah,0

byte_7D64 db 1
word_7D65 dw 200h

failure db 0Dh,0Ah
    db 'Disk Boot failure',0Dh,0Ah,0
aMicrosoftInc db 'Microsoft,Inc'
    db 20h
aIbmbioCom db 'ibmbio  com'
    db 30h
aIbmdosCom db 'ibmdos  com'

db             030h, 005h, 0c6h, 006h, 077h, 02fh, 0ffh, 083h, 07eh, 0fch, 000h, 075h, 00bh, 080h
db 07eh, 0f7h, 03bh, 075h, 005h, 0c6h, 006h, 076h, 02fh, 0ffh, 089h, 0ech, 05dh, 0cah, 004h, 0000h

times 40h db 0

;CHECKSUM 96a1b68e4ae1ac5fa0a3925c3a0e75bd
