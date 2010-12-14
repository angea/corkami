; PE PoC
; file with null imagebase - and relocated by the OS

%include '..\..\onesec.hdr'

IMAGEBASE equ 0

EntryPoint:
    push MB_ICONINFORMATION ; UINT uType
;%reloc 1
    push tada               ; LPCTSTR lpCaption
;%reloc 1
    push helloworld         ; LPCTSTR lpText
    push 0                  ; HWND hWnd
    call MessageBoxA
    push 0                  ; UINT uExitCode
    call ExitProcess
;%reloc 2
;%IMPORT user32.dll!MessageBoxA
;%reloc 2
;%IMPORT kernel32.dll!ExitProcess
;%relocs
tada db "Tada!", 0
helloworld db "Hello World!", 0

;%IMPORTS

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE

;Ange Albertini, Creative Commons BY, 2009-2010
