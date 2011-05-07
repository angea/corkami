start:
    jmp short next
    nop

aMsdos5_0 db 'MSDOS5.0'
byte_7C0B db 0
    db    2
byte_7C0D db 1
word_7C0E dw 1
byte_7C10 db 2
word_7C11 dw 0E0h
word_7C13 dw 960h
byte_7C15 db 0F9h
word_7C16 dw 7
word_7C18 dw 0Fh
word_7C1A dw 2
word_7C1C dw 0
word_7C1E dw 0
word_7C20 dw 0
    db    0
    db    0
byte_7C24 db 0
byte_7C25 db 0
    dw 0FC29h
    db  18h
aRNoName db 'R!NO NAME    '
aFat12    db 'FAT12   '


next:

    cli
    xor ax, ax
    mov ss, ax
    mov sp,  start
    push ss
    pop es

loc_7C48:
    mov bx, 'x'

loc_7C4B:
    lds si, ss:[bx]
    push ds

loc_7C4F:
    push si

loc_7C50:
    push ss
    push bx

loc_7C52:
    mov di,  next
    mov cx, 0Bh
    cld
    rep movsb
    push es
    pop ds
    mov byte [di-2], 0Fh
    mov cx, ds:word_7C18
    mov [di-7], cl
    mov [bx+2], ax
    mov word [bx],  next
    sti
    int 13h    ; reset disk system
    jb short loc_7CED
    xor ax, ax
    cmp ds:word_7C13, ax
    jz short loc_7C84
    mov cx, ds:word_7C13
    mov ds:word_7C20, cx

loc_7C84:
    mov al, ds:byte_7C10
    mul ds:word_7C16
    add ax, ds:word_7C1C
    adc dx, ds:word_7C1E
    add ax, ds:word_7C0E
    adc dx, 0
    mov word ds:loc_7C50, ax
    mov word ds:loc_7C52, dx
    mov word ds:loc_7C48+1, ax
    mov word ds:loc_7C4B, dx
    mov ax, 20h ; ' '
    mul ds:word_7C11
    mov bx, word ds:byte_7C0B
    add ax, bx
    dec ax
    div bx
    add word ds:loc_7C48+1, ax
    adc word ds:loc_7C4B, 0
    mov bx, 500h
    mov dx, word ds:loc_7C52
    mov ax, word ds:loc_7C50
    call sub_7D60
    jb short loc_7CED
    mov al, 1
    call sub_7D81
    jb short loc_7CED
    mov di, bx
    mov cx, 0Bh
    mov si,  aIoSysmsdosSys ; "IO      SYSMSDOS SYS"
    repe cmpsb
    jnz short loc_7CED
    lea di, [bx+20h]
    mov cx, 0Bh
    repe cmpsb
    jz short loc_7D05

loc_7CED:
    mov si,  aNonSystemDiskO ; "\r\nNon-System disk or disk error\r\nReplac"...
    call sub_7D52
    xor ax, ax
    int 16h    ; KEYBOARD - READ CHAR FROM BUFFER, WAIT IF EMPTY
         ; Return: AH = scan code, AL = character
    pop si
    pop ds
    pop word [si]
    pop word [si+2]
    int 19h    ; DISK BOOT
         ; causes reboot of disk system

loc_7D00:
    pop ax
    pop ax
    pop ax
    jmp short loc_7CED


loc_7D05:
    mov ax, [bx+1Ah]
    dec ax
    dec ax
    mov bl, ds:byte_7C0D
    xor bh, bh
    mul bx
    add ax, word ds:loc_7C48+1
    adc dx, word ds:loc_7C4B
    mov bx, 700h
    mov cx, 3

loc_7D20:
    push ax
    push dx
    push cx
    call sub_7D60
    jb short loc_7D00
    mov al, 1
    call sub_7D81
    pop cx
    pop dx
    pop ax
    jb short loc_7CED
    add ax, 1
    adc dx, 0
    add bx, word ds:byte_7C0B
    loop loc_7D20
    mov ch, ds:byte_7C15
    mov dl, ds:byte_7C24
    mov bx, word ds:loc_7C48+1
    mov ax, word ds:loc_7C4B
    jmp far ptr 70h:0



sub_7D52 proc near
    lodsb
    or al, al
    jz short locret_7D80
    mov ah, 0Eh
    mov bx, 7
    int 10h    ; - VIDEO - WRITE CHARACTER AND ADVANCE CURSOR (TTY WRITE)
         ; AL = character, BH = display page (alpha modes)
         ; BL = foreground color (graphics modes)
    jmp short sub_7D52
sub_7D52 endp




sub_7D60 proc near
    cmp dx, ds:word_7C18
    jnb short loc_7D7F
    div ds:word_7C18
    inc dl
    mov byte ds:loc_7C4F, dl
    xor dx, dx
    div ds:word_7C1A
    mov ds:byte_7C25, dl
    mov word ds:loc_7C4B+2, ax
    clc
    retn


loc_7D7F:
    stc

locret_7D80:
    retn
sub_7D60 endp




sub_7D81 proc near
    mov ah, 2
    mov dx, word ds:loc_7C4B+2
    mov cl, 6
    shl dh, cl
    or dh, byte ds:loc_7C4F
    mov cx, dx
    xchg ch, cl
    mov dl, ds:byte_7C24
    mov dh, ds:byte_7C25
    int 13h    ; read sectores
    retn
sub_7D81 endp


aNonSystemDiskO db 0Dh,0Ah
    db 'Non-System disk or disk error',0Dh,0Ah
    db 'Replace and press any key when ready',0Dh,0Ah,0
aIoSysmsdosSys db 'IO      SYSMSDOS   SYS',0
    db    0
    dw 0AA55h
