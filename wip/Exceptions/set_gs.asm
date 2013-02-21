%include 'head.inc'

EntryPoint:
    mov eax, gs
    test eax, eax
    jnz end_
_
    push fs
    pop gs
    push handler
    push dword [gs:0]
    mov [gs:0], esp
_
    int3
_
end_:
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

Msg db " * set a SEH via GS", 0ah, 0
_d

ALIGN FILEALIGN, db 0