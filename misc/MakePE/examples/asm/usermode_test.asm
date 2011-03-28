
; this a file making use of each usermode opcode (at least, one of each family)

; general FPU/SSE+ opcodes are not included

; the OS dependent checks will fail under a VmWare

; remove KiFastSystemCallRet references to run under XP SP<3

;TODO: gather code and data together, tests that are not just expects - add exception handler

; Ange Albertini, BSD Licence, 2009-2011

%include '..\..\onesec.hdr'

_CS equ 01bh ; cs is 01bh on Windows XP usermode, will fail if different
SUBSYSTEM equ IMAGE_SUBSYSTEM_WINDOWS_CUI

STD_OUTPUT_HANDLE equ -11

%macro expect 2
    cmp %1, %2
    jz %%good
    call errormsg_
%%good:
%endmacro

print:
    pushad
    mov edi, [esp + 24h]
    mov esi, edi
    xor al, al
    cld
    push -1
    pop ecx
    repnz scasb
    not ecx
    sub edi, ecx
    dec ecx

    push 0                          ; LPVOID lpReserved
    push lpNumbersOfCharsWritten    ; LPWORD lpNumbersOfCharsWritten
    push ecx ; HELLOWORLD_LEN             ; DWORD nNumbersOfCharsToWrite
    push edi ;helloworld                 ; VOID *lpBuffer
    push dword [hConsoleOutput]     ; HANDLE hConsoleOutput
    call WriteConsoleA
    popad
    retn 4
_c

;%IMPORT kernel32.dll!WriteConsoleA
_c

lpNumbersOfCharsWritten dd 0
_d

%macro print_ 1+
    call %%next
    db %1
    db 0dh, 0ah, 0
%%next:
    call print
%endmacro

%macro setmsg_ 1+
    call %%next
    db %1
    db 0dh, 0ah, 0
%%next:
    pop dword [ErrorMsg]
_
%endmacro

errormsg_:
    push dword [ErrorMsg]
    call print
    retn
_c

ErrorMsg dd 0
_d

start:
    push STD_OUTPUT_HANDLE  ; DWORD nStdHandle
    call GetStdHandle
    mov [hConsoleOutput], eax

    print_ 'Opcode tester - 2011/03/28'
    print_ 'Ange Albertini, BSD Licence, 2009-2011 - http://corkami.com', 0dh, 0ah
    retn
_c
;%IMPORT kernel32.dll!GetStdHandle
_c
hConsoleOutput dd 0
_d

EntryPoint:
    call start
    call TLS    ; only Kernel32 is imported, so we have to call our TLS manually

    ; jump short, near, far, ret near, ret far, interrupt ret
    call jumps

    ; mov movzx movsx lea xchg add sub sbb adc inc dec or and xor
    ; not neg rol ror rcl rcr shl shr sal shld shrd div mul imul enter leave
    ; setXX cmovXX bsf bsr bt bswap cbw cwde cwd
    call classics

    ; xadd aaa daa aas das aad aam lds bound arpl jcxz xlatb lar
    ; verr cmpxchg cmpxchg8b sldt lsl
    call rares

    call undocumented ; aam xx, salc, aad xx, bswap reg16, smsw reg32

    call cpu_specifics  ; popcnt movbe crc32

    call encodings      ; test, 'sal'

    ; os should be before any fpu use
    call [os]

    ; nop pause sfence mfence lfence prefetchnta 'hint nop', into
    call nops

    ; gs, smsw, rdtsc, pushf, pop ss
    call antis

    call get_ips ; call, call far, fstenv

    ; documented but frequent disassembly mistakes
    ; smsw str hints word calls/rets
    call disassembly
    jmp good
_c

jumps:
_retword:
    mov ecx, bad
    and ecx, 0ffffh
    ; mov word [ecx - 2], 9090h          ; a little pre-padding for the call word trick ; not needed as 0000 is a nop here...
    mov byte [ecx], 68h
    mov dword [ecx + 1], _callword
    mov byte [ecx + 5], 0c3h
    push bad
    db 66h
        retn
