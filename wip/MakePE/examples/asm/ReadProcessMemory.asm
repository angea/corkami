;self-modify via ReadProcessMemory

%include '..\..\onesec.hdr'

EntryPoint:
    push 0              ; BytesRead
    push _end - _start ; size
    push _target   ; Buffer
    push _start     ; BaseAddress
    push -1         ; hProcess
    call ReadProcessMemory
_target:
    call ExitProcess
_start:
    push MB_ICONINFORMATION ; UINT uType
    push tada               ; LPCTSTR lpCaption
    push helloworld         ; LPCTSTR lpText
    push 0                  ; HWND hWnd
    call MessageBoxA
    push 0                  ; UINT uExitCode
    call ExitProcess

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess
;%IMPORT kernel32.dll!ReadProcessMemory
_end:


tada db "Tada!", 0
helloworld db "Hello World!", 0

;%IMPORTS

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE

;Ange Albertini, Creative Commons BY, 2010
