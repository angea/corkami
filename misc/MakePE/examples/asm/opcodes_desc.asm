%include '..\..\onesec.hdr'

%macro expect 2
    cmp %1, %2
    jnz bad
%endmacro

EntryPoint:
    mov eax, 3
    lea eax, [eax * 4 + 203Ah]
    expect eax, 203ah + 4 * 3

    mov eax, 3
    add eax, 3
    expect eax, 6

    stc
    mov eax, 3
    adc eax, 3
    expect eax, 3 + 3 + 1

    mov eax, 6
    sub eax, 3
    expect eax, 6 - 3

    stc
    mov eax, 6
    sbb eax, 3
    expect eax, 6 - 3 - 1

    mov eax, 0
    inc eax
    expect eax, 0 + 1

    mov eax, 7
    dec eax
    expect eax, 7 - 1

    mov eax, 1010b
    or eax, 0110b
    expect eax , 1110b

    mov eax, 1010b
    and eax, 0110b
    expect eax, 0010b

    mov eax, 1010b
    xor eax, 0110b
    expect eax, 1100b

    mov al, 1010b
    not al
    expect al, 11110101b

    mov eax, 1010b
    rol eax, 3
    expect eax, 1010000b

    mov al, 1010b
    ror al, 3
    expect al, 01000001b

    stc
    mov al, 1010b
    rcl al, 3
    expect eax, 1010100b

    stc
    mov al, 1010b
    rcr al, 3
    expect al, 10100001b

    mov al, 1010b
    shl al, 2
    expect al, 101000b

    mov al, 1010b
    shr al, 2
    expect al, 10b

    mov al, -8
    sar al, 2
    expect al, -2

    jmp good

%include '..\goodbad.inc'

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess

tada db "Tada!", 0
helloworld db "Hello World!", 0

;%IMPORTS

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE

;Ange Albertini, Creative Commons BY, 2009-2010