_c

_callword:
    sub esp, 2
    mov dword [ecx + 1], _jumpword
    db 66h
    call bad
_c

_jumpword:
    add esp, 2 + 4
    mov dword [ecx + 1], _jumps
    db 66h
    jmp bad
_c

_jumps:
    jmp short _jmp1     ; short jump, relative, EB
_c

_jmp1:
    jmp near _jmpreg32  ; jump, relative, E9
_c

_jmpreg32:                ; jump via register
    mov eax, _jmpreg16
    jmp eax

_jmpreg16:
    mov dword [ecx + 1], _jmp3
    db 67h
        jmp ecx
_c

_jmp3:
    jmp dword [buffer1]
    buffer1 dd _jmp4
_c

    ; far jump, absolute
_jmp4:
                        ; jmp far is encoded as EA <ddOffset> <dwSegment>
;    mov [_patchCS + 5], cs
_patchCS:
    jmp _CS:_jmp5
_c

_jmp5:
    ; mov [buffer3 + 4], cs
    jmp far [buffer3]
buffer3:
    dd _pushret
    dw _CS
_c

_pushret:               ; push an address then return to it
    push _pushretf
    ret                 ; it's also a way to make an absolute jump without changing a register or flag.
_c

_pushretf:
    push cs
    push _pushiret
    retf
_c

_pushiret:
    pushfd
    push cs
    push _ret
    iretd
_c

_ret:
    ret

classics:
    setmsg_ "ERROR: MOV reg32, imm32"
    mov eax, 3
    expect eax, 3
_
    setmsg_ "ERROR: MOVZX"
    mov al, -1
    movzx ecx, al
    expect ecx, 0ffh
_
    setmsg_ "ERROR: MOVSX"
    mov al, -3
    movsx ecx, al
    expect ecx, -3
_
    setmsg_ "ERROR: LEA"
    mov eax, 3
    lea eax, [eax * 8 + eax + 203Ah]
    expect eax, 203ah + 8 * 3 + 3
_
    setmsg_ "ERROR: XCHG"
    mov al, 1
    mov bl, 2
    xchg al, bl
    expect al, 2
    expect bl, 1
;_
;    xchg [xchgpopad] , esp                  ; makes a backup of ESP and temporarily change ESP to the start of the data
;    popad                                   ; read all the data into registers
;    mov esp, [xchgpopad]                    ; restore ESP and EAX
_
    setmsg_ "ERROR: ADD"
    mov eax, 3
    add eax, 3
    expect eax, 6
_
    setmsg_ "ERROR: ADC"
    stc
    mov eax, 3
    adc eax, 3
    expect eax, 3 + 3 + 1
_
    setmsg_ "ERROR: SUB"
    mov eax, 6
    sub eax, 3
    expect eax, 6 - 3
_
    setmsg_ "ERROR: SBB"
    stc
    mov eax, 6
    sbb eax, 3
    expect eax, 6 - 3 - 1
_
    setmsg_ "ERROR: INC"
    mov eax, 0
    inc eax
    expect eax, 0 + 1
_
    setmsg_ "ERROR: DEC"
    mov eax, 7
    dec eax
    expect eax, 7 - 1
_
    setmsg_ "ERROR: OR"
    mov eax, 1010b
    or eax, 0110b
    expect eax , 1110b
_
    setmsg_ "ERROR: AND"
    mov eax, 1010b
    and eax, 0110b
    expect eax, 0010b
_
    setmsg_ "ERROR: XOR"
    mov eax, 1010b
    xor eax, 0110b
    expect eax, 1100b
_
    setmsg_ "ERROR: NOT"
    mov al, 1010b
    not al
    expect al, 11110101b
_
    setmsg_ "ERROR: NEG"
    mov al, 1010b
    neg al
    expect al, -1010b
_
    setmsg_ "ERROR: ROL"
    mov eax, 1010b
    rol eax, 3
    expect eax, 1010000b
