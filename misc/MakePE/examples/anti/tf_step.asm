; an exception handler sets the Trap Flag, to manually step trough the original code

;Ange Albertini, BSD Licence, 2009-2011

%include '..\..\standard_hdr.asm'

COUNT equ 4

EntryPoint:
    setSEH handler
    IceBP

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

counter db 0

%include '..\goodbad.inc'

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess

;%IMPORTS

%include '..\..\standard_ftr.asm'
