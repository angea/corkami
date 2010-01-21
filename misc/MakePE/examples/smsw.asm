%include '..\standard_hdr.asm'

EntryPoint:
    smsw eax
    cmp ax, 03bh
    jnz bad

    fnop
    smsw eax
    cmp ax, 031h   ; 03bh if debugged or
    jnz bad

_1:
    smsw eax
    cmp ax, 031h
    jz _1

    jmp good

bad:
    push MB_ICONERROR   ; UINT uType
    push error          ; LPCTSTR lpCaption
    push errormsg       ; LPCTSTR lpText
    push 0              ; HWND hWnd
    call MessageBoxA
    push 042h
    call ExitProcess    ; UINT uExitCode
good:
    push MB_ICONINFORMATION ; UINT uType
    push success            ; LPCTSTR lpCaption
    push successmsg         ; LPCTSTR lpText
    push 0                  ; HWND hWnd
    call MessageBoxA
    push 0
    call ExitProcess        ; UINT uExitCode

error db "Bad", 0
errormsg db "Something went wrong...", 0
success db "Good", 0
successmsg db "Expected behaviour occured...", 0

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess

;%IMPORTS

%include '..\standard_ftr.asm'

;Ange Albertini 2009-2010
