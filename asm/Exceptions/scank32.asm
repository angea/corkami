;the exception handler overwrites the top handler, then trigger another exception.

;Ange Albertini, BSD Licence, 2009-2012

%include 'head.inc'

EntryPoint:
    setSEH handler
    mov eax, 011000000h
loop_:
    sub eax, 10000h
    cmp word [eax], 'MZ'
    jz good
    jmp loop_
_c

handler:
    mov eax, [esp + exceptionHandler.pContext + 4]
    add dword [eax + CONTEXT.regEip], 5
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

Msg db " * memory range scanner with SEH", 0ah, 0
_d

ALIGN FILEALIGN, db 0
