;the exception handler overwrites the top handler, then trigger another exception.

;Ange Albertini, BSD Licence, 2009-2012

%include 'head.inc'

EntryPoint:
    setSEH handler
    int3
    jmp bad
_c

handler:
    mov dword [esp + 18h], good             ; overwriting the higher level handler

; then pretending everything is fine (actually not needed here)

    mov eax, [esp + exceptionHandler.pContext + 4]
    mov dword [eax + CONTEXT.regEip], bad
    mov eax, ExceptionContinueExecution
; until we reach another trigger that just calls the overwritten handler
    int3
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

Msg db " * exception handler overwritten before next exception", 0ah, 0
_d

ALIGN FILEALIGN, db 0
