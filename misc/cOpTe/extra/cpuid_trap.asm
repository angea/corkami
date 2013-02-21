;simple cpuid trap
;
; testing if running under a real CPU by using 2 instructions that are not implemented on the same CPU
;
; Ange Albertini, BSD Licence 2011
;TODO: console me

%include '../header.inc'

MEM_RESERVE        equ 2000h
MEM_TOP_DOWN       equ 100000h
MB_ICONINFORMATION equ 040h

BASE equ 00c100000h


EntryPoint:
    setSEH good
    mov ecx, good
    crc32 eax, ebx
    movbe eax, [ecx]
    jmp bad
good:
    push MB_ICONINFORMATION ; UINT uType
    push tada               ; LPCTSTR lpCaption
    push helloworld         ; LPCTSTR lpText
    push 0                  ; HWND hWnd
    call MessageBoxA
bad:
    push 0                  ; UINT uExitCode
    call ExitProcess
_c

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess
_c

tada db "correct", 0
helloworld db "real cpu found", 0
_d

;%IMPORTS

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE
SUBSYSTEM equ 2
