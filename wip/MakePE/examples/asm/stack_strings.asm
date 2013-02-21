; strings build on the stack

%include '..\..\standard_hdr.asm'

EntryPoint:
    push "!"    ; zero-terminator will be pushed for us
    push "Tada" ; yasm pushes string 'backward'

    push 0
    push "rld!"
    push "o Wo"
    push "Hell"

    push MB_ICONINFORMATION  ; UINT uType
    push esp                 ; LPCTSTR lpCaption
    push esp                 ; LPCTSTR lpText
    push 0                   ; HWND hWnd

    add dword [esp+8], 5 * 4
    add dword [esp+4], 2 * 4
    call MessageBoxA

    ; let's restore the stack - 2 dwords for tada, 4 for hello world
    add esp, 4 * 6

    push 0                  ; UINT uExitCode
    call ExitProcess

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess

;%IMPORTS

%include '..\..\standard_ftr.asm'

; Ange Albertini, Creative Commons BY, 2010
