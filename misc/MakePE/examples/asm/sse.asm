; simple fibonacci number calculator, in sse

%include '../../onesec.hdr'
_46 dd 46
_0 dd 0
_1 dd 1
_m1 dd -1

EntryPoint:
    ; start of code to virtualize
    movd xmm0, dword [_46]                  ; mov ecx, 046

    movd xmm1, dword [_0]                   ; mov eax, 0
    movd xmm2, dword [_1]                   ; mov ebx, 1
    movd xmm4, dword [_m1]

_loop:
    movq xmm3, xmm2                         ;mov edx, ebx
    paddd xmm3, xmm1                        ;add edx, eax
    movq xmm1, xmm2                         ;mov eax, ebx
    movq xmm2, xmm3                         ;mov ebx, edx
    paddd xmm0, xmm4                        ;add ecx, -1

    movd ecx, xmm0                          ;jnz _loop

    cmp ecx, 0
    jnz _loop
_exit:

    movd ecx, xmm2                           ;mov ecx, ebx
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
