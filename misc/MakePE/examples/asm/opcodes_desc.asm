;a file making use of each user mode opcode (at least, one of each family)

; FPU/SSE+ are not included
; Jumps specific opcodes are in Jumps.
; opcodes doing 'nothing visible are in Nops.asm
; opcodes triggering exceptions are in seh_triggers.asm

; the classic: mov movzx movsx lea xchg inc dec or and xor not rol ror rcl rcr shl shr add adc sub sbb div mul imul
; the not so classic: aaa daa aas das aad aam xadd sar enter leave bsf btX bswap cbw cwde cwd rdtsc setXX salc cmovXX shld shrd
; the rares: lds bound xlatb cmpxchg cmpxchg8b cpuid lsl popcnt movbe crc32 arpl lar verr sldt sidt sgdt str

; the OS dependant checks will fail under a VmWare

; removeKiFastSystemCallRet reference under XP SP<3

; Ange Albertini, BSD Licence, 2009-2011

%include '..\..\onesec.hdr'

%macro expect 2
    cmp %1, %2
    jnz bad
%endmacro

EntryPoint:
    mov eax, 3
    expect eax, 3
_
    mov al, -1
    movzx ecx, al
    expect ecx, 0ffh
_
    mov al, -3
    movsx ecx, al
    expect ecx, -3
_
    mov eax, 3
    lea eax, [eax * 8 + eax + 203Ah]
    expect eax, 203ah + 8 * 3 + 3
_
    mov al, 1
    mov bl, 2
    xchg al, bl
    expect al, 2
    expect bl, 1
_
    xchg [xchgpopad] , esp                  ; makes a backup of ESP and temporarily change ESP to the start of the data
    popad                                   ; read all the data into registers
    mov esp, [xchgpopad]                    ; restore ESP and EAX
_
    mov ax, 0304h                           ; 34
    mov bx, 0307h                           ; 37
    add ax, bx
    aaa
    expect ax, 0701h                        ;34 + 37 = 71
_
    mov ax, 01234h                          ; 1234
    mov bx, 0537h                           ; 537
    add ax, bx
    daa
    expect ax, 1771h                        ; 1234 + 537 = 1771
_
    mov al, 01h
    mov bl, 04h
    sub al, bl
    aas
    expect al, 11 - 4
_
    mov eax, 01771h
    mov ebx, 01234h
    sub eax, ebx
    das
    expect eax, 537h                        ; 1771 - 1234 = 537
_
    mov ax, 305h
    aad
    expect ax, 35
_
    mov ax, 35
    aam
    expect ax, 305h
_
    mov eax, 3
    add eax, 3
    expect eax, 6
_
    mov al, 1
    mov bl, 2
    xadd al, bl
    expect al, 1 + 2
    expect bl, 1
_
    stc
    mov eax, 3
    adc eax, 3
    expect eax, 3 + 3 + 1
_
    mov eax, 6
    sub eax, 3
    expect eax, 6 - 3
_
    stc
    mov eax, 6
    sbb eax, 3
    expect eax, 6 - 3 - 1
_
    mov eax, 0
    inc eax
    expect eax, 0 + 1
_
    mov eax, 7
    dec eax
    expect eax, 7 - 1
_
    mov eax, 1010b
    or eax, 0110b
    expect eax , 1110b
_
    mov eax, 1010b
    and eax, 0110b
    expect eax, 0010b
_
    mov eax, 1010b
    xor eax, 0110b
    expect eax, 1100b
_
    mov al, 1010b
    not al
    expect al, 11110101b
_
    mov eax, 1010b
    rol eax, 3
    expect eax, 1010000b
_
    mov al, 1010b
    ror al, 3
    expect al, 01000001b
_
    stc
    mov al, 1010b
    rcl al, 3
    expect eax, 1010100b
_
    stc
    mov al, 1010b
    rcr al, 3
    expect al, 10100001b
_
    mov al, 1010b
    shl al, 2
    expect al, 101000b
_
    mov al, 1010b
    shr al, 2
    expect al, 10b
_
    mov al, -8
    sar al, 2
    expect al, -2
_
    mov ax, 1111b
    mov bx, 0100000000000000b
    shld ax, bx, 3
    expect ax, 1111010b
_
    mov ax, 1101001b
    mov bx, 101b
    shrd ax, bx, 3
    expect ax, 1010000000001101b
_
    mov ax, 35
    mov bl, 11
    div bl                                  ; 35 = 3 * 11 + 2
    expect al, 3                            ; quo
    expect ah, 2                            ; rem
_
    mov al, 11
    mov bl, 3
    mul bl
    expect ax, 3 * 11
_
    mov eax, 11
    imul eax, eax, 3
    expect eax, 3 * 11
_
    push ds
    mov ebx, addseg                         ; [addseg] = 00:12345678
    lds eax, [ebx]
    expect eax , 12345678h
    push ds
    pop eax
    expect eax, 0
    pop ds
_
    push 3
    enter 8, 0
    enter 4, 1
    leave
    leave
    pop eax
    expect eax, 3
_
    stc
    setc al
    expect al, 1
    clc
    setc al
    expect al, 0
_
    stc
    salc
    expect al, -1
    clc
    salc
    expect al, 0
_
    rdtsc
    mov ecx, eax
    clc
    mov ebx, 3
    cmovc eax, ebx
    expect eax, ecx
    stc
    cmovc eax, ebx
    expect eax, 3
_
    mov eax, 0010100b
    bsf ebx, eax                            ; bit scan forward
    expect ebx, 2
