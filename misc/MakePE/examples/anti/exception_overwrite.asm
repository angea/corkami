%include '..\..\standard_hdr.asm'

EntryPoint:
    setSEH handler
    int3
    jmp bad
handler:
    mov dword [esp + 18h], good             ; overwriting the higher level handler

; then pretending everything is fine (actually not needed here)

    mov eax, [esp + exceptionHandler.pContext + 4]
    mov dword [eax + CONTEXT.regEip], bad
    mov eax, ExceptionContinueExecution
; until we reach another trigger that just calls the overwritten handler
    int3

    retn

%include '..\goodbad.inc'

;%IMPORT kernel32.dll!ExitProcess
;%IMPORT user32.dll!MessageBoxA

;%IMPORTS

%include '..\..\standard_ftr.asm'

;Ange Albertini, Creative Commons BY, 2009-2010
