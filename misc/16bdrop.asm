; Ange Albertini BSD 2012

org 100h
bits 16

; init ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    push    cs
    pop     ds

; print ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mov     dx, dos_msg
    mov     ah, 9 ; print
    int     21h

; shrink image for execution ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mov     ah, 4ah ; reallocate
    mov     sp, stub_end + 40
    mov     bx, sp ;effective end of image
    add     bx, 80h ;it's relative to ds, not cs, round up to next paragraph
    shr     bx, 4 ;convert to paragraphs
    int     21h

; create target ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mov     ah, 03ch ; create file
    mov     cx, 0 ; normal attributes
    mov     dx, new
    int     21h
    jc      end_
    mov     [hnew], ax

; write buffer ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mov     bx, [hnew]
    push    ds
    mov     ah, 40h ; writing
    mov     dx, data_start
    mov     cx, DATA_END
    int     21h
    pop     ds
    jc      end_

; close target file ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mov     ah, 3eh ; close file
    mov     bx, [hnew]
    int     21h
    jc end_

; executing PE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    push    ds
    pop     es
    mov     bx, block
    mov     word [bx + 4], ds
    mov     word [bx + 8], ds
    mov     word [bx + 0ch], ds
    mov     ah, 4bh ; execute
    mov     al, 0 ; load & execute
    mov     dx, new
    ; mov cx, 0 ; children mode
    int     21h
    jc      end_

end_:
    mov     ax, 4c01h
    int     21h

hnew dw 0
hbuf dw 0

new db 'EP.EXE', 0
block:
    dw 0, 80h ; command tail
    dw 0, 5ch ; first fcb
    dw 0, 6ch ; second fcb
    dw 0 ; used when AL = 1
align 16, db 0

dos_msg db ' # dropping PE (from 16bit .COM file)', 0dh, 0dh, 0ah, '$'

data_start:
incbin "tiny.exe"
DATA_END equ $ - data_start

stub_end:
