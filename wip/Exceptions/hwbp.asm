; trigger an exception, set hardware breakpoint
; go on execution the 'wrong' way, which triggers an exception, and goes back the right way

;Ange Albertini, BSD Licence, 2009-2012

%include 'head.inc'

EXCEPTION_MAXIMUM_PARAMETERS equ 15

struc EXCEPTION_RECORD
    .ExceptionCode         resd 1
    .ExceptionFlags        resd 1
    .pExceptionRecord      resd 1
    .ExceptionAddress      resd 1
    .NumberParameters      resd 1
    .ExceptionInformation  resd EXCEPTION_MAXIMUM_PARAMETERS
endstruc

EntryPoint:
    setSEH handler
trigger:
    int3
_resume:
    ; we could do a lot here and let the user+debugger forget about the hardware breakpoint we set.
    jmp bad
_c
handler:
    ; where did the exception occur ?
    mov edx, [esp + exceptionHandler.pContext + 4]
    cmp dword [edx + CONTEXT.regEip], bad
    jnz first_time

    ; second time, let's check that we had a SINGLE STEP exception
    mov edx, [esp + exceptionHandler.pException + 4]
    cmp dword [edx + EXCEPTION_RECORD.ExceptionCode], SINGLE_STEP
    jz good
    jmp bad
_c

first_time:
    ; let's set an execution hardware breakpoint
    mov dword [edx + CONTEXT.iDr0], bad        ; DR0 to the address of trigger
    mov dword [edx + CONTEXT.iDr7], 000000001h ; DR7 to 1 to activate the execution breakpoint
    ; skip the int3 and return correctly
    add dword [edx + CONTEXT.regEip], _resume - trigger

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

Msg db " * define and use hardware breakpoint via SEH", 0ah, 0
_d

counter db 0

ALIGN FILEALIGN, db 0
