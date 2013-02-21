; minimalist thread host, 'waiting' for thread injection

%include '..\..\standard_hdr.asm'

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess

EntryPoint:
    push 1000000h       ; dwMilliseconds
    call Sleep
    push 0              ; uExitCode
    Call ExitProcess

;%IMPORT kernel32.dll!Sleep

SIZEOFCODE equ $ - base_of_code

;%IMPORTS

base_of_data equ IMAGEBASE
SIZEOFINITIALIZEDDATA equ 0

uninit_data equ IMAGEBASE
SIZEOFUNINITIALIZEDDATA equ 0

Section0Size EQU $ - Section0Start

SIZEOFIMAGE EQU $ - IMAGEBASE

; Ange Albertini, Creative Commons BY, 2010