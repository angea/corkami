; Assembly rewrite of:  AA86 - Symbolic assembler demo (http://utf-8.jp/public/sas/) by Yosuke HASEGAWA

; the idea behind AA86 is an encoding that recreates any byte from a word made of symbols
;    lodsw
;    shl ah, 4
;    and al, 0Fh
;    or al, ah
;    stosb

; the size itself is encoded on 2 words, to get a value on 1 word

; during execution of this binary,
; the decoding algorithm is built on the stack, backward, word by word,
; by crafting ax, pushing it with pushad then popping registers to leave a single word on the stack.
; then it jumps to the stack (the 'jmp sp' is decoded too), where the length is restored, then the decoding loop is performed

;algorithm built on the stack, word by word:

;    mov  si, payload                        ; be d002
;    mov  di, start                          ; bf 0001

;    lodsw                                   ; ad   ; size decoding
;    nop                                     ; 90
;    shl ax, 1                               ; d1e0
;    shl ax, 1                               ; d1e0
;    shl ax, 1                               ; d1e0
;    shl ax, 1                               ; d1e0
;    and ah, 0F0h                            ; 80e4 f0
;    mov cx, ax                              ; 89c1
;    lodsw                                   ; ad
;    and ax, 0F0Fh                           ; 25 0f0f
;    or cx, ax                               ; 09c1

;_loop:
;    lodsw                                   ; ad
;    shl ah, 1                               ; d0e4
;    shl ah, 1                               ; d0e4
;    shl ah, 1                               ; d0e4
;    shl ah, 1                               ; d0e4
;    and al, 0Fh                             ; 24 0f
;    or al, ah                               ; 08e0
;    stosb                                   ; aa
;    loop _loop                              ; e2f0

;    nop                                     ; 90       ; init and eop jump
;    mov ax,cx                               ; 89c8
;    mov dx,cx                               ; 89ca
;    mov bx,cx                               ; 89cb
;    mov si,cx                               ; 89ce
;    mov di,cx                               ; 89cf
;    push start                              ; 68 0001
;    ret 3Ch                                 ; c23c00

; compile with : yasm -o aa86.com aa86.asm

bits 16

org 100h

%macro _pushax 0
    pusha
    pop di
    pop si

    pop bx
    pop si

    pop di
    pop si

    pop bp
%endmacro

start:
    and ax, 2240h
    and ax, 4022h
    sub al, 7eh
    sub al, 25h
    sub al, 21h
    ; ax = 003c
_pushax

    sub ax, 3e3bh
    ; ax = C201
_pushax

    and ax, 2122h
    sub al, 5eh
    sub al, 3ah
    ; ax = 0068
_pushax

    sub ax, 7b40h
    sub ax, 7b60h
    sub ax, 3a3fh
    ; ax = cf89

; not sure why that one is slightly different, it could be a _pushax
    pusha
    pop di
    pop bx
    pop si
    pop di
    pop si
    pop bp
    pop di

    sub ax, 6060h
    sub ax, 6060h
    sub ax, 4040h
    ; ax = cf89
_pushax

    sub ax, 7e60h
    sub ax, 6060h
    sub ax, 2440h
    ; ax = cb89
_pushax

    sub ax, 6060h
    sub ax, 6060h
    sub ax, 4040h
    ; ax = ca89
_pushax

    sub ax, 7e60h
    sub ax, 6060h
    sub ax, 2340h
    ; ax = c889
_pushax

    sub ax, 7e2bh
    sub ax, 7e2fh
    sub ax, 3b3fh
    ; 90f0
_pushax

    and ax, 7e21h
    sub ax, 2d3bh
    sub al, 3bh
    ; e2aa
_pushax

    sub ax, 2422h
    sub ax, 7e40h
    sub ax, 6040h
    ; e008
_pushax

    sub ax, 5b7bh
    sub ax, 3b29h
    sub ax, 3a40h
    ; 0f24
_pushax

    sub ax, 2a2fh
    sub al, 25h
    ; e4d0 * 4
_pushax
_pushax
_pushax
_pushax

    and ax, 2440h
    sub ax, 3b40h
    sub ax, 3b3fh
    ; adc1
_pushax

    sub ax, 7e2fh
    sub ax, 2660h
    sub al, 23h
    ; 090f
_pushax

    sub ax, 7e60h
    sub ax, 7b60h
    sub al, 2ah
    ; 0f25
_pushax

    sub ax, 4040h
    sub ax, 2124h
    ; adc1
_pushax

    sub ax, 243ah
    sub al, 5bh
    sub al, 3ch
    ; 89f0
_pushax

    sub ax, 7c21h
    sub ax, 292eh
    sub al, 21h
    ; e480
_pushax

    sub ax, 7b40h
    sub ax, 6040h
    sub ax, 282fh
    ; e0d1 * 4
_pushax
_pushax
_pushax
_pushax

    sub ax, 217bh
    sub ax, 2e7bh
    sub al, 2eh
    ; 90ad
_pushax

    sub ax, 2f7eh
    sub ax, 602fh
    ; 0100
_pushax

    and ax, 2222h
    sub ax, 407dh
    and al, 22h
    ; bf02
_pushax

    and ax, 4040h
    sub ax, 2f21h
    sub al, 21h
    ; d0be
_pushax

    sub ax, 2a3ah
    sub ax, 253dh
    ; 8147

    pusha   ; this time, we specifically set bx, so we don't leave a word on the stack
    pop bx
    pop bx
    pop bx
    pop bx
    pop bx
    pop bx
    pop bx
    pop bx
    ; => bx = 8147

    pusha   ; and this time, si
    pop si
    pop si
    pop si
    pop si
    pop si
    ; => si = 8147

    sub ax, 2b25h
    ; ax = 5622

    ; we're set to patch the 'jmp sp'
    sub [bx + si + 40h], ax                 ; sub [patchme], 5622h

    ; compensating the previous pusha
    pop si
    pop si
    pop si

patchme:
    dw 3b21h                                ; => FF E4 jmp sp    e4ff = 3b21 - 5622

payload:
; here is an example of payload:

    dw 4040h, 215fh    ; encoded size of 010F

    ; encoded Hello world
    db 02ch, 028h, 028h, 02ch, 02eh, 028h, 028h, 02dh, 024h, 02bh, 029h, 040h, 02ah, 02bh
    db 040h, 021h, 021h, 040h, 02dh, 02ch, 021h, 022h, 028h, 02bh, 040h, 040h, 02ch, 024h, 02dh, 02ch
    db 021h, 022h, 028h, 024h, 025h, 026h, 02ch, 026h, 02ch, 026h, 05fh, 026h, 02ch, 022h, 040h, 022h
    db 027h, 025h, 05fh, 026h, 022h, 027h, 02ch, 026h, 024h, 026h, 02dh, 040h, 02ah, 040h, 024h, 022h
; original code:
;    mov ax, cs                             ; 8cc8
;    mov ds, ax                             ; 8ed8
;    mov ah, 09h                            ; b4 09
;    mov dx, message                        ; ba 1001
;    int 21h                                ; cd 21
;    mov ax, 4c00h                          ; b8 004c
;    int 21h                                ; cd 21
; message:
;     db "Hello, World", 0dh, 0ah, "$"      ; 48 65 6C 6C 6F 2C 20 57 6F 72 6C 64 0D 0A 24

; Ange Albertini, BSD licence, 2011
