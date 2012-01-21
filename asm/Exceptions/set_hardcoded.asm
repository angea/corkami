%include 'head.inc'

EntryPoint:
    mov eax, gs
    test eax, eax
    jnz _64b
_
_32b:
    push 03bh
    pop ds
    jmp set_
_c

_64b:
    push 53h
    pop ds
    jmp set_
_c

set_:
    push handler
    push dword [ds:0]
    mov [ds:0], esp
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

Msg db " * set a SEH via hardcoded value", 0ah, 0
_d

bound_ dd 3, 5
ALIGN FILEALIGN, db 0