%include '..\..\standard_hdr.asm'

EntryPoint:
    setSEH handler
trigger:
    int3
_resume:
    ; we could do a lot here and let the user+debugger forget about the hardware breakpoint we set.
    jmp bad

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

first_time:
    ; let's set an execution hardware breakpoint
    mov dword [edx + CONTEXT.iDr0], bad        ; DR0 to the address of trigger
    mov dword [edx + CONTEXT.iDr7], 000000001h ; DR7 to 1 to activate the execution breakpoint
    ; skip the int3 and return correctly
    add dword [edx + CONTEXT.regEip], _resume - trigger

    mov eax, ExceptionContinueExecution
    retn

counter db 0

%include '..\goodbad.inc'

;%IMPORT kernel32.dll!ExitProcess
;%IMPORT user32.dll!MessageBoxA

;%IMPORTS

%include '..\..\standard_ftr.asm'

;Ange Albertini, Creative Commons BY, 2009-2010
