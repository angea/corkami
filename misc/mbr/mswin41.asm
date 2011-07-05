org 7c00h
NEWBASE equ 600h
MBRLEN equ 100h
MARKER equ 0AA55h

start:
	jmp short next
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


next:        
    xor cx, cx ;ORIGINAL 33 c9
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
    mov bp,  start
    mov byte [di-2], 0Fh
    cmp [bp+24h], cl
    jge short loc_7C8D
	
    mov ax, cx ;ORIGINAL 8b c1
    cwd
    call sub_7DF1
	
    sub bx, 3Ah ; ':'
    mov eax, [dword_7C1C]

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
    xor cx, cx ;ORIGINAL 33 c9
    inc byte [byte_7DD8]

loc_7C93:        
    mov al, [bp+10h]
    cbw
    mul word [bp+16h]
    add ax, [bp+1Ch]
    adc dx, [bp+1Eh]
    add ax, [bp+0Eh]
    adc dx, cx ;ORIGINAL 13 d1
    mov si, [bp+11h]
    pusha
    mov [bp-4], ax
    mov [bp-2], dx
    mov ax, 20h ; ' '
    mul si
    mov bx, [bp+0Bh]
    add ax, bx ;ORIGINAL 03 c3
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
    cmp di, bx ;ORIGINAL 3b fb
    jb short loc_7CCB
	
    jmp short loc_7CC3


loc_7CE6:        
    dec byte [byte_7DD8]
    jnp short loc_7C93
	
    mov si,  word_7D7F

loc_7CEF:        
    lodsb
    cbw
    add si, ax ;ORIGINAL 03 F0

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
    pop dword [si] ; large
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

    jmp far 70h:200h

loc_7D37:        
    push dx
    push ax
    push es
    push bx
    push 1
    push 10h
    xchg ax, cx
    mov ax, [bp+18h]
    mov [526h], al
    xchg ax, si
    xchg ax, dx
    xor dx, dx ;ORIGINAL 33 d2
    div si
    xchg ax, cx
    div si
    inc dx
    xchg dx, cx
    div word [bp+1Ah]
    mov dh, dl ;ORIGINAL 8a f2
    mov ch, al ;ORIGINAL 8a e8
    ror ah, 2
    or cl, ah ;ORIGINAL 0a CC
    mov ax, 201h
    cmp byte [bp+2], 0Eh
    jnz short loc_7D6B

    mov ah, 42h ; 'B'
    mov si, sp ;ORIGINAL 8b f4

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

word_7D7F dw 1803h    
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

sub_7DF1:
    inc cx

sub_7DF2:
    mov bx, 700h

loc_7DF5:        
    pusha
    push dword 0
    jmp loc_7D37

dw 0

marker    dw MARKER

;CHECKSUM 6132527d7c41cf9dd31a5a23285b820b