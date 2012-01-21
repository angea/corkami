%include 'head.inc'

EntryPoint:
    mov eax, [fs:018h] ; TIB.self
    push handler
    push dword [eax]
    mov [eax], esp
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

Msg db " * set a SEH via tib.self", 0ah, 0
_d

bound_ dd 3, 5
ALIGN FILEALIGN, db 0