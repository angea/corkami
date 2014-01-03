; a 'Hello World' BMP

; Ange Albertini BSD Licence 2013

db 'BM'
dd FILESIZE
dd 0 ; padding?
dd data ; datasize

header:
    dd HEADERSIZE
    dd 92, 7 ; width, height ; could be 1, 1, but we wouldn't see it's actually rendered
    dw 0 ; nb_plan ; 0 plan ? :D
    dw 1 ; bpp
    dd 0 ; compression = uncompressed
    dd DATASIZE ; supposed to be IMAGESIZE, but actually ignored :(
    dd 0 ;0ec4h ; horiz dpi
    dd 0 ; 0ec4h ; vert dpi
    dd 2 ; used colors
    dd 0 ; important colors
db 'BGRs'
times 30h db 0
dd 2, 0, 0, 0
HEADERSIZE equ $ - header

db -1, -1, -1
db 0, 0, 0
db 0, 0


data:
incbin 'bmpdata'
DATASIZE equ $ - data

FILESIZE equ $
