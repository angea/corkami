; simple fibonacci number calculator
; with a non-linear IP, and SEH to jump from one opcode to the other

; Ange Albertini, BSD Licence 2012

%include '../../onesec.hdr'

STEPLENGTH equ 1 << 3
%macro __ 1
        times STEPLENGTH - %1 int3
%endmacro

_pos db  6, 7, 4, 2, 1, -1, 3, 9, 5, 8

handler:
    mov eax, [esp + exceptionHandler.pContext + 4]
    mov ebx, dword [eax + CONTEXT.regEip]
    sub ebx, start
    and ebx, 0ffffffffh ^ (STEPLENGTH - 1)

    shr ebx, 3
    mov ecx, _pos
    movzx ebx, byte [ecx + ebx]

    shl ebx, 3
    add ebx, start
    mov dword [eax + CONTEXT.regEip], ebx
    mov eax, ExceptionContinueExecution
    retn

EntryPoint:
    setSEH handler

align STEPLENGTH, db 90h

start:
;0
    mov ecx, 046
        __ 5

;5
    mov eax, ebx
        __ 2

;3
_loop:
    mov edx, ebx
        __ 2

;2
    mov ebx, 1
        __ 5

;4
    add edx, eax
        __ 2

;9
    jmp end
        __ 2

;1
    mov eax, 0
        __ 5

;6
    mov ebx, edx
        __ 2

;8
    jnz _loop
        __ 2

;7
    add ecx, -1
        __ 3

end:
    mov ecx, ebx
    cmp ecx, 2971215073 ; 46th fibonacci number
    jnz bad

    jmp good

%include '..\goodbad.inc'

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess

;%IMPORTS

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE
