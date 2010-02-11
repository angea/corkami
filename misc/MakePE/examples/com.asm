; simple COM helloworld
bits 16

org 100h
    push    cs
    pop     ds
    mov     dx, dos_msg
    mov     ah, 9
    int     21h
    mov     ax, 4c01h
    int     21h
dos_msg:
    db 'Hello World!$'