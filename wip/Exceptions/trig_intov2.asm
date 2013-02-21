%include 'head.inc'

EntryPoint:
    push handler
    push dword [fs:0]
    mov [fs:0], esp
_
    mov eax, 80000000h
    rol eax, 1
    into
_
    push 42
    call [__imp__ExitProcess]
_c

handler:
    push Msg
    call [__imp__printf]
    add esp, 1 * 4
_
    push 0
    call [__imp__ExitProcess]
_c

Msg db " * trigger: integer overflow via INTO", 0ah, 0
_d

ALIGN FILEALIGN, db 0