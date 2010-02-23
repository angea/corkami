; simple fibonacci number calculator, used as base for various virtualization exercices

%include '../../onesec.hdr'

EntryPoint:
    ; start of code to virtualize
    mov ecx, 046

    mov eax, 0
    mov ebx, 1
_loop:
    mov edx, ebx
    add edx, eax
    mov eax, ebx
    mov ebx, edx
    add ecx, -1
    jnz _loop
    mov ecx, ebx
; end of code to virtualize
    cmp ecx, 2971215073 ; 46th fibonacci number
    jnz bad

    jmp good

%include '..\goodbad.inc'

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess

;%IMPORTS

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE

; Ange Albertini, Creative Commons BY, 2009-2010
