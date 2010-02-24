; extreme case of overlapping instructions junk code.
; makes a funny block of IMUL instructions

%include '../onesec.hdr'

%macro before 0
    %push junk
    jmp %$after
    db 069h, 84h    ; imul ...
%$after:
%endmacro

%macro after 0
    ; pad with enough nops
    times (%$after + 7) - $ db 090h
    %pop
%endmacro

EntryPoint:

before
    push MB_ICONINFORMATION ; UINT uType
    push tada               ; LPCTSTR lpCaption
after

before
    push helloworld         ; LPCTSTR lpText
after

before
    push 0                  ; HWND hWnd
    call MessageBoxA
after

before
    push 0                  ; UINT uExitCode
    call ExitProcess
after

tada db "Tada!", 0
helloworld db "Hello World!", 0

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess

;%IMPORTS

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE

;Ange Albertini, Creative Commons BY, 2009-2010
