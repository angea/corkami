%include 'consts.inc'

STROFF equ NEWBASE + 100h

start:
    xor ax, ax                              ;ORIGINAL 33 c0
    mov ss, ax
    mov sp, start
    mov es, ax
    mov ds, ax
    mov si, start
    mov di, NEWBASE
    mov cx, MBRLEN
    cld
    rep movsb
    push ax
    push next - start + NEWBASE
    retf

next:
    sti
    mov cx, 4
    mov bp, PARTITIONS - start + NEWBASE

loc_7C23:
    cmp byte [bp + 0], NONBOOTABLE
    jl loc_7C34

    jnz loc_7D3B

    add bp, 10h
    loop loc_7C23

    int 18h

loc_7C34:
    mov [bp], dl
    push bp
    mov byte [bp + 11h], 5
    mov byte [bp + 10h], 0
    mov ah, 41h
    mov bx, sMARKER
    int 13h

    pop bp
    jb loc_7C59

    cmp bx, MARKER
    jnz loc_7C59

    test cx, 1
    jz loc_7C59

    inc byte [bp+10h]

loc_7C59:
    pushad
    cmp byte [bp + 10h], 0
    jz loc_7C87

    push 0                                  ;ORIGINAL 66 68 00 00 00 00
    push dword [bp + 8]
    push 0                                  ;ORIGINAL 68 00 00
    push start
    push 1                                  ;ORIGINAL 68 01 00
    push 10h                                ;ORIGINAL 68 10 00
    mov ah, 42h
    mov dl, [bp + 0]
    mov si, sp                              ;ORIGINAL 8B f4
    int 13h

    lahf
    add sp, 10h
    sahf
    jmp loc_7C9B

loc_7C87:
    mov ax, 201h
    mov bx,  start
    mov dl, [bp + 0]
    mov dh, [bp + 1]
    mov cl, [bp + 2]
    mov ch, [bp + 3]
    int 13h    ; read sectors

loc_7C9B:
    popad
    jnb loc_7CBB

    dec byte [bp + 11h]
    jnz loc_7CB0

    cmp byte [bp], 80h
    jz near loc_7D36

    mov dl, 80h
    jmp loc_7C34


loc_7CB0:
    push bp
    xor ah, ah                              ;ORIGINAL 32 e4
    mov dl, [bp]
    int 13h    ; reset disk system

    pop bp
    jmp loc_7C59


loc_7CBB:
    cmp word [marker], MARKER
    jnz noOS

    push word [bp]
    call sub_7D56

    jnz loc_7CE2

    cli
    mov al, 0D1h
    out 64h, al
    call sub_7D56

    mov al, 0DFh
    out 60h, al
    call sub_7D56

    mov al, 0FFh
    out 64h, al

    call sub_7D56
    sti

loc_7CE2:
    mov ax, 0BB00h
    int 1Ah
    and eax, eax                            ;ORIGINAL 66 23 c0
    jnz loc_7D27

    cmp ebx, "TCPA"
    jnz loc_7D27

    cmp cx, 102h
    jb loc_7D27

    push dword 0BB07h                       ;ORIGINAL 66 68 07 bb 00 00
    push dword 200h                         ;ORIGINAL 66 68 00 02 00 00
    push dword 8                            ;ORIGINAL 66 68 08 00 00 00
    push ebx
    push ebx
    push ebp
    push dword 0                            ;ORIGINAL 66 68 00 00 00 00
    push dword start                        ;ORIGINAL 66 68 00 7c 00 00
    popad
    push word 0                             ;ORIGINAL 68 00 00
    pop es
    int 1Ah

loc_7D27:
    pop dx
    xor dh, dh                              ;ORIGINAL 32 f6
    jmp far 0:start

    int 18h

noOS:
    mov al, [lpnoos - start + NEWBASE]
    jmp print

loc_7D36:
    mov al, [lperrorloading - start + NEWBASE]
    jmp print

loc_7D3B:
    mov al, [lpinvalidpart - start + NEWBASE]

print:
    xor ah, ah                              ;ORIGINAL 32 e4
    add ax, STROFF
    mov si, ax                              ;ORIGINAL 8b f0

nextchar:
    lodsb
    cmp al, 0
    jz short endloop

    mov bx, 7
    mov ah, 0Eh
    int 10h

    jmp nextchar

endloop:
    hlt
    jmp endloop

sub_7D56:
    sub cx, cx                              ;ORIGINAL 2b c9

loc_7D58:
    in al, 64h
    jmp $+2
    and al, 2
    loopne loc_7D58
    and al, 2
    retn

aInvalitPart db 'Invalid partition table',0
aErrorLoading db 'Error loading operating system',0
anoOS db 'Missing operating system',0

times 2 db 0

lpinvalidpart:
    db (aInvalitPart - STROFF) & 0ffh
lperrorloading:
    db (aErrorLoading - STROFF) & 0ffh
lpnoos:
    db (anoOS - STROFF) & 0ffh

    db 0D4h
    db  34h
    db 0A0h
    db  2Eh
    db    0
    db    0

PARTITIONS:
istruc PARTITION ; #1
	at PARTITION.state,       db BOOTABLE
	at PARTITION.CHSfirst,    db 020h, 021h, 000h,
	at PARTITION.type,        db NTFS
	at PARTITION.CHSlast,     db 0dfh, 013h, 00ch
	at PARTITION.StartSector, dd 800h
	at PARTITION.Size,        dd 32000h
iend

istruc PARTITION ; #2
	at PARTITION.state,       db NONBOOTABLE
	at PARTITION.CHSfirst,    db 0dfh, 014h, 00ch
	at PARTITION.type,        db NTFS 
    at PARTITION.CHSlast,     db 0feh, 0ffh, 0ffh
iend
istruc PARTITION ; #3
iend
istruc PARTITION ; #4
iend

marker dw MARKER

;CHECKSUM 9d5458d36a14f55d0796b037af42daa6