_
    mov ax, 00100b
    mov bx, 2
    bt ax,bx                                ; bit test
    jnc bad
_
    mov eax, 12345678h
    bswap eax
    expect eax, 78563412h
_
    mov eax, -1
    mov al, 3
    cbw
    expect ax, 3
    cwde
    expect eax, 3
    cwd
    expect dx, 0
_
    mov eax, 136
    mov ebx, boundslimit                    ; boundslimit = [135, 143]
    bound eax, [ebx]
    ; no exception happens if within bounds
_
    ; compares lower 2 bits and copy if inferior
    CONST equ 1111111111111100b
    mov ax, CONST
    mov bx, 1010100111b
    arpl ax, bx
    jnz bad                                 ; ZF should be set too
    expect ax, CONST + 11b
_
    mov ecx, -1
    db 66h                                  ; just increasing cx instead of ecx
    inc ecx
    expect ecx, 0ffff0000h
_
    db 67h                                  ; just checking cx instead of ecx
    jecxz _cx0
    jmp bad
_cx0:

    mov al, 35
    mov ebx, xlattable                      ; xlattable[35] = 75
    xlatb
    expect al, 75
_
    push cs
    pop ecx
    lar eax, ecx
    expect eax, 0cffb00h
_
    push cs
    pop ecx
    verr cx
    jnz bad
_
    mov al, 3
    mov bl, 6
    cmpxchg bl, cl
    expect al, bl
_
    mov al, 3
    mov bl, al
    cmpxchg bl, cl
    expect bl, cl
_
    mov eax, 00a0a0a0ah
    mov edx, 0d0d0d0d0h
    mov ecx, 99aabbcch
    mov ebx, 0ddeeff00h
    cmpxchg8b [_cmpxchg8b]                 ; [_cmpxchg8b] = 0d0d0d0d0:00a0a0a0a
    expect [_cmpxchg8b], ebx
    expect [_cmpxchg8b + 4], ecx
_
    rdtsc
    mov ebx, eax
    mov ecx, edx
    rdtsc
    cmp eax, ebx
    jle bad
    expect edx, ecx
_
    sldt eax
    expect eax, 0
_
    mov eax, 0
    cpuid
    test eax, eax
    jz bad
_
    push cs
    pop ecx
    lsl eax, ecx
    jnz bad
    expect eax, -1
_
    mov eax, 1
    cpuid
    and ecx, 1 << 23
    jz no_popcnt

    mov ebx, 0100101010010b
    popcnt eax, ebx
    expect eax, 5
no_popcnt:
_
    mov eax, 1
    cpuid
    and ecx, 1 << 22
    jz no_movbe

    mov ebx, _movbe                         ; [_movbe] = 11223344h
    movbe eax, [ebx]
    expect eax, 44332211h
no_movbe:
_
    mov eax, 1
    cpuid
    and ecx, 1 << 20
    jz no_crc32

    mov eax, 0
    mov ebx, crc32_
    crc32 eax, [ebx]
    expect eax, 0fa745634h
no_crc32:
_
    jmp [os]
_c

XP_tests:
    mov eax, dummy
    sidt [eax]
    expect word [eax], 007ffh
_
    mov eax, dummy
    sgdt [eax]
    expect word [eax], 003ffh
_
    str ax
    expect ax, 28h
_
    mov eax, 0
    push _return
    mov edx, esp
    sysenter
_c

_return:
    expect eax, ACCESS_VIOLATION            ; depends on initial EAX
    lea eax, [esp - 4]
    expect ecx, eax                         ; 1 if stepping
    mov al, [edx]
    expect al, 0c3h
    expect edx, [__imp__KiFastSystemCallRet]; -1 if stepping
    jmp good
_c

;%IMPORT ntdll.dll!KiFastSystemCallRet
_c

W7_tests:
    mov eax, dummy
    sidt [eax]
    expect word [eax], 0fffh
_
    mov eax, dummy
    sgdt [eax]
    expect word [eax], 07fh
_
    str ax
    expect ax, 40h
    jmp good
_c
xlattable:
times 35 db 0
         db 75

boundslimit:
    dd 135
    dd 143
_d

crc32_:
    dd 12345678h
_d
_cmpxchg8b:
    dd 00a0a0a0ah
    dd 0d0d0d0d0h
_d

addseg:
    dd 12345678h
    dw 00h
_d

_movbe dd 11223344h
_d

%include '..\goodbad.inc'
_c

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess
_c
TLS:
    mov eax, [fs:18h]
    mov ecx, [eax + 030h]
    xor eax, eax
    or eax, [ecx + 0a8h]
    shl eax,8
    or eax, [ecx + 0a4h]
    cmp eax, 0106h
    jz W7
    retn
W7:
    mov dword [os], W7_tests
    retn
_c

Image_Tls_Directory32:
    StartAddressOfRawData dd Characteristics
    EndAddressOfRawData   dd Characteristics
    AddressOfIndex        dd Characteristics
    AddressOfCallBacks    dd SizeOfZeroFill
    SizeOfZeroFill        dd TLS
    Characteristics       dd 0
_d

ValueEDI dd 0ED0h
ValueESI dd 0E01h
ValueEBP dd 0EEBE3141h                      ; E B PI ;)
ValueESP dd 0                               ; unused
ValueEBX dd 0EB1h
ValueEDX dd 0ED1h
ValueECX dd 0EC1h
ValueEAX dd 0EA1h
xchgpopad dd ValueEDI
_d

dummy dd 0,0
os dd XP_tests
_d

;%IMPORTS
_d

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE
