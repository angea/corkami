%include 'head.inc'

EntryPoint:
    push handler
    push dword [fs:0]
    mov [fs:0], esp
_
    int3
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

Msg db " * BREAKPOINT exception trigger int3 (CC)", 0ah, 0
_d

bound_ dd 3, 5
ALIGN FILEALIGN, db 0