;small code using each opcode

%include '..\..\onesec.hdr'

%macro expect 2
    cmp %1, %2
    jnz bad
%endmacro

ValueEDI dd 0ED0h
ValueESI dd 0E01h
ValueEBP dd 0EEBE3141h     ; E B PI ;)
ValueESP dd 0              ; unused
ValueEBX dd 0EB1h
ValueEDX dd 0ED1h
ValueECX dd 0EC1h
ValueEAX dd 0EA1h
val dd ValueEDI
ud1
ud2
hlt
db 0f1h
EntryPoint:
    mov eax, 3
    expect eax, 3

    mov al, -1
    movzx ecx, al
    expect ecx, 0ffh

    mov al, -3
    movsx ecx, al
    expect ecx, -3

    mov eax, 3
    lea eax, [eax * 4 + 203Ah]
    expect eax, 203ah + 4 * 3

    mov al, 1
    mov bl, 2
    xchg al, bl
    expect al, 2
    expect bl, 1

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

    mov al, 01h
    mov bl, 04h
    sub al, bl
    aas
    expect al, 11 - 4

    mov eax, 01771h
    mov ebx, 01234h
    sub eax, ebx
    das
    expect eax, 537h

    mov ax, 305h
    aad
    expect ax, 35

    mov ax, 35
    aam
    expect ax, 305h

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

    mov eax, 0010100b
    bsf ebx, eax
    expect ebx, 2

    mov ax, 00100b
    mov bx, 2
    bt ax,bx
    jnc bad

    mov eax, 12345678h
    bswap eax
    expect eax, 78563412h

    mov eax, -1
    mov al, 3
    cbw
    expect ax, 3
    cwde
    expect eax, 3
    cwd
    expect dx, 0

    mov eax, 136
    mov ebx, boundslimit
    bound eax, [ebx]

    stc
    salc
    expect al, -1

    ; compares lower 2 bits and copy if inferior
    CONST equ 1111111111111100b
    mov ax, CONST + 00b
    mov bx, CONST + 11b
    arpl ax, bx
    jnz bad             ; ZF should be set too
    expect ax, CONST + 11b

    mov ecx, -1
    db 66h      ; just increasing cx instead of ecx
    inc ecx
    expect ecx, 0ffff0000h

    db 67h      ; just checking cx instead of ecx
    jecxz _cx0
    jmp bad
_cx0:

    mov al, 35
    mov ebx, xlattable
    xlatb
    expect al, 75

    push cs
    pop ecx
    lar eax, ecx
    expect eax, 0cffb00h

    push cs
    pop ecx
    verr cx
    jnz bad

    mov al, 3
    mov bl, 6
    cmpxchg bl, cl
    expect al, bl

    mov al, 3
    mov bl, al
    cmpxchg bl, cl
    expect bl, cl

    rdtsc
    mov ebx, eax
    mov ecx, edx
    rdtsc
    cmp eax, ebx
    jle bad
    expect edx, ecx

    sldt eax
    expect eax, 0

    mov eax, dummy
    sidt [eax]
    expect word [eax],  007ffh

    mov eax, dummy
    sgdt [eax]
    expect word [eax],  003ffh

    mov eax, 0
    cpuid
    test eax, eax
    jz bad

    ; nops
    sfence
    mfence
    lfence
    prefetchnta [eax]   ; no matter the eax value
    db 0fh, 019h, 00    ; hint nop [eax]
    db 0fh, 01fh, 00    ; nop [eax]

    push cs
    pop ecx
    lsl eax, ecx
    jnz bad
    expect eax, -1

    str ax
    expect ax, 28h

    mov eax, 0
    push _return
    mov edx, esp
    sysenter
_return:
    expect eax, ACCESS_VIOLATION            ; depends on initial EAX
    lea eax, [esp - 4]
    expect ecx, eax                             ; 1 if stepping
    mov al, [edx]
    expect al, 0c3h
    expect edx, [__imp__KiFastSystemCallRet]    ; -1 if stepping

    jmp good

align 4, db 0
;%IMPORT ntdll.dll!KiFastSystemCallRet
xlattable:
times 35 db 0
db 75

    dd 1
boundslimit:
    dd 135
    dd 143
addseg:
    dd 12345678h
    dw 00h         ; standard value for DS

align 4, db 0

%include '..\goodbad.inc'

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess

dummy dd 0,0

tada db "Tada!", 0
helloworld db "Hello World!", 0

;%IMPORTS

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE

;Ange Albertini, Creative Commons BY, 2009-2010
