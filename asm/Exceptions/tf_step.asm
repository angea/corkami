; an exception handler sets the Trap Flag, to manually step trough the original code

;Ange Albertini, BSD Licence, 2009-2012

%include 'head.inc'

COUNT equ 4

EntryPoint:
    setSEH handler
    db 0f1h ; IceBP

times COUNT nop

_end:   ; until here
    nop
    cmp byte [counter], COUNT + 1
    jz good
    jmp bad

handler:
    mov edx, [esp + exceptionHandler.pContext + 4]
    cmp dword [edx + CONTEXT.regEip], _end
    jg here

    ; if in the right range, we count it
    inc byte [counter]

    ; and set the trap flag in the context
    or dword [edx + CONTEXT.regFlag], 0100h

here:
    mov eax, ExceptionContinueExecution
    retn
_c

counter db 0

bad:
    push 42
    call [__imp__ExitProcess]
_c

good:
    push Msg
    call [__imp__printf]
    add esp, 1 * 4
_
    push 0
    call [__imp__ExitProcess]
_c

Msg db " * manual stepping via trap flag", 0ah, 0
_d

ALIGN FILEALIGN, db 0