_
    setmsg_ "ERROR: ROR"
    mov al, 1010b
    ror al, 3
    expect al, 01000001b
_
    setmsg_ "ERROR: RCL"
    stc
    mov al, 1010b
    rcl al, 3
    expect eax, 1010100b
_
    setmsg_ "ERROR: RCR"
    stc
    mov al, 1010b
    rcr al, 3
    expect al, 10100001b
_
    setmsg_ "ERROR: SHL"
    mov al, 1010b
    shl al, 2
    expect al, 101000b
_
    setmsg_ "ERROR: SAL"                    ; this is actually SHL
    mov eax, -1010b
    sal eax, 3
    expect eax, -1010000b
_
    mov al, 1010b
    shr al, 2
    expect al, 10b
_
    setmsg_ "ERROR: SAR"
    mov al, -8                              ; shift arithmetic right (shift and propagates the sign)
    sar al, 2
    expect al, -2
_
    setmsg_ "ERROR: SHLD"
    mov ax, 1111b
    mov bx, 0100000000000000b
    shld ax, bx, 3
    expect ax, 1111010b
_
    setmsg_ "ERROR: SHRD"
    mov ax, 1101001b
    mov bx, 101b
    shrd ax, bx, 3
    expect ax, 1010000000001101b
_
    setmsg_ "ERROR: DIV"
    mov ax, 35
    mov bl, 11
    div bl                                  ; 35 = 3 * 11 + 2
    expect al, 3                            ; quo
    expect ah, 2                            ; rem
_
    setmsg_ "ERROR: MUL"
    mov al, 11
    mov bl, 3
    mul bl
    expect ax, 3 * 11
_
    setmsg_ "ERROR: IMUL"
    mov eax, 11
    imul eax, eax, 3
    expect eax, 3 * 11
_
    setmsg_ "ERROR: PUSH/LEAVE"
    push 3
    enter 8, 0
    enter 4, 1
    leave
    leave
    pop eax
    expect eax, 3
_
    setmsg_ "ERROR: SETC"
    stc
    setc al
    expect al, 1
    clc
    setc al
    expect al, 0
_
    setmsg_ "ERROR: CMOVC"
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
    setmsg_ "ERROR: BSF"
    mov eax, 0010100b
    bsf ebx, eax                            ; bit scan forward
    expect ebx, 2
_
    setmsg_ "ERROR: BSR"
    mov eax, 0010100b
    bsr ebx, eax                            ; bit scan reverse
    expect ebx, 4
_
    setmsg_ "ERROR: BT"
    mov ax, 01100b
    mov bx, 2
    bt ax, bx                               ; bit test
    jnc bad
    expect ax, 01100b                       ; unchanged
_
    setmsg_ "ERROR: BTR"
    mov ax, 01101b
    mov bx, 2
    btr ax, bx                              ; bit test and reset
    jnc bad
    expect ax, 1001b
_
    setmsg_ "ERROR: BTC"
    mov ax, 01101b
    mov bx, 2
    btc ax, bx                              ; bit test and complement
    jnc bad
    expect ax, 1001b
_
    setmsg_ "ERROR: BSWAP"
    mov eax, 12345678h
    bswap eax
    expect eax, 78563412h
_
    setmsg_ "ERROR: CBW"
    mov eax, -1
    mov al, 3
    cbw
    expect ax, 3
    setmsg_ "ERROR: CWDE"
    cwde
    expect eax, 3
    setmsg_ "ERROR: CWD"
    cwd
    expect dx, 0
_
    retn
_c

rares:
    setmsg_ "ERROR: XADD"
    mov al, 1
    mov bl, 2
    xadd al, bl
    expect al, 1 + 2
    expect bl, 1
_
    setmsg_ "ERROR: AAA"
    mov ax, 0304h                           ; 34
    mov bx, 0307h                           ; 37
    add ax, bx
    aaa
    expect ax, 0701h                        ;34 + 37 = 71
_
    setmsg_ "ERROR: DAA"
    mov ax, 01234h                          ; 1234
    mov bx, 0537h                           ; 537
    add ax, bx
    daa
    expect ax, 1771h                        ; 1234 + 537 = 1771
_
    setmsg_ "ERROR: AAS"
    mov al, 01h
    mov bl, 04h
    sub al, bl
    aas
    expect al, 11 - 4
_
    setmsg_ "ERROR: DAS"
    mov eax, 01771h
    mov ebx, 01234h
    sub eax, ebx
    das
    expect eax, 537h                        ; 1771 - 1234 = 537
_
    setmsg_ "ERROR: AAD"
    mov ax, 0305h
    aad
    expect ax, 35                           ; 03 05 becomes 35
_
    setmsg_ "ERROR: AAM"
    rdtsc
    mov ax, 35
    aam
    expect ax, 305h
_
    setmsg_ "ERROR: LDS - wrong register value"
    push ds
    mov ebx, addseg                         ; [addseg] = 00:12345678
    lds eax, [ebx]
    expect eax , 12345678h
;    setmsg_ "ERROR: LDS - wrong segment value"
    push ds
    pop eax
    expect ax, 0
    pop ds
_
    setmsg_ "ERROR: BOUND"
    mov eax, 136
    mov ebx, boundslimit                    ; boundslimit = [135, 143]
    bound eax, [ebx]
    ; no exception happens if within bounds
_
    setmsg_ "ERROR: ARPL"
    ; compares lower 2 bits and copy if inferior
    ARPL_ equ 1111111111111100b
    mov ax, ARPL_
    mov bx, 1010100111b
    arpl ax, bx
    jnz bad                                 ; ZF should be set too
    expect ax, ARPL_ + 11b
_
    setmsg_ "ERROR: INC reg16"
    mov ecx, -1
    db 66h                                  ; just increasing cx instead of ecx
    inc ecx
    expect ecx, 0ffff0000h
_
    setmsg_ "ERROR: JCXZ"
    db 67h                                  ; just checking cx instead of ecx
    jecxz _cx0
    jmp bad
_cx0:
_
    setmsg_ "ERROR: XLATB (on EBX)"
    mov al, 35
    mov ebx, xlattable                      ; xlattable[35] = 75
    xlatb
    expect al, 75
_
delta8 equ 20
xlat8b equ 68
xlatval equ 78
    setmsg_ "ERROR: XLATB (on BX)"
    mov byte [xlat8b], xlatval
    mov al, xlat8b - delta8
    mov bx, delta8                              ; xlattable[] = 75
    db 67h     ; reads from [BX + AL]
        xlatb
    expect al, xlatval
_
    setmsg_ "ERROR: LAR"
    push cs
    pop ecx
    lar eax, ecx
    expect eax, 0cffb00h
_
    setmsg_ "ERROR: VERR"
    push cs
    pop ecx
    verr cx
    jnz bad
_
    setmsg_ "ERROR: CMPXCHG"
    mov al, 3
    mov bl, 6
    cmpxchg bl, cl
    expect al, bl
_
    setmsg_ "ERROR: CMPXCHG"
    mov al, 3
    mov bl, al
    cmpxchg bl, cl
    expect bl, cl
_
    setmsg_ "ERROR: CMPXCHG8B"
    mov eax, 00a0a0a0ah
    mov edx, 0d0d0d0d0h
    mov ecx, 99aabbcch
    mov ebx, 0ddeeff00h
    mov esi, _cmpxchg8b                     ; [_cmpxchg8b] = 0d0d0d0d0:00a0a0a0a
    lock cmpxchg8b [esi]                    ; lock, for the pentium bug fun :)
    expect [_cmpxchg8b], ebx
    expect [_cmpxchg8b + 4], ecx
_
    setmsg_ "ERROR: SLDT"
    sldt eax
    expect eax, 0                           ; 4060 under VmWare
_
    setmsg_ "ERROR: LSL"
    push cs
    pop ecx
    lsl eax, ecx
    jnz bad
    expect eax, -1                          ; 0ffbfffffh under vmware
_
    retn
_c

undocumented:
    ; undocumented behavior with an immediate operand different from 10
    setmsg_ "ERROR: AAM with non-10 operand [undocumented]"
    rdtsc
    mov al, 3ah
    aam 3                                   ; ah = al / 3, al = al % 3 => ah = 13h, al = 1
    expect ax, 1301h
_
    ; 'undocumented' opcode: salc/setalc    ; Set AL on Carry.
    setmsg_ "ERROR: SETALC [undocumented]"
    stc
    salc
    expect al, -1
_
    setmsg_ "ERROR: SETALC [undocumented]"
    clc
    salc
    expect al, 0
_
    ; aad with an immediate operand that is not 10
    setmsg_ "ERROR: AAD with non-10 operand [undocumented]"
    rdtsc
    mov ax, 0325h
    aad 7                                   ; ah = 0, al = ah * 7 + al => al = 3Ah
    expect ax, 003Ah
_
    ; bswap behavior on 16bit
    setmsg_ "ERROR: BSWAP reg16 [undocumented]"
    mov eax, 12345678h
    PREFIX_OPERANDSIZE
    bswap eax                               ; bswap ax = xor ax, ax
    expect eax, 12340000h
_
    ; smsw on dword is officially undocumented, but it just fills the whole CR0 to the operand
    setmsg_ "ERROR: SMSW reg32 [undocumented]"
    smsw eax
    expect eax, 08001003bh  ; XP

    retn
_c

cpu_specifics:
    mov eax, 0
    cpuid
    cmp eax, 0ah
    jl bad
_
    mov eax, 1
    cpuid
    mov [cpuid_ecx], ecx

    mov ecx, [cpuid_ecx]
    and ecx, 1 << 23
    jz no_popcnt
_
    setmsg_ "ERROR: POPCNT"
    mov ebx, 0100101010010b
    popcnt eax, ebx
    expect eax, 5
    jmp popcnt_end
no_popcnt:
    print_ "Info: POPCNT not supported"
    jmp popcnt_end
popcnt_end:
_
    mov ecx, [cpuid_ecx]
    and ecx, 1 << 22
    jz no_movbe
_
    setmsg_ "ERROR: MOVBE"
    mov ebx, _movbe                         ; [_movbe] = 11223344h
    movbe eax, [ebx]
    expect eax, 44332211h
    jmp movbe_end
no_movbe:
    print_ "Info: MOVBE not supported"
    jmp movbe_end
movbe_end:
_
    mov ecx, [cpuid_ecx]
    and ecx, 1 << 20
    jz no_crc32
_
    setmsg_ "ERROR: CRC32"
    mov eax, 0abcdef9h
    mov ebx, 12345678h
    crc32 eax, ebx
    expect eax, 0c0c38ce0h
    jmp crc32_end
no_crc32:
    print_ "Info: CRC32 not supported"
    jmp crc32_end
crc32_end:
_
    retn
_c

cpuid_ecx dd 0
_d

rand:
    push edx
    rdtsc
    push eax
    rdtsc
    bswap eax
    pop edx
    xor eax, edx
    pop edx
    retn
_c

randreg:
    call rand
        mov ebx, eax
    call rand
        mov ecx, eax
    call rand
        mov esi, eax
    call rand
        mov edi, eax
    call rand
        mov ebp, eax
    call rand
        mov esi, eax
    call rand
        mov edx, eax
    call rand
    retn
_c

nops:
    call randreg
    pushad

    ; these ones should do nothing (and not trigger any LOCK exception)
    push eax
    xor eax, eax
    add [eax], al

    lock adc [eax], eax
    lock add [eax], eax
    lock and [eax], eax
    lock or [eax], eax
    lock sbb [eax], eax
    lock sub [eax], eax
    lock xor [eax], eax
    lock cmpxchg [eax], eax
    push edx
    lock cmpxchg8b [eax]
    pop edx
_
    ; lock bt [eax], eax                    ; this one is not valid, and will trigger an exception
    lock btc [eax], eax
    lock btr [eax], eax
    lock bts [eax], eax

    lock dec dword [eax]
    lock inc dword [eax]
    lock neg dword [eax]
    lock not dword [eax]

    lock xadd [eax], eax                    ; atomic, superfluous prefix, but no exception
    lock xchg [eax], eax                    ; atomic, superfluous prefix, but no exception

    mov dword [0], 0
    pop eax
_
    nop
    xchg eax, eax
    xchg al, al
    pause
_
    mov eax, eax
    or eax, eax
    xor eax, 0
    sub eax, 0
    cmp eax, 0
    test eax, 0
    and eax, eax                            ; should clear Z
_
    cmc
    stc
    clc
    std
    cld
;loopz _afterloop
;_afterloop:
jnz _afterjnz
_afterjnz:
cmovz eax, ebx
_
    sfence
    mfence
    lfence
    prefetch [eax]                          ;0f0d00
    prefetchnta [eax]                       ;0f1800
    prefetcht0 [eax]                        ;0f18 08
    prefetcht1 [eax]                        ;0f18 10
    prefetcht2 [eax]                        ;0f18 18
_
    ; if OF is not set, this just does a nop - a tricky nop then
    into
_
    db 0fh, 1ch, 00                         ; nop [eax] ; doesn't trigger an exception
    db 0fh, 019h, 084h, 0c0h
        dd 080000000h                       ; hint_nop [eax + eax * 8 - 080000000h]
_
    push eax
    pop eax
_
    call $ + 5
    add esp, 4                              ; changes flags ! bad :p
_
    enter 0,0
    leave
_
    push eax
    push eax
    call _retn4
    pop eax
_
    pushad
    popad
    pushaw
    popaw
_
    pushf
    popf
    pushfw
    popfw
_
    push ds
    pop ds
_
    inc eax
    dec eax

    add eax, 31415926h
    sub eax, 31415926h

    lea eax, [eax + 31415926h]
    sub eax, 31415926h

    rol eax, 35
    ror eax, 35
_
    fnop
    emms
_
    ffreep st0
    db 0d9h, 0d8h                           ; fstp1 st0
    db 0dch, 0d0h                           ; fcom2 st0
    db 0dch, 0d8h                           ; fcomp3 st0
    db 0ddh, 0c8h                           ; fxch4 st0
    db 0deh, 0d0h                           ; fcomp5 st0
    db 0dfh, 0c8h                           ; fxch7 st0
    db 0dfh, 0d0h                           ; fstp8 st0
    db 0dfh, 0d8h                           ; fstp9 st0
    db 0dbh, 0e0h                           ; fneni
    db 0dbh, 0e1h                           ; fndisi
_
    ;int 2dh
_
    ; we're checking nothing was modified during the nop pairs
    cmp eax, [esp + 1ch]
    jnz bad
    cmp ecx, [esp + 18h]
    jnz bad
    cmp edx, [esp + 14h]
    jnz bad
    cmp ebx, [esp + 10h]
    jnz bad
    cmp ebp, [esp + 8]
    jnz bad
    cmp esi, [esp + 4]
    jnz bad
    cmp edi, [esp + 0]
    jnz bad
    popad
_
    retn
_c
_retn4:
    retn 4


XP_tests:
    setmsg_ "ERROR: SMSW [XP]"
    smsw ax
    expect ax, 0003bh  ; XP
_
    setmsg_ "ERROR: SIDT [XP]"
    mov eax, sidt_
    sidt [eax]
    expect word [eax], 007ffh
_
    setmsg_ "ERROR: SGDT [XP]"
    mov eax, sgdt_
    sgdt [eax]
    expect word [eax], 003ffh               ; 0412fh under vmware
_
    setmsg_ "ERROR: STR reg16 [XP]"
    mov eax, -1
    str ax
    expect eax, 0ffff0028h                  ; 4000h under vmware
_
    setmsg_ "ERROR: STR reg32 [XP]"
    mov eax, -1
    str eax
    expect eax, 28h                          ; 4000h under vmware
_
    setmsg_ "ERROR: sysenter [XP]"
    mov eax, 10001h
    push _return
    mov edx, esp
    sysenter
_c

_return:
    expect eax, ACCESS_VIOLATION            ; depends if [EAX] was a valid address or not
    lea eax, [esp - 4]
    expect ecx, eax                         ; 1 if stepping
    mov al, [edx]
    expect al, 0c3h
    expect edx, [__imp__KiFastSystemCallRet]; -1 if stepping
    retn
_c
;%IMPORT ntdll.dll!KiFastSystemCallRet
_c

W7_tests:
    setmsg_ "ERROR: SMSW [W7]"
    smsw eax
    cmp eax, 080050031h  ; Win7 x64
_
    setmsg_ "ERROR: SIDT [W7]"
    mov eax, sidt_
    sidt [eax]
    expect word [eax], 0fffh
_
    setmsg_ "ERROR: SGDT [W7]"
    mov eax, sgdt_
    sgdt [eax]
    expect word [eax], 07fh
_
    setmsg_ "ERROR: STR reg16 [W7]"
    str ax
    expect ax, 40h
    retn
_c

sgdt_ dd 0,0
sidt_ dd 0,0
os dd 0
_d

CONST equ 035603h

encodings: ; undocumented alternate encodings
    mov eax, CONST
    db 0f7h, 0c8h                           ; test eax, CONST
        dd CONST
    jz bad
_
    db 0f7h, 0c0h                           ; test eax, CONST
        dd CONST
    jz bad
_
    ; 'SAL' is technically the same as SHL, but different encoding
    setmsg_ "ERROR: Wrong EIP via Call/pop"
    mov al, 1010b
    db 0c0h, 0f0h, 2                        ; sal al, 2
    expect al, 101000b
_
    retn
_c

smswtrick:
waitfor3b:
    setmsg_ "ANTI-DEBUG: SMSW - incorrect value after FPU"
    smsw ax
    cmp ax, 03bh
    jnz waitfor3b

    fnop
    smsw ax
    expect ax, 031h   ; 03bh if debugged

_1:
    smsw ax
    cmp ax, 031h
    jz _1
    retn

%macro mov_gs 1
    mov ax, %1
    mov gs, ax
%endmacro

%macro cmp_gs 1
    mov ax, gs
    cmp ax, %1
%endmacro

%macro gsloop 0
    mov_gs 3
%%_not:
    cmp_gs 3
    jz %%_not
%endmacro

gstrick:
    ; anti stepping with thread switch GS clearing
    setmsg_ "ANTI-DEBUG: incorrect value of GS"
    mov_gs 3
    mov ax, gs
    expect ax, 3

; gs should still be 3

    ; behavior-based anti-emulator
    gsloop      ; infinite loop if gs is not eventually reset

    ; timing based anti-emulator
;gsloop ; not needed, since we just switched in, because gs is 0
    rdtsc
    mov ebx, eax
gsloop
    rdtsc
    sub eax, ebx
    cmp eax, 100h     ; 2 consecutives rdtsc take less than 100h ticks, we expect a much bigger value here.
    jae GSgood
    print_ "ANTI-DEBUG: GS is not reset slowly enough"
GSgood:
    retn
_c

antis:
    call gstrick
    call smswtrick
