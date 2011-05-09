; Assembly rewrite of:  AA86 - Symbolic assembler demo (http://utf-8.jp/public/sas/) by Yosuke HASEGAWA
bits 16

%macro _ 0
    pusha
    pop di
    pop si
    pop bx
    pop si
    pop di
    pop si
    pop bp
%endmacro

    and ax, 2240h
    and ax, 4022h
    sub al, 7eh
    sub al, 25h
    sub al, 21h
_
    sub ax, 3e3bh
_
    and ax, 2122h
    sub al, 5eh ; '^'
    sub al, 3ah ; ':'
_
    sub ax, 7b40h
    sub ax, 7b60h
    sub ax, 3a3fh

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
_
    sub ax, 7e60h
    sub ax, 6060h
    sub ax, 2440h
_
    sub ax, 6060h
    sub ax, 6060h
    sub ax, 4040h
_
    sub ax, 7e60h
    sub ax, 6060h
    sub ax, 2340h
_
    sub ax, 7e2bh
    sub ax, 7e2fh
    sub ax, 3b3fh
_
    and ax, 7e21h
    sub ax, 2d3bh
    sub al, 3bh
_
    sub ax, 2422h
    sub ax, 7e40h
    sub ax, 6040h
_
    sub ax, 5b7bh
    sub ax, 3b29h
    sub ax, 3a40h
_
    sub ax, 2a2fh
    sub al, 25h
_
_
_
_
    and ax, 2440h
    sub ax, 3b40h
    sub ax, 3b3fh
_
    sub ax, 7e2fh
    sub ax, 2660h
    sub al, 23h
_
    sub ax, 7e60h
    sub ax, 7b60h
    sub al, 2ah
_
    sub ax, 4040h
    sub ax, 2124h
_
    sub ax, 243ah
    sub al, 5bh
    sub al, 3ch
_
    sub ax, 7c21h
    sub ax, 292eh
    sub al, 21h
_
    sub ax, 7b40h
    sub ax, 6040h
    sub ax, 282fh
_
_
_
_
    sub ax, 217bh
    sub ax, 2e7bh
    sub al, 2eh
_
    sub ax, 2f7eh
    sub ax, 602fh
_
    and ax, 2222h
    sub ax, 407dh
    and al, 22h
_
    and ax, 4040h
    sub ax, 2f21h
    sub al, 21h
_
    sub ax, 2a3ah
    sub ax, 253dh
    pusha
    pop bx
    pop bx
    pop bx
    pop bx
    pop bx
    pop bx
    pop bx
    pop bx

    pusha
    pop si
    pop si
    pop si
    pop si
    pop si
    sub ax, 2b25h
    sub [bx + si + 40h], ax
    pop si
    pop si
    pop si

    and [bp+di], di
    inc ax
    inc ax
    ; NOP db 021h, 040h, 040h, 029h

    ; Hello world
    db 05fh, 021h, 02ch, 028h, 028h, 02ch, 02eh, 028h, 028h, 02dh, 024h, 02bh, 029h, 040h, 02ah, 02bh
    db 040h, 021h, 021h, 040h, 02dh, 02ch, 021h, 022h, 028h, 02bh, 040h, 040h, 02ch, 024h, 02dh, 02ch
    db 021h, 022h, 028h, 024h, 025h, 026h, 02ch, 026h, 02ch, 026h, 05fh, 026h, 02ch, 022h, 040h, 022h
    db 027h, 025h, 05fh, 026h, 022h, 027h, 02ch, 026h, 024h, 026h, 02dh, 040h, 02ah, 040h, 024h, 022h

