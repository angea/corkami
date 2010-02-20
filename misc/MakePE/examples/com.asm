; simple COM helloworld
bits 16
org 100h
; ///////////////////////////////////////
;     jmp start
; db 0dh    ; Carriage Return
; db 'Secret Message - Homage to Budokan, 1989'
; db 01ah   ; EndOfFile
; //////////////////////////////////////

start:
;   push cs
;   pop ds
    mov dx, dos_msg
    mov ah, 9
    int 21h
    int 20h
;   mov ax, 4c01h
;   int 21h
dos_msg:
    db 'Hello World!$'

;Ange Albertini, Creative Commons BY, 2010