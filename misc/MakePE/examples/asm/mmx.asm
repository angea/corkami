; simple fibonacci number calculator, in mmx

%include '../../onesec.hdr'
_46 dd 46
_0 dd 0
_1 dd 1
_m1 dd -1

EntryPoint:
    ; start of code to virtualize
    movd mm0, dword [_46]                   ; mov ecx, 046

    movd mm1, dword [_0]                    ; mov eax, 0
    movd mm2, dword [_1]                    ; mov ebx, 1
    movd mm4, dword [_m1]

_loop:
    movq mm3, mm2                           ;mov edx, ebx
    paddd mm3, mm1                          ;add edx, eax
    movq mm1, mm2                           ;mov eax, ebx
    movq mm2, mm3                           ;mov ebx, edx
    paddd mm0, mm4                          ;add ecx, -1

    movd ecx, mm0                           ;jnz _loop

    cmp ecx, 0
    jnz _loop
_exit:

    movd ecx, mm2                           ;mov ecx, ebx

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
