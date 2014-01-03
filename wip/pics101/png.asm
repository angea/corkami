%macro _dd 1
        db (%1 >> 8 * 3) & 0ffh
        db (%1 >> 8 * 2) & 0ffh
        db (%1 >> 8 * 1) & 0ffh
        db (%1 >> 8 * 0) & 0ffh
%endmacro

db 89h, 'PNG', 0dh, 0ah, 1ah, 0ah
_dd 0dh
db 'IHDR'
_dd 92
_dd 7
db 8
dd 3

_dd 0b278da5eh
_dd 6
db "PLTE"
db 0,0,0, -1,-1,-1
_dd 0a5d99fddh
_dd 296h
db 'IDAT'
db 28h, 15h, 01h
_dd 8b0274fdh
db 0

incbin 'pngdata'
_dd 32d701a1h
_dd 0c5a0545ch
dd 0
db 'IEND'
_dd 0ae426082h