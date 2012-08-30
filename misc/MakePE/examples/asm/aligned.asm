; simple fibonacci number calculator in x86, where opcodes are aligned
; Ange Albertini, BSD Licence 2012

%include '../../onesec.hdr'

STEPLENGTH equ 1 << 3

%macro __ 1
        times STEPLENGTH - %1 nop
%endmacro

EntryPoint:

align STEPLENGTH, db 90h

start:
;0
    mov ecx, 046
        __ 5

;1
    mov eax, 0
        __ 5

;2
    mov ebx, 1
        __ 5

;3
_loop:
    mov edx, ebx
        __ 2

;4
    add edx, eax
        __ 2

;5
    mov eax, ebx
        __ 2
        
;6
    mov ebx, edx
        __ 2
;7
    add ecx, -1
        __ 3
;8
    jnz _loop
        __ 2
;9
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
