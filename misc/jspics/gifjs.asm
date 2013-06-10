; a hand-made GIF containing valid JavaScript code
; abusing header to start a JavaScript comment

; inspired by Saumil Shah's Deadly Pixels presentation

; Ange Albertini, BSD Licence 2013

WIDTH equ 10799 ; equivalent to 2f2a, which is '/*' in ASCII, thus starting an opening comment

HEIGTH equ 10 ; just to make it easier to spot

db 'GIF89a'
    dw WIDTH, HEIGTH

db 0 ; GCT
    db -1 ;  background color
    db 0 ; default aspect ratio
    ;db 0fch, 0feh, 0fch
    ;times COLORS db 0, 0, 0
    
; no need of Graphic Control Extension
 ; db 21h, 0f9h
 ; db GCESIZE ; size
 ; gce_start:
 ;     db 0 ; transparent background
 ;     dw 0 ; delay for anim
 ;     db 0 ; other transparent
 ; GCESIZE equ $ - gce_start
 ;     db 0 ; end of GCE

db 02ch ; Image descriptor
    dw 0, 0 ; NW corner
    dw WIDTH, HEIGTH ; w/h of image
    db 0    ; color table

db 2 ; lzw size

;db DATASIZE
;data_start:
;    db 00, 01, 04, 04
;    DATASIZE equ $ - data_start

db 0
db 3bh ; GIF terminator

; end of the GIF

db '*/'  ; closing the comment
db '=1;' ; creating a fake use of that GIF89a string

db 'alert("Hello World\n(from a GIF file)");'