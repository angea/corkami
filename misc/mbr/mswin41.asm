    jmp short loc_7C3E
    nop

aMswin4_1 db 'MSWIN4.1',0
    db    2
    db    1
    db    1
    db    0
    db    2
    db 0E0h ; à
    db    0
    db  40h ; @
    db  0Bh
    db 0F0h ; ð
    db    9
    db    0
    db  12h
    db    0
    db    2
    db    0
dword_7C1C dd 0     
    db    0
    db    0
    db    0
    db    0
    db    0
    db    0
aLBootdiskFat12 db ')!l',15h,27h,'BOOTDISK   FAT12   '


loc_7C3E:        
    xor cx, cx
    mov ss, cx
    mov sp, 7BFCh
    push ss
    pop es
    mov bp, 78h ; 'x'
    lds si, [bp+0]
    push ds
    push si
    push ss
    push bp
    mov di, 522h
    mov [bp+0], di
    mov [bp+2], cx
    mov cl, 0Bh
    cld
    rep movsb
    push es
    pop ds
    mov bp,  loc_7C00
    mov byte [di-2], 0Fh
    cmp [bp+24h], cl
    jge short loc_7C8D
    mov ax, cx
    cwd
    call sub_7DF1
    sub bx, 3Ah ; ':'
    mov eax, ds:dword_7C1C

loc_7C7A:        
    cmp eax, [bx]
    mov dl, [bx-4]
    jnz short loc_7C88
    or dl, 2
    mov [bp+2], dl

loc_7C88:        
    add bl, 10h
    jnb short loc_7C7A

loc_7C8D:        
    xor cx, cx
    inc ds:byte_7DD8

loc_7C93:        
    mov al, [bp+10h]
    cbw
    mul word [bp+16h]
    add ax, [bp+1Ch]
    adc dx, [bp+1Eh]
    add ax, [bp+0Eh]
    adc dx, cx
    mov si, [bp+11h]
    pusha
    mov [bp-4], ax
    mov [bp-2], dx
    mov ax, 20h ; ' '
    mul si
    mov bx, [bp+0Bh]
    add ax, bx
    dec ax
    div bx
    add [bp-4], ax
    adc [bp-2], cx
    popa

loc_7CC3:        
    mov di, 700h
    call sub_7DF1
    jb short loc_7D09

loc_7CCB:        
    cmp [di], ch
    jz short loc_7CE6
    pusha
    mov cl, 0Bh
    mov si,  byte_7DD8
    repe cmpsb
    popa
    jz short loc_7D17
    dec si
    jz short loc_7CE6
    add di, 20h ; ' '
    cmp di, bx
    jb short loc_7CCB
    jmp short loc_7CC3


loc_7CE6:        
    dec ds:byte_7DD8
    jnp short loc_7C93
    mov si,  word_7D7F

loc_7CEF:        
    lodsb
    cbw
    add si, ax

loc_7CF3:        
    lodsb
    cbw
    inc ax
    jz short loc_7D04
    dec ax
    jz short loc_7D0E
    mov ah, 0Eh
    mov bx, 7
    int 10h    ; - VIDEO - WRITE CHARACTER AND ADVANCE CURSOR (TTY WRITE)
         ; AL = character, BH = display page (alpha modes)
         ; BL = foreground color (graphics modes)
    jmp short loc_7CF3


loc_7D04:        
    mov si,  aInvalidSystemD ; "'\r\nInvalid system disk"
    jmp short loc_7CEF


loc_7D09:        
    mov si, ( word_7D7F+1)
    jmp short loc_7CEF


loc_7D0E:        
    int 16h    ; KEYBOARD -
    pop si
    pop ds
    pop large dword ptr [si]
    int 19h    ; DISK BOOT
         ; causes reboot of disk system

loc_7D17:        
    mov si,  byte_7D81
    mov di, [di+1Ah]
    lea ax, [di-2]
    mov cl, [bp+0Dh]
    mul cx
    add ax, [bp-4]
    adc dx, [bp-2]
    mov cl, 4
    call sub_7DF2
    jb short loc_7D09
    jmp far ptr 70h:200h

; START OF FUNCTION CHUNK FOR sub_7DF2

loc_7D37:        
    push dx
    push ax
    push es
    push bx
    push 1
    push 10h
    xchg ax, cx
    mov ax, [bp+18h]
    mov ds:526h, al
    xchg ax, si
    xchg ax, dx
    xor dx, dx
    div si
    xchg ax, cx
    div si
    inc dx
    xchg cx, dx
    div word [bp+1Ah]
    mov dh, dl
    mov ch, al
    ror ah, 2
    or cl, ah
    mov ax, 201h
    cmp byte [bp+2], 0Eh
    jnz short loc_7D6B
    mov ah, 42h ; 'B'
    mov si, sp

loc_7D6B:        
    mov dl, [bp+24h]
    int 13h    ; DISK -
    popa
    popa
    jb short locret_7D7E
    inc ax
    jnz short loc_7D78
    inc dx

loc_7D78:        
    add bx, [bp+0Bh]
    dec cx
    jnz short loc_7DF5

locret_7D7E:        
    retn
; END OF FUNCTION CHUNK FOR sub_7DF2

word_7D7F dw 1803h    
         ; seg000:loc_7D09o
byte_7D81 db 1     
aInvalidSystemD db 27h,0Dh,0Ah    
    db 'Invalid system disk'
    db 0FFh
aDiskIOError db 0Dh,0Ah
    db 'Disk I/O error'
    db 0FFh
aReplaceTheDisk db 0Dh,0Ah
    db 'Replace the disk, and then press any key',0Dh,0Ah,0
    db    0
byte_7DD8 db 49h     
aOSysmsdosSys db 'O      SYSMSDOS   SYS'
    db  7Fh ; 
    db    1
    db    0



sub_7DF1 proc near    
    inc cx
sub_7DF1 endp




sub_7DF2 proc near    

; FUNCTION CHUNK AT 7D37 SIZE 00000048 BYTES

    mov bx, 700h

loc_7DF5:        
    pusha
    push large 0
    jmp loc_7D37
sub_7DF2 endp


    db    0
    db    0
marker    dw 0AA55h
