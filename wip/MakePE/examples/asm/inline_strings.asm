%include '..\..\standard_hdr.asm'

EntryPoint:
    push MB_ICONINFORMATION ; UINT uType

    call over_tada          ; LPCTSTR lpCaption
    db "Tada!", 0
over_tada:

    call over_helloworld    ; LPCTSTR lpText
    db "Hello World!", 0
over_helloworld:

    push 0                  ; HWND hWnd
    call MessageBoxA

    push 0                  ; UINT uExitCode
    call ExitProcess

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess

;%IMPORTS

%include '..\..\standard_ftr.asm'

; Ange Albertini, Creative Commons BY, 2010