_
TF equ 0100h
    ; checking if the Trap Flag is set via pushf (sahf doesn't save TF)
    pushf
    pop eax
    and eax, TF
    setmsg_ "ANTI-DEBUG: TF is set"
    expect eax, 0
_
    ; the same, but 'pop ss' prevents the debugger to step on pushf
    setmsg_ "ANTI-DEBUG: TF is set (after pop ss)"
    push ss
    pop ss
    pushf
    pop eax
    and eax, TF
    jnz bad
_
    ; anti-debug: rdtsc as a timer check
    rdtsc
    mov ebx, eax
    mov ecx, edx
    rdtsc
    cmp eax, ebx
    jnz different_timers
    print_ "ANTI-DEBUG: RDTSC timers identical..."
different_timers:
    sub eax, ebx
    cmp eax, 100h
    jle not_too_slow
    print_ "ANTI-DEBUG: RDTSC too far from each other"
not_too_slow:

_
    retn
_c

get_ips:
    setmsg_ "ERROR: Wrong EIP via Call/pop"
    ; get ip call
    call $ + 5
after_call:
    pop eax
    expect eax, after_call
_
    ; get ip far call
    setmsg_ "ERROR: Wrong EIP via Call FAR/pop"
    call far 01bh: $ + 7
after_far:
    pop eax
    expect eax, after_far
    pop eax
    expect eax, _CS
_
    ; get ip f?stenv
    setmsg_ "ERROR: Wrong EIP via FPU"
_fpu:
    fnop
    fnstenv [fpuenv]              ; storing fpu environment
    mov eax,[fpuenv.DataPointer]  ; getting the EIP of last fpu operation
    expect eax, _fpu
    ; using the FPU will change internal flags such as cr0
_
    retn
_c

%define PREFIX_BRANCH_TAKEN db 3eh
%define PREFIX_BRANCH_NOT_TAKEN db 2eh

disassembly:
    ; the following lines are just to test common mistakes in output
    retn
PREFIX_BRANCH_TAKEN
    jz $ + 2
PREFIX_BRANCH_NOT_TAKEN
    jnz $ + 2
    call word disassembly
    db 66h
    retn
    str eax
    str ax
    str [eax]
    smsw eax
    smsw ax
    PREFIX_OPERANDSIZE                      ; YASM doesn't support bswap <reg16>
        bswap eax
    bswap eax
    db 0f1h
    db 64h
    movsd
    xlatb      ; reads from [EBX + AL]
    db 67h     ; reads from [BX + AL]
        xlatb
    db 0fh, 0ffh    ; ud0                   ;0fff
    ud1                                     ;0fb9
    ud2                                     ;0f0b
_c

xlattable:
times 35 db 0
         db 75

boundslimit:
    dd 135
    dd 143
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

good:
    push 0
    call ExitProcess
_c

bad:
    print_ "Error"
    push 0
    call ExitProcess
_c

;%IMPORT kernel32.dll!ExitProcess
_c
MEM_RESERVE               equ 2000h
MEM_TOP_DOWN              equ 100000h

TLS:
    push PAGE_READWRITE     ; ULONG Protect
    push MEM_RESERVE|MEM_COMMIT|MEM_TOP_DOWN     ; ULONG AllocationType
    push zwsize             ; PSIZE_T RegionSize
    push 0                  ; ULONG_PTR ZeroBits
    push lpBuffer3          ; PVOID *BaseAddress
    push -1                 ; HANDLE ProcessHandle
    call ZwAllocateVirtualMemory
_
    mov eax, [fs:18h]
    mov ecx, [eax + 030h]
    xor eax, eax
    or eax, [ecx + 0a8h]
    shl eax,8
    or eax, [ecx + 0a4h]
    cmp eax, 0106h
    jz W7
_
    print_ "Info: Windows XP found"
    mov dword [os], XP_tests
    retn
_c

W7:
    print_ "Info: Windows 7 found"
    mov dword [os], W7_tests
    retn
_c

;%IMPORT ntdll.dll!ZwAllocateVirtualMemory
_c

zwsize dd 0ffffh
lpBuffer3 dd 1
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

fpuenv:
    .ControlWord           dd 0
    .StatusWord            dd 0
    .TagWord               dd 0
    .DataPointer           dd 0
    .InstructionPointer    dd 0
    .LastInstructionOpcode dd 0
    dd 0
_d

;%IMPORTS
_d

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE
