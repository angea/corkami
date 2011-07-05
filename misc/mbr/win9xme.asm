org 7c00h
NEWBASE equ 600h
MBRLEN equ 100h
MARKER equ 0AA55h

start:
    xor ax, ax ;ORIGINAL 33 c0
    mov ss, ax
    mov sp,  start
    sti
    push ax
    pop es
    push ax
    pop ds
    cld
    mov si, next
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
    mov bp, si ;ORIGINAL 8b EE

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
    mov [bp + 25h], ax
    xchg ax, si
    mov al, [bp + 4]
    mov ah, 6
    cmp al, 0Eh
    jz short loc_7C6B
	
    mov ah, 0Bh
    cmp al, 0Ch
    jz short loc_7C65
	
    cmp al, ah ;ORIGINAL 3a C4
    jnz short loc_7C8F
	
    inc ax

loc_7C65:
    mov byte [bp + 25h], 6
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
	
    mov ah, al ;ORIGINAL 8a e0
    mov [bp + 24h], dl
    mov word [6A1h], 1EEBh

loc_7C8C:
    mov [bp+4], ah

loc_7C8F:
    mov di, 0Ah

loc_7C92:
    mov ax, 201h
    mov bx, sp ;ORIGINAL 8b dc
    xor cx, cx ;ORIGINAL 33 c9
    cmp di, 5
    jg short loc_7CA1

    mov cx, [bp + 25h]

loc_7CA1:
    add cx, [bp + 2]
    int 13h

loc_7CA6:
    jb short loc_7CD1

    mov si, 746h
    cmp word [word_7DFE], 0AA55h
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

    xor ax, ax ;ORIGINAL 33 c0
    int 13h    ; reset disk system

    jmp short loc_7C92

    times 6 db 0

sub_7CE0:
    push si
    xor si, si ;ORIGINAL 33 f6
    push si
    push si
    push dx
    push ax
    push es
    push bx
    push cx
    mov si, 10h
    push si
    mov si, sp ;ORIGINAL 8B f4
    push ax
    push dx
    mov ax, 4200h
    mov dl, [bp + 24h]
    int 13h

    pop dx
    pop ax
    lea sp, [si + 10h]
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

loc_7D0D:
    jmp short loc_7D83

aInvalidPartiti db 'Invalid partition table',0
aErrorLoadingOp db 'Error loading operating system',0
aMissingOperati db 'Missing operating system',0
times 24h db 0

loc_7D83:
    mov di, sp ;ORIGINAL 8b fc
    push ds
    push di
    mov si, bp ;ORIGINAL 8b f5
    retf

times 34h db 0
 db 80h, 1,1, 0, 0Bh, 7Fh, 0BFh, 0FDh
    db 3Fh, 0,0,0, 0C1h, 40h, 5Eh, 
	times 31h db 0
word_7DFE dw MARKER

;CHECKSUM 55c160cd12a616a6e999b51a1ec2492b