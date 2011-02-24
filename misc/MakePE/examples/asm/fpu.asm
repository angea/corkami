; simple fibonacci number calculator, in FPU
; taking advantage of the barrel to avoid transferring data

%include '../../onesec.hdr'
res dt 0
EntryPoint:
    mov ecx, 46
        ; version with counter in FPU, far less elegant
        ; loosing the auto-rotate ability of the barrel :(

        ;_46 dd 46

    finit
        ;    fild dword [_46]
    fldz
    fld1
    fwait

_loop:
    fld st1                                 ;    _3 = _2 + _1
    fadd st1                                ;    _2, _1 = _2, _3 combined
    ffree st2

        ;    ; decrease counter
        ;    fld1
        ;    fsubp st4
        ;    fnop
        
        ;    ; now needs to copy st3 in st2, ugly !
        ;    fld st3
        ;    ffree st4
        ;    fxch st3
        ;    ffree st0
        ;    fincstp

    dec ecx
    jnz _loop

_exit:
    fstp tword [res]
    mov ecx, [res + 4]
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
