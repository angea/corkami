; some api may return after each call a value that has been incremented
; in a predictable way, so it's usable as an anti-emulator

;Ange Albertini, BSD Licence, 2009-2011

%include '..\..\onesec.hdr'

%macro myapi 0
    push 0
    push 0
    call GlobalAlloc
%endmacro

counter equ 10

EntryPoint:
    myapi
    mov [base], eax ; increment calculation

    myapi
    sub eax, [base]
    mov [increment], eax

    mov eax, [increment]
    mov ecx, counter + 1
    mul ecx
    add eax, [base]

    mov [limit], eax

    mov ebx, 0

_loop:
    inc ebx

    myapi
    cmp [limit], eax
    jnz _loop

    cmp ebx, counter        ; let's confirm the amount of iterationwas correct
    jnz bad

    jmp good

;%IMPORT kernel32.dll!GlobalAlloc

base dd 0
increment dd 0
limit dd 0

%include '../goodbad.inc'

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess

;%IMPORTS

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE
