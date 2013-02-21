;encrypted strings

%include '..\..\onesec.hdr'

EntryPoint:
    push MB_ICONINFORMATION ; UINT uType

    push tada               ; LPCTSTR lpCaption
    push 0adh
    call decrypt

    push helloworld         ; LPCTSTR lpText
    push 21h
    call decrypt

    push 0                  ; HWND hWnd
    call MessageBoxA
    push 0                  ; UINT uExitCode
    call ExitProcess

decrypt:
    mov cl, [esp + 4]
    mov esi, [esp + 8]
    mov edi, esi
decloop:
    lodsb
    xor al, cl
    stosb
    cmp al, 0
    jnz decloop
    retn 4

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess

tada db 0f9h, 0cch, 0c9h, 0cch, 08ch, 0adh
helloworld db 069h, 044h, 04dh, 04dh, 04eh, 01h, 076h, 04eh, 053h, 04dh, 045h, 021h

;%IMPORTS

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE

;Ange Albertini, Creative Commons BY, 2009-2010
