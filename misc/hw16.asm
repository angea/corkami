bits 16
org 100h
   mov ax, cs
   mov ds, ax
   mov ah, 09h
   mov dx, message
   int 21h
   mov ax, 4c00h
   int 21h
message:
    db "Hello world!", 0dh, 0ah, "$"
