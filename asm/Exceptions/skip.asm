; the exception handler overwrite the return address in the stack => the flow is redirected AFTER returning to NTDLL

;Ange Albertini, BSD Licence, 2009-2011

%include 'head.inc'

EntryPoint:
    setSEH handler
    int3
    jmp bad
_c

handler:
    mov dword [esp + 24h], good ; overwrite a return address in the stack to disrupt code execution
; this is all unused, but still here to 'look' standard
    mov eax, [esp + exceptionHandler.pContext + 4]
    mov dword [eax + CONTEXT.regEip], bad
    mov eax, ExceptionContinueExecution
    retn
_c

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

Msg db " * exception handling skipped by stack overwriting", 0ah, 0
_d

ALIGN FILEALIGN, db 0