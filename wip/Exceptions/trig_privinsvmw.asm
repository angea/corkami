%include 'head.inc'

EntryPoint:
    push handler
    push dword [fs:0]
    mov [fs:0], esp
_
    mov eax, 'hXMV'
    mov ecx, 10
    mov dx, 'XV'
    in eax, dx
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

Msg db " * exception trigger via privileged instruction (vmware backdoor)", 0ah, 0
_d

ALIGN FILEALIGN, db 0