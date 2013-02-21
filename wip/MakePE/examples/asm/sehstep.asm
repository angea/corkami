; simple fibonacci number calculator
; where a SEH is used to jump from one instruction to the next

; Ange Albertini, BSD Licence 2012

%include '../../onesec.hdr'
STEPLENGTH equ 1 << 3
%macro __ 1
        times STEPLENGTH - %1 int3
%endmacro

handler:
    mov eax, [esp + exceptionHandler.pContext + 4]
    mov ebx, dword [eax + CONTEXT.regEip]

    and ebx, 0ffffffffh ^ (STEPLENGTH - 1)
    add ebx, STEPLENGTH

    mov dword [eax + CONTEXT.regEip], ebx
    mov eax, ExceptionContinueExecution
    retn

EntryPoint:
    setSEH handler

align STEPLENGTH, db 90h

start:
    mov ecx, 046
        __ 5
    mov eax, 0
        __ 5
    mov ebx, 1
        __ 5
_loop:
    mov edx, ebx
        __ 2
    add edx, eax
        __ 2
    mov eax, ebx
        __ 2
    mov ebx, edx
        __ 2
    add ecx, -1
        __ 3
    jnz _loop
        __ 2
    jmp end

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
