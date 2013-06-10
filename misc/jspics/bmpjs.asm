; a hand-made BMP containing valid JavaScript code
; abusing header to start a JavaScript comment

; inspired by Saumil Shah's Deadly Pixels presentation

; Ange Albertini, BSD Licence 2013

hof:
db 'BM'

    dd 10799 ; in theory FILESIZE, but encoding '/*' instead
    dd 0  ; padding
    dd 0 ; datasize ; seems to make no difference

header:
    dd HEADERSIZE
    dd 20, 20 ; width, height ; could be 1, 1, but we wouldn't see it's actually rendered
    dw 0 ; nb_plan ; 0 plan ? :D
    dw 1 ; bpp
    dd 0 ; compression = uncompressed
    dd 0 ; supposed to be IMAGESIZE, but actually ignored :(
    dd 1 ; horiz dpi
    dd 1 ; vert dpi
    dd 0 ; used colors ; no colors :p
    dd 0 ; important colors
HEADERSIZE equ $ - header

palette: ; color as RGBA - looks like we need 2
    dd 0ff800080h
    dd 0ff008080h 

rawbytes:
    ; who needs actual data when any loader ignored everything...
    IMAGESIZE equ $ - rawbytes

FILESIZE equ $ - hof

db '*/'  ; closing the comment
db '=1;' ; creating a fake use of that BM string

db 'alert("Hello World\n(from a BMP file)");'