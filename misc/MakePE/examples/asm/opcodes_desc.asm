%include '..\..\onesec.hdr'

%macro expect 2
    cmp %1, %2
    jnz bad
%endmacro

ValueEDI dd 0ED0h
ValueESI dd 0E01h
ValueEBP dd 0EEBE3141h     ; E B PI ;)
ValueESP dd 0               ; unused
ValueEBX dd 0EB1h
ValueEDX dd 0ED1h
ValueECX dd 0EC1h
ValueEAX dd 0EA1h
val dd ValueEDI

EntryPoint:

    xchg [val] , esp    ; makes a backup of ESP and temporarily change ESP to the start of the data
    popad               ; read all the data into registers
    mov esp, [val]       ; restore ESP and EAX

    mov ax, 0304h ; 34
    mov bx, 0307h ; 37
    add ax, bx
    aaa
    expect ax, 0701h ;34 + 37 = 71

    mov ax, 01234h ; 1234
    mov bx, 0537h  ; 537
    add ax, bx
    daa
    expect ax, 1771h ; 1234 + 537 = 1771

    mov ax, 0701h
    mov bx, 0304h
    sub ax, bx
    aas
;    expect ax, 0307h wrong

mov eax, 01771h         ; let's store a constant as BCD
mov ebx, 01234h
sub eax, ebx            ; we got the result wrong, so we'll use AAA
das                     ; now eax has the right result
expect eax, 537h

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

    mov ax, 1111b
    mov bx, 0100000000000000b
    shld ax, bx, 3
    expect ax, 1111010b

    mov ax, 1101001b
    mov bx, 101b
    shrd ax, bx, 3
    expect ax, 1010000000001101b

    mov ax, 35
    mov bl, 11
    div bl          ; 35 = 3 * 11 + 2
    expect al, 3    ; quo
    expect ah, 2    ; rem

    mov al, 11
    mov bl, 3
    mul bl
    expect ax, 33

    mov eax, 11
    imul eax, eax, 3
    expect eax, 33

    push ds

    mov ebx, addseg
    lds eax, [ebx]
    expect eax , 12345678h
    push ds
    pop eax
    expect eax, 0

    pop ds

    stc
    setc al
    expect al, 1

    clc
    mov eax, 0
    mov ebx, 3
    cmovc eax, ebx
    expect eax, 0

    jmp good

align 4, db 0
addseg:
    dd 12345678h
    dw 00h         ; standard value for DS

align 4, db 0

%include '..\goodbad.inc'

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess

tada db "Tada!", 0
helloworld db "Hello World!", 0

;%IMPORTS

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE

;Ange Albertini, Creative Commons BY, 2009-2010
