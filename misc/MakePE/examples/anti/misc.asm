; misc anti debuggers

%include '..\..\standard_hdr.asm'


EntryPoint:
    call deletefib
    call trig
    jmp good

; DeleteFiber
; triggers a BREAKPOINT exception if debugger present, else just an ERROR INVALID PARAMETER
; (ForceFlag check)

ERROR_INVALID_PARAMETER equ 00000057h

deletefib:
    push EntryPoint     ; LPVOID lpFiber
    call DeleteFiber

    call GetLastError
    cmp eax, ERROR_INVALID_PARAMETER
    jnz bad
    retn
;%IMPORT kernel32.dll!GetLastError
;%IMPORT kernel32.dll!DeleteFiber

trig:
    push 0
    call _CIasin
    add esp, 4
    cmp al, 98H     ; a8h if debugger present
    jnz bad
    retn
;%IMPORT msvcrt.dll!_CIasin

%include '..\goodbad.inc'

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess
;%IMPORTS

%include '..\..\standard_ftr.asm'

; Ange Albertini, Creative Commons BY, 2009-2010
