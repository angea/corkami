%include '..\..\onesec.hdr'

program db 'User-mode opcodes tester v0.2b 2011/??/??    ', 0dh, 0ah, 0
author  db 'Ange Albertini, BSD Licence, 2009-2011 - http://corkami.com', 0dh, 0ah, 0
_d

;this file tests each usermode opcode (at least, one of almost all families)
; using segment 33h trick to test 64b opcodes
; using ZwAllocateVirtualMemory trick to allocate [0000-ffff], so word jumps and returns are working

; tested under W7 64b, XP SP3, XPSP1 under VmWare

; general FPU/SSE+ opcodes are not included

;TODO:
; add IP checking for exception triggers
; int2a-2b os dependent
; test int2d under ollydbg 1/2
; int2c-2e with wrong/right address
; merge os checks, just see values
; merge 16b operations - expand stub for tests on [0000-ffff]
; fsave, fxsave
; setldtentries, xlat/movs* with selector
; test print watchdog with VEH

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

%macro print_ 1+
    push %1
;    mov dword [PRINTME] , %1
    call printnl
%endmacro

EntryPoint:
    call initconsole
;    setSEH printer
    print_ program
    print_ author
    call init
    jmp main
_c


init:
    print_ %string:"allocating buffer [0000-ffff]", 0dh, 0
    call initmem
    print_ %string:"checking OS version", 0dh, 0
    call checkOS
    retn
_c

main:
    ; call to word
    ; jump short, near, to word, to reg32, to reg16, far
    ; return near, near word, far, interrupt
    print_ %string:"testing jumps opcodes...", 0dh, 0ah, 0
    call jumps_
_
    ; mov movzx movsx lea xchg add sub sbb adc inc dec or and xor
    ; not neg rol ror rcl rcr shl shr shld shrd div mul imul enter leave
    ; setXX cmovXX bsf bsr bt btr btc bswap cbw cwde cwd
    print_ %string:"testing classic opcodes...", 0dh, 0ah, 0
    call classics
_
    print_ %string:"testing rare opcodes...", 0dh, 0ah, 0
    ; xadd aaa daa aas das aad aam lds bound arpl inc jcxz xlatb (on ebx and bx) lar
    ; verr cmpxchg cmpxchg8b sldt lsl
    call rares
_
    print_ %string:"testing undocumented opcodes...", 0dh, 0ah, 0
    call undocumented ; aam xx, salc, aad xx, bswap reg16, smsw reg32
_
    print_ %string:"testing cpu-specific opcodes...", 0dh, 0ah, 0
    call cpu_specifics  ; popcnt movbe crc32
_
    print_ %string:"testing undocumented encodings...", 0dh, 0ah, 0
    call encodings      ; test, 'sal'
_
    ; smsw sidt sgdt str sysenter
    print_ %string:"testing os-dependant opcodes...", 0dh, 0ah, 0
    call [os]   ; os should be before any fpu use
_
    ; nop pause sfence mfence lfence prefetchnta 'hint nop' into, fpu, lock + operators
    print_ %string:"testing 'nop' opcodes...", 0dh, 0ah, 0
    call nops
_
    ; gs, smsw, rdtsc, pushf, pop ss
    print_ %string:"testing opcode-based anti-debuggers...", 0dh, 0ah, 0
    call antis
_
    print_ %string:"testing opcode-based GetIPs...", 0dh, 0ah, 0
    call get_ips ; call, call far, fstenv
_
    ; generic int 00-FF , int 2d, illegal instruction,
    ; into, int4, int3, int 3, IceBP, TF, bound, lock, in, hlt
    print_ %string:"testing opcode-based exception triggers...", 0dh, 0ah, 0
    call exceptions
_
    ; documented but frequent disassembly mistakes
    ; bswap, smsw, str, branch hints, word calls/rets/loops, FS:movsd, xlatb, ud*
    call disassembly
_
    print_ %string:"testing 64 bits opcodes...", 0dh, 0ah, 0
    ; cwde cmpxchg16 lea movsxd
    call sixtyfour
_
    jmp good
_c

good:
    print_ ''
    print_ %string:0dh, 0ah, "...completed!", 0dh, 0ah, 0
    push 0
    call ExitProcess
_c

bad:
    print_ %string:0dh, 0ah, "Error", 0dh, 0ah, 0
    call print
    retn
    ; temporarily trying that error reporting tries to resume execution
    push 42
    call ExitProcess
_c

%macro expect 2
    cmp %1, %2
    jz %%good
    call errormsg_
%%good:
%endmacro

;%IMPORT kernel32.dll!ExitProcess
_c

;%strings
newline db 0dh, 0ah, 0
_d

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
    push ecx                        ; DWORD nNumbersOfCharsToWrite
    push edi                        ; VOID *lpBuffer
    push dword [hConsoleOutput]     ; HANDLE hConsoleOutput
    call WriteConsoleA
    popad
    retn 4
_c

printnl:
    push %string:'                                                                         ', 0dh, 0
    call print
    push dword [esp + 4]
    call print
    retn 4
_c

;%IMPORT kernel32.dll!WriteConsoleA
_c

lpNumbersOfCharsWritten dd 0
_d

%macro setmsg_ 1+
    mov dword [ErrorMsg], %1
%endmacro

errormsg_:
    push dword [ErrorMsg]
    call printnl
    retn
_c

ErrorMsg dd 0
_d

STD_OUTPUT_HANDLE equ -11
initconsole:
    push STD_OUTPUT_HANDLE  ; DWORD nStdHandle
    call GetStdHandle
    mov [hConsoleOutput], eax
    retn
_c
;%IMPORT kernel32.dll!GetStdHandle
_c

hConsoleOutput dd 0
;%strings
_d

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MEM_RESERVE               equ 2000h
MEM_TOP_DOWN              equ 100000h

initmem:
    push PAGE_READWRITE     ; ULONG Protect
    push MEM_RESERVE|MEM_COMMIT|MEM_TOP_DOWN     ; ULONG AllocationType
    push zwsize             ; PSIZE_T RegionSize
    push 0                  ; ULONG_PTR ZeroBits
    push lpBuffer3          ; PVOID *BaseAddress
    push -1                 ; HANDLE ProcessHandle
    call ZwAllocateVirtualMemory
    retn
_c

checkOS:
    mov eax, [fs:18h]
    mov ecx, [eax + 030h]
    xor eax, eax
    or eax, [ecx + 0a8h]
    shl eax,8
    or eax, [ecx + 0a4h]
    cmp eax, 0106h
    jz W7
_
XP:
    print_ %string:"Info: Windows XP found", 0dh, 0ah, 0
    mov dword [lock_exception], INVALID_LOCK_SEQUENCE
    mov dword [prefix_exception], ILLEGAL_INSTRUCTION
    mov dword [os], XP_tests
    retn
_c

W7:
    print_ %string:"Info: Windows 7 found", 0dh, 0ah, 0
    mov dword [lock_exception], ILLEGAL_INSTRUCTION
    mov dword [prefix_exception], ACCESS_VIOLATION
    mov dword [os], W7_tests
    retn
_c

;%IMPORT ntdll.dll!ZwAllocateVirtualMemory
_c

zwsize dd 0ffffh
lpBuffer3 dd 1
;%strings
_d

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;cs is:
; 01bh on Windows XP usermode
; 23 on W7 in 32 bit
; 33 in 64b

jumps_:
_retword:
    mov ecx, bad
    and ecx, 0ffffh
    ; a little pre-padding for the call word trick (actually not needed as 0000 is a nop here...)
    ; mov word [ecx - 2], 9090h
    mov byte [ecx], 68h
    mov dword [ecx + 1], _callword
    mov byte [ecx + 5], 0c3h
    print_ %string:"Testing now: RETN WORD", 0dh, 0
    push bad
    db 66h
        retn
_c

_callword:
    sub esp, 2
    mov dword [ecx + 1], _jumpword
    print_ %string:"Testing now: CALL WORD", 0dh, 0
    db 66h
    call bad
_c

_jumpword:
    add esp, 2 + 4
    mov dword [ecx + 1], _jumps
    print_ %string:"Testing now: JMP WORD", 0dh, 0
    db 66h
    jmp bad
_c

_jumps:
    print_ %string:"Testing now: SHORT JUMP", 0dh, 0
    jmp short _jmp1     ; short jump, relative, EB
_c

_jmp1:
    print_ %string:"Testing now: NEAR JUMP", 0dh, 0
    jmp near _jmpreg32  ; jump, relative, E9
_c

_jmpreg32:                ; jump via register
    print_ %string:"Testing now: JUMP reg32", 0dh, 0
    mov eax, _jmpreg16
    jmp eax

_jmpreg16:
    print_ %string:"Testing now: JUMP reg16", 0dh, 0
    mov dword [ecx + 1], _jmp3
    db 67h
        jmp ecx
_c

_jmp3:
    print_ %string:"Testing now: JMP [mem]", 0dh, 0
    jmp dword [buffer1]
    buffer1 dd _jmp4
_c

    ; far jump, absolute
_jmp4:
                        ; jmp far is encoded as EA <ddOffset> <dwSegment>
    mov [_patchCS + 5], cs
    print_ %string:"Testing now: JUMP FAR IMMEDIATE", 0dh, 0
_patchCS:
    jmp 0:_jmp5
_c

_jmp5:
    mov [buffer3 + 4], cs
    print_ %string:"Testing now: JUMP FAR [MEM]", 0dh, 0
    jmp far [buffer3]
buffer3:
    dd _pushret
    dw 0
_c

_pushret:               ; push an address then return to it
    print_ %string:"Testing now: RET", 0dh, 0
    push _pushretf
    ret                 ; it's also a way to make an absolute jump without changing a register or flag.
_c

_pushretf:
    print_ %string:"Testing now: RET FAR", 0dh, 0
    push cs
    push _pushiret
    retf
_c

_pushiret:
    print_ %string:"Testing now: INTERRUPT RET", 0dh, 0
    pushfd
    push cs
    push _ret
    iretd
_c

_ret:
    ret
_c

;%strings
_d

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

classics:
    setmsg_ %string:"ERROR: MOV reg32, imm32", 0dh, 0ah, 0
    mov eax, 3
    expect eax, 3
_
    setmsg_ %string:"ERROR: MOVZX", 0dh, 0ah, 0
    mov al, -1
    movzx ecx, al
    expect ecx, 0ffh
_
    setmsg_ %string:"ERROR: MOVSX", 0dh, 0ah, 0
    mov al, -3
    movsx ecx, al
    expect ecx, -3
_
    setmsg_ %string:"ERROR: LEA", 0dh, 0ah, 0
    mov eax, 3
    lea eax, [eax * 8 + eax + 203Ah]
    expect eax, 203ah + 8 * 3 + 3
_
    setmsg_ %string:"ERROR: XCHG", 0dh, 0ah, 0
    mov al, 1
    mov bl, 2
    xchg al, bl
    expect al, 2
    expect bl, 1
_
    setmsg_ %string:"ERROR: ADD", 0dh, 0ah, 0
    mov eax, 3
    add eax, 3
    expect eax, 6
_
    setmsg_ %string:"ERROR: ADC", 0dh, 0ah, 0
    stc
    mov eax, 3
    adc eax, 3
    expect eax, 3 + 3 + 1
_
    setmsg_ %string:"ERROR: SUB", 0dh, 0ah, 0
    mov eax, 6
    sub eax, 3
    expect eax, 6 - 3
_
    setmsg_ %string:"ERROR: SBB", 0dh, 0ah, 0
    stc
    mov eax, 6
    sbb eax, 3
    expect eax, 6 - 3 - 1
_
    setmsg_ %string:"ERROR: INC", 0dh, 0ah, 0
    mov eax, 0
    inc eax
    expect eax, 0 + 1
_
    setmsg_ %string:"ERROR: DEC", 0dh, 0ah, 0
    mov eax, 7
    dec eax
    expect eax, 7 - 1
_
    setmsg_ %string:"ERROR: OR", 0dh, 0ah, 0
    mov eax, 1010b
    or eax, 0110b
    expect eax , 1110b
_
    setmsg_ %string:"ERROR: AND", 0dh, 0ah, 0
    mov eax, 1010b
    and eax, 0110b
    expect eax, 0010b
_
    setmsg_ %string:"ERROR: XOR", 0dh, 0ah, 0
    mov eax, 1010b
    xor eax, 0110b
    expect eax, 1100b
_
    setmsg_ %string:"ERROR: NOT", 0dh, 0ah, 0
    mov al, 1010b
    not al
    expect al, 11110101b
_
    setmsg_ %string:"ERROR: NEG", 0dh, 0ah, 0
    mov al, 1010b
    neg al
    expect al, -1010b
_
    setmsg_ %string:"ERROR: ROL", 0dh, 0ah, 0
    mov eax, 1010b
    rol eax, 3
    expect eax, 1010000b
_
    setmsg_ %string:"ERROR: ROR", 0dh, 0ah, 0
    mov al, 1010b
    ror al, 3
    expect al, 01000001b
_
    setmsg_ %string:"ERROR: RCL", 0dh, 0ah, 0
    stc
    mov al, 1010b
    rcl al, 3
    expect eax, 1010100b
_
    setmsg_ %string:"ERROR: RCR", 0dh, 0ah, 0
    stc
    mov al, 1010b
    rcr al, 3
    expect al, 10100001b
_
    setmsg_ %string:"ERROR: SHL", 0dh, 0ah, 0
    mov al, 1010b
    shl al, 2
    expect al, 101000b
_
    mov al, 1010b
    shr al, 2
    expect al, 10b
_
    setmsg_ %string:"ERROR: SAR", 0dh, 0ah, 0
    mov al, -8                              ; shift arithmetic right (shift and propagates the sign)
    sar al, 2
    expect al, -2
_
    setmsg_ %string:"ERROR: SHLD", 0dh, 0ah, 0
    mov ax, 1111b
    mov bx, 0100000000000000b
    shld ax, bx, 3
    expect ax, 1111010b
_
    setmsg_ %string:"ERROR: SHRD", 0dh, 0ah, 0
    mov ax, 1101001b
    mov bx, 101b
    shrd ax, bx, 3
    expect ax, 1010000000001101b
_
    setmsg_ %string:"ERROR: DIV", 0dh, 0ah, 0
    mov ax, 35
    mov bl, 11
    div bl                                  ; 35 = 3 * 11 + 2
    expect al, 3                            ; quo
    expect ah, 2                            ; rem
_
    setmsg_ %string:"ERROR: MUL", 0dh, 0ah, 0
    mov al, 11
    mov bl, 3
    mul bl
    expect ax, 3 * 11
_
    setmsg_ %string:"ERROR: IMUL", 0dh, 0ah, 0
    mov eax, 11
    imul eax, eax, 3
    expect eax, 3 * 11
_
    setmsg_ %string:"ERROR: PUSH/LEAVE", 0dh, 0ah, 0
    push 3
    enter 8, 0
    enter 4, 1
    leave
    leave
    pop eax
    expect eax, 3
_
    setmsg_ %string:"ERROR: SETC", 0dh, 0ah, 0
    stc
    setc al
    expect al, 1
    clc
    setc al
    expect al, 0
_
    setmsg_ %string:"ERROR: CMOVC", 0dh, 0ah, 0
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
    setmsg_ %string:"ERROR: BSF", 0dh, 0ah, 0
    mov eax, 0010100b
    bsf ebx, eax                            ; bit scan forward
    expect ebx, 2
_
    setmsg_ %string:"ERROR: BSR", 0dh, 0ah, 0
    mov eax, 0010100b
    bsr ebx, eax                            ; bit scan reverse
    expect ebx, 4
_
    setmsg_ %string:"ERROR: BT", 0dh, 0ah, 0
    mov ax, 01100b
    mov bx, 2
    bt ax, bx                               ; bit test
    jnc bad
    expect ax, 01100b                       ; unchanged
_
    setmsg_ %string:"ERROR: BTR", 0dh, 0ah, 0
    mov ax, 01101b
    mov bx, 2
    btr ax, bx                              ; bit test and reset
    jnc bad
    expect ax, 1001b
_
    setmsg_ %string:"ERROR: BTC", 0dh, 0ah, 0
    mov ax, 01101b
    mov bx, 2
    btc ax, bx                              ; bit test and complement
    jnc bad
    expect ax, 1001b
_
    setmsg_ %string:"ERROR: BSWAP", 0dh, 0ah, 0
    mov eax, 12345678h
    bswap eax
    expect eax, 78563412h
_
    setmsg_ %string:"ERROR: CBW", 0dh, 0ah, 0
    rdtsc
    mov al, -3
    cbw
    expect ax, -3
    setmsg_ %string:"ERROR: CWDE", 0dh, 0ah, 0
    cwde
    expect eax, -3
    setmsg_ %string:"ERROR: CDQ", 0dh, 0ah, 0
    cdq
    expect edx, -1

    setmsg_ %string:"ERROR: CWD", 0dh, 0ah, 0
    mov ax, -15
    mov ebx, eax
    cwd
    expect eax, ebx
    expect dx, -1
_
    retn
_c

;%strings
_d

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

rares:
    setmsg_ %string:"ERROR: XADD", 0dh, 0ah, 0
    mov al, 1
    mov bl, 2
    xadd al, bl
    expect al, 1 + 2
    expect bl, 1
_
    setmsg_ %string:"ERROR: AAA", 0dh, 0ah, 0
    mov ax, 0304h                           ; 34
    mov bx, 0307h                           ; 37
    add ax, bx
    aaa
    expect ax, 0701h                        ;34 + 37 = 71
_
    setmsg_ %string:"ERROR: DAA", 0dh, 0ah, 0
    mov ax, 01234h                          ; 1234
    mov bx, 0537h                           ; 537
    add ax, bx
    daa
    expect ax, 1771h                        ; 1234 + 537 = 1771
_
    setmsg_ %string:"ERROR: AAS", 0dh, 0ah, 0
    mov al, 01h
    mov bl, 04h
    sub al, bl
    aas
    expect al, 11 - 4
_
    setmsg_ %string:"ERROR: DAS", 0dh, 0ah, 0
    mov eax, 01771h
    mov ebx, 01234h
    sub eax, ebx
    das
    expect eax, 537h                        ; 1771 - 1234 = 537
_
    setmsg_ %string:"ERROR: AAD", 0dh, 0ah, 0
    mov ax, 0305h
    aad
    expect ax, 35                           ; 03 05 becomes 35
_
    setmsg_ %string:"ERROR: AAM", 0dh, 0ah, 0
    rdtsc
    mov ax, 35
    aam
    expect ax, 305h
_
    setmsg_ %string:"ERROR: LDS - wrong register value", 0dh, 0ah, 0
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
    setmsg_ %string:"ERROR: BOUND", 0dh, 0ah, 0
    mov eax, 136
    mov ebx, boundslimit                    ; boundslimit = [135, 143]
    bound eax, [ebx]
    ; no exception happens if within bounds
_
    setmsg_ %string:"ERROR: ARPL", 0dh, 0ah, 0
    ; compares lower 2 bits and copy if inferior
    ARPL_ equ 1111111111111100b
    mov ax, ARPL_
    mov bx, 1010100111b
    arpl ax, bx
    jnz bad                                 ; ZF should be set too
    expect ax, ARPL_ + 11b
_
    setmsg_ %string:"ERROR: INC reg", 0dh, 0ah, 0
    mov ecx, -1
    db 66h                                  ; just increasing cx instead of ecx
    inc ecx
    expect ecx, 0ffff0000h
_
    setmsg_ %string:"ERROR: JCXZ", 0dh, 0ah, 0
    db 67h                                  ; just checking cx instead of ecx
    jecxz _cx0
    jmp bad
_cx0:
_
    setmsg_ %string:"ERROR: XLATB (on EBX)", 0dh, 0ah, 0
    mov al, 35
    mov ebx, xlattable                      ; xlattable[35] = 75
    xlatb
    expect al, 75
_
delta8 equ 20
xlat8b equ 68
xlatval equ 78
    print_ %string:"Testing now: XLATB (on BX)", 0dh, 0
    setmsg_ %string:"ERROR: XLATB (on BX)", 0dh, 0ah, 0
    mov byte [xlat8b], xlatval              ; will crash is 000000 not allocated
    mov al, xlat8b - delta8
    mov bx, delta8                              ; xlattable[] = 75
    db 67h     ; reads from [BX + AL]
        xlatb
    expect al, xlatval
_
    setmsg_ %string:"ERROR: LAR", 0dh, 0ah, 0
    push cs
    pop ecx
    lar eax, ecx
    expect eax, 0cffb00h
_
    setmsg_ %string:"ERROR: VERR", 0dh, 0ah, 0
    push cs
    pop ecx
    verr cx
    jnz bad
_
    setmsg_ %string:"ERROR: CMPXCHG", 0dh, 0ah, 0
    mov al, 3
    mov bl, 6
    cmpxchg bl, cl
    expect al, bl
_
    setmsg_ %string:"ERROR: CMPXCHG", 0dh, 0ah, 0
    mov al, 3
    mov bl, al
    cmpxchg bl, cl
    expect bl, cl
_
    setmsg_ %string:"ERROR: CMPXCHG8B", 0dh, 0ah, 0
    mov eax, 00a0a0a0ah
    mov edx, 0d0d0d0d0h
    mov ecx, 99aabbcch
    mov ebx, 0ddeeff00h
    mov esi, _cmpxchg8b                     ; [_cmpxchg8b] = 0d0d0d0d0:00a0a0a0a
    lock cmpxchg8b [esi]                    ; lock, for the pentium bug fun :)
    expect [_cmpxchg8b], ebx
    expect [_cmpxchg8b + 4], ecx
_
    setmsg_ %string:"ERROR: SLDT non null (vm present ?)", 0dh, 0ah, 0
    sldt eax
    expect eax, 0                           ; 4060 under VmWare
_
    setmsg_ %string:"ERROR: LSL (vm present?)", 0dh, 0ah, 0
    push cs
    pop ecx
    lsl eax, ecx
    jnz bad
    expect eax, -1                          ; 0ffbfffffh under vmware
_
    retn
_c

xlattable:
times 35 db 0
         db 75
_d

boundslimit:
    dd 135
    dd 143

_cmpxchg8b:
    dd 00a0a0a0ah
    dd 0d0d0d0d0h

addseg:
    dd 12345678h
    dw 00h

;%strings
_d

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

undocumented:
    ; undocumented behavior with an immediate operand different from 10
    setmsg_ %string:"ERROR: AAM with non default operand (undocumented)", 0dh, 0ah, 0
    rdtsc
    mov al, 3ah
    aam 3                                   ; ah = al / 3, al = al % 3 => ah = 13h, al = 1
    expect ax, 1301h
_
    ; 'undocumented' opcode: salc/setalc    ; Set AL on Carry.
    setmsg_ %string:"ERROR: SETALC [undocumented]", 0dh, 0ah, 0
    stc
    salc
    expect al, -1
_
    setmsg_ %string:"ERROR: SETALC [undocumented]", 0dh, 0ah, 0
    clc
    salc
    expect al, 0
_
    ; aad with an immediate operand that is not 10
    setmsg_ %string:"ERROR: AAD with non default operand (undocumented)", 0dh, 0ah, 0
    rdtsc
    mov ax, 0325h
    aad 7                                   ; ah = 0, al = ah * 7 + al => al = 3Ah
    expect ax, 003Ah
_
    ; bswap behavior on 16bit
    setmsg_ %string:"ERROR: BSWAP reg16 (undocumented)", 0dh, 0ah, 0
    mov eax, 12345678h
    PREFIX_OPERANDSIZE
    bswap eax                               ; bswap ax = xor ax, ax
    expect eax, 12340000h
_
    retn
_c

_d

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

cpu_specifics:
; XSAVE, XGETBV XRSTOR, LZCNT are missing, I don't have a CPU supporting them
    setmsg_ %string:"ERROR: CPUID", 0dh, 0ah, 0
    mov eax, 0
    cpuid
    cmp eax, 0ah
    jl bad
    mov [cpuids + 0], ebx
    mov [cpuids + 4], edx
    mov [cpuids + 8], ecx
    print_ cpuidstr
_
    mov eax, 1
    cpuid
    mov [cpuid_ecx], ecx

    mov ecx, [cpuid_ecx]
    and ecx, 1 << 23
    jz no_popcnt
_
    setmsg_ %string:"ERROR: POPCNT", 0dh, 0ah, 0
    rdtsc
    mov ebx, 0100101010010b
    popcnt eax, ebx
    expect eax, 5
    jmp popcnt_end
no_popcnt:
    print_ %string:"Info: POPCNT not supported", 0dh, 0ah, 0
    jmp popcnt_end
popcnt_end:
_
    mov ecx, [cpuid_ecx]
    and ecx, 1 << 22
    jz no_movbe
_
    setmsg_ %string:"ERROR: MOVBE", 0dh, 0ah, 0
    mov ebx, _movbe                         ; [_movbe] = 11223344h
    rdtsc
    movbe eax, [ebx]
    expect eax, 44332211h
    jmp movbe_end
no_movbe:
    print_ %string:"Info: MOVBE not supported", 0dh, 0ah, 0
    jmp movbe_end
movbe_end:
_
    mov ecx, [cpuid_ecx]
    and ecx, 1 << 20
    jz no_crc32
_
    setmsg_ %string:"ERROR: CRC32", 0dh, 0ah, 0
    mov eax, 0abcdef9h
    mov ebx, 12345678h
    crc32 eax, ebx
    expect eax, 0c0c38ce0h
    jmp crc32_end
no_crc32:
    print_ %string:"Info: CRC32 not supported", 0dh, 0ah, 0
    jmp crc32_end
crc32_end:
_
    mov eax, 080000001h
    cpuid
    and edx, 1 << 27
    jz no_rdtscp
_
    setmsg_ %string:"ERROR: RDTSCP", 0dh, 0ah, 0
    rdtsc
    mov ebx, edx
    mov esi, eax
    rdtscp
    expect ebx, edx
    sub eax, esi
    cmp eax, 500h
    jle not_too_slow2
    print_ %string:"RDTSCP too far from RDTSC", 0dh, 0ah, 0
not_too_slow2:
    expect ecx, 0
    jmp rdtscp_end
no_rdtscp:
    print_ %string:"Info: RDTSCP not supported", 0dh, 0ah, 0
    jmp rdtscp_end
rdtscp_end:
_

    retn
_c

cpuid_ecx dd 0
_movbe dd 11223344h

cpuidstr db "Info: CPUID "
cpuids:
    dd 0, 0, 0
    db 0dh, 0ah, 0
;%strings
_d

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CONST equ 035603h
CONST8 equ 27h

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
    rdtsc
    mov al, CONST8
    db 0f6h, 0c8h
        db CONST8
    jz bad
_
    ; 'SAL' is technically the same as SHL, but different encoding
    setmsg_ %string:"ERROR: 'sal'", 0dh, 0ah, 0
    mov al, 1010b
    db 0c0h, 0f0h, 2                        ; sal al, 2
    expect al, 101000b
_
    retn
_c

;%strings
_d

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

XP_tests:
    setmsg_ %string:"ERROR: SMSW [XP]", 0dh, 0ah, 0
    smsw ax
    expect ax, 0003bh  ; XP
_
    ; smsw on dword is officially undocumented, but it just fills the whole CR0 to the operand
    setmsg_ %string:"ERROR: SMSW reg32 [undocumented, XP value]", 0dh, 0ah, 0
    smsw eax
    expect eax, 08001003bh  ; XP
_
    setmsg_ %string:"ERROR: SIDT [XP]", 0dh, 0ah, 0
    mov eax, sidt_
    sidt [eax]
    expect word [eax], 007ffh
_
    setmsg_ %string:"ERROR: SGDT (vm present?) [XP]", 0dh, 0ah, 0
    mov eax, sgdt_
    sgdt [eax]
    expect word [eax], 003ffh               ; TODO: 0412fh under vmware
_
    setmsg_ %string:"ERROR: STR reg16 (vm present?) [XP]", 0dh, 0ah, 0
    rdtsc
    str ax  ; 660F00C8
    expect ax, 00028h                  ; TODO: 04000h under vmware
_
    setmsg_ %string:"ERROR: STR reg32 (vm present?) [XP]", 0dh, 0ah, 0
    rdtsc
    str eax ; 0F00C8
    expect eax, 000000028h             ; TODO: 000004000h under vmware
_
    print_ %string:"Testing now: GS anti-debug (XP only)", 0dh, 0
    call gstrick   ; xp only ?
    print_ %string:"Testing now: SMSW anti-debug (XP only)", 0dh, 0
    call smswtrick ; xp only ?
_
    print_ %string:"Testing now: sysenter (XP only)", 0dh, 0
    setmsg_ %string:"ERROR: sysenter [XP]", 0dh, 0ah, 0
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
;    expect edx, [__imp__KiFastSystemCallRet]; -1 if stepping
    print_ ''
    retn
_c
; disabled, not <SP3 compatible IMPORT ntdll.dll!KiFastSystemCallRet
_c

W7_tests:
    setmsg_ %string:"ERROR: SMSW [W7]", 0dh, 0ah, 0
    smsw eax
    cmp eax, 080050031h  ; Win7 x64
_
    ; smsw on dword is officially undocumented, but it just fills the whole CR0 to the operand
    setmsg_ %string:"ERROR: SMSW reg32 [undocumented, W7 value]", 0dh, 0ah, 0
    smsw eax
    expect eax, 080050031h ; W7
_
    setmsg_ %string:"ERROR: SIDT [W7]", 0dh, 0ah, 0
    mov eax, sidt_
    sidt [eax]
    expect word [eax], 0fffh
_
    setmsg_ %string:"ERROR: SGDT [W7]", 0dh, 0ah, 0
    mov eax, sgdt_
    sgdt [eax]
    expect word [eax], 07fh
_
    setmsg_ %string:"ERROR: STR reg16 [W7]", 0dh, 0ah, 0
    str ax
    expect ax, 40h
    retn
_c

sgdt_ dd 0,0
sidt_ dd 0,0
os dd 0

;%strings
_d

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
    db 0fh, 0dh, 0c0h

    ; 0f 18 is a group
    prefetchnta [eax]                       ;0f18 00 000 000
    prefetcht0 [eax]                        ;0f18 00 001 000 (08)
    prefetcht1 [eax]                        ;0f18 00 010 000 (10)
    prefetcht2 [eax]                        ;0f18 00 011 000 (18)
    db 0fh, 018h, 100b << 3
    db 0fh, 018h, 101b << 3
    db 0fh, 018h, 110b << 3
    db 0fh, 018h, 111b << 3

_
    ; if OF is not set, this just does a nop - a tricky nop then
    into
_
    db 0fh, 1ch, 00                         ; nop [eax] ; doesn't trigger an exception
    db 0fh, 1fh, 00                         ; nop [eax] ; doesn't trigger an exception
    db 0fh, 1dh, 0c0h ; nop eax
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
_c

;%strings
_d
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

smswtrick:
waitfor3b:
    setmsg_ %string:"ANTI-DEBUG: SMSW - incorrect value after FPU", 0dh, 0ah, 0
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
    setmsg_ %string:"ANTI-DEBUG: incorrect value of GS", 0dh, 0ah, 0
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
    print_ %string:"ANTI-DEBUG: GS is not reset slowly enough", 0dh, 0ah, 0
GSgood:
    retn
_c

antis:
TF equ 0100h
    print_ %string:"Testing now: Trap flag", 0dh, 0
    ; checking if the Trap Flag is set via pushf (sahf doesn't save TF)
    pushf
    pop eax
    and eax, TF
    setmsg_ %string:"ANTI-DEBUG: TF is set", 0dh, 0ah, 0
    expect eax, 0
_
    ; the same, but 'pop ss' prevents the debugger to step on pushf
    print_ %string:"Testing now: Trap flag after pop ss", 0dh, 0
    setmsg_ %string:"ANTI-DEBUG: TF is set after pop ss", 0dh, 0ah, 0
    push ss
    pop ss
    pushf
    pop eax
    and eax, TF
    jnz bad
_
    ; anti-debug: rdtsc as a timer check
    print_ %string:"Testing now: RDTSC timer", 0dh, 0
    rdtsc
    mov ebx, eax
    mov ecx, edx
    rdtsc
    cmp eax, ebx
    jnz different_timers
    print_ %string:"ANTI-DEBUG: RDTSC timers identical...", 0dh, 0ah, 0
different_timers:
    sub eax, ebx
    cmp eax, 500h   ; taking a big limit for VMs, otherwise 100h sounds good enough.
    jle not_too_slow
    print_ %string:"ANTI-DEBUG: RDTSC too far from each other", 0dh, 0ah, 0
not_too_slow:

_
    retn
_c

;%strings
_d

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

get_ips:
    print_ %string:"Testing now: GetIP via Call/Pop", 0dh, 0
    setmsg_ %string:"ERROR: Wrong EIP via Call/pop", 0dh, 0ah, 0
    ; get ip call
    call $ + 5
after_call:
    pop eax
    expect eax, after_call
_
    ; get ip far call
    print_ %string:"Testing now: GetIP via Call FAR/Pop", 0dh, 0
    setmsg_ %string:"ERROR: Wrong EIP via Call FAR/pop", 0dh, 0ah, 0
    mov word [callfarcs + 5], cs
callfarcs:
    call far 0: $ + 7
after_far:
    pop eax
    expect eax, after_far
    pop eax
    push cs
    pop ecx
    expect eax, ecx
_
    ; get ip f?stenv
    print_ %string:"Testing now: GetIP via FSTENV", 0dh, 0
    setmsg_ %string:"ERROR: Wrong EIP via FPU", 0dh, 0ah, 0
_fpu:
    fnop
    fnstenv [fpuenv]              ; storing fpu environment
    mov eax,[fpuenv.DataPointer]  ; getting the EIP of last fpu operation
    expect eax, _fpu
    ; using the FPU will change internal flags such as cr0
_
    retn
_c

fpuenv:
    .ControlWord           dd 0
    .StatusWord            dd 0
    .TagWord               dd 0
    .DataPointer           dd 0
    .InstructionPointer    dd 0
    .LastInstructionOpcode dd 0
    dd 0

;%strings
_d

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ARRAY_BOUNDS_EXCEEDED equ 0C000008Ch
ILLEGAL_INSTRUCTION equ 0C000001Dh

%macro ints 2
%assign i %1
%rep    %2
;    _before
        int i
;    _after ACCESS_VIOLATION
%assign i i+1
%endrep
%endmacro

ints_handler:
    inc dword [counter]
    ; let's get the exception error
    mov edx, [esp + exceptionHandler.pException + 4]
    mov eax, [current_exception]
    cmp dword [edx], eax
    jnz bad

    mov edx, [esp + exceptionHandler.pContext + 4]
    movzx eax, byte [currentskip]
    add dword [edx + CONTEXT.regEip], eax

    mov eax, ExceptionContinueExecution
    retn

exceptions:
    print_ %string:"Setting Exception handler...", 0dh, 0
    setSEH ints_handler
_
    print_ %string:"Testing now: ACCESS VIOLATION exceptions triggers with Int 00-FF", 0dh, 0
    setmsg_ %string:"ERROR: INT 00-FF - no exception", 0dh, 0ah, 0
    mov dword [counter], 0
    mov dword [current_exception], ACCESS_VIOLATION
    mov dword [currentskip], 2
    ints 000h, 3
                ; int 003h = BREAKPOINT
                ; int 004h = INTEGER_OVERFLOW
    times 2*2 nop
    ; int 20 = sometimes shown as VXDCALL but triggering the same thing
    ; int 3b-3f = used by some emulators for FPU functions

    ints 005h, 02ah - 5
        ; int 02ah ; edx = ????????, eax = edx << 8 + ?? [step into next instruction]  / W7 : access violation
        ; int 02bh ; eax = C0000258 , ecx = 00000000 [step into next instruction]  / W7 : access violation
        ; int 02ch ; eax = C000014F, ecx = esp , edx = IP (if ran, not stepped) [step into next instruction] / W7: exception 0c0000420h
        ; int 02dh = see below
        ; int 02eh ; XP: eax = C0000xxx (depends on EAX before), ecx = esp , edx = IP (if ran, not stepped) [step into next instruction] / W7 : access violation
    times 2*5 nop
    ints 02fh, 0ffh - 02fh + 1
    expect dword [counter], 256 - 2 - 5
_
    ; int 2dh triggers a BREAKPOINT after if no debugger is present, under all OS
    print_ %string:"Testing now: BREAKPOINT with INT2D (no triggers if debugger present)", 0dh, 0
    setmsg_ %string:"ERROR: INT2D - no exception (debugger present ?)", 0dh, 0ah, 0
    mov dword [counter], 0
    mov dword [current_exception], BREAKPOINT
    mov dword [currentskip], 0  ; the exception is triggered AFTER
    int 02dh
    nop
    expect dword [counter], 1
_
    print_ %string:"Testing now: CPU-dependant exception triggers with too long instruction", 0dh, 0
    setmsg_ %string:"ERROR: >15 byte instruction - no exception", 0dh, 0ah, 0
    mov dword [counter], 0
    push dword [prefix_exception] ; ACCESS VIOLATION or ILLEGAL INSTRUCTION
    pop dword [current_exception]
    mov dword [currentskip], 17
    times 16 db 066h
        nop
        ; => access violation for too many prefixes (old anti-VirtualPC)
    expect dword [counter], 1
_
    print_ %string:"Testing now: INTEGER OVERFLOW with INTO", 0dh, 0
    setmsg_ %string:"ERROR: INTO - no exception", 0dh, 0ah, 0
    mov dword [counter], 0
    mov dword [current_exception], INTEGER_OVERFLOW
    mov dword [currentskip], 0 ; exception happens after
    mov al, 1
    ror al, 1
    into
    expect dword [counter], 1
_
    print_ %string:"Testing now: INTEGER OVERFLOW with INT 4", 0dh, 0
    setmsg_ %string:"ERROR: INT4 - no exception", 0dh, 0ah, 0
    mov dword [counter], 0
    mov dword [current_exception], INTEGER_OVERFLOW
    mov dword [currentskip], 0 ; instruction is 2 bytes, but happens *AFTER*
    int 4
    expect dword [counter], 1
_
    print_ %string:"Testing now: BREAKPOINT with INT3", 0dh, 0
    setmsg_ %string:"ERROR: INT3 - no exception", 0dh, 0ah, 0
    mov dword [counter], 0
    mov dword [current_exception], BREAKPOINT
    mov dword [currentskip], 1
    int3
    expect dword [counter], 1
_
    setmsg_ %string:"ERROR: INT 3 - no exception", 0dh, 0ah, 0
    mov dword [counter], 0
    print_ %string:"Testing now: BREAKPOINT with INT 3", 0dh, 0
    mov dword [currentskip], BREAKPOINT
    mov dword [currentskip], 1  ; instruction is 2 bytes, but it's reported as 'in the middle' of the opcode...
    int 3
    expect dword [counter], 1
_
    setmsg_ %string:"ERROR: ICEBP - no exception", 0dh, 0ah, 0
    mov dword [counter], 0
    print_ %string:"Testing now: SINGLE_STEP with 'undocumented' IceBP", 0dh, 0
    mov dword [current_exception], SINGLE_STEP
    mov dword [currentskip], 0
    db 0f1h ; IceBP
    expect dword [counter], 1
_
    setmsg_ %string:"ERROR: Trap Flag - no exception", 0dh, 0ah, 0
    mov dword [counter], 0
    print_ %string:"Testing now: SINGLE_STEP with setting TF via popf", 0dh, 0
    mov dword [current_exception], SINGLE_STEP
    mov dword [currentskip], 0
    pushf
    pop eax         ; EAX  = EFLAGS
    or eax, 100h    ; set TF
    push eax
    popf
    nop
    expect dword [counter], 1
_
    setmsg_ %string:"ERROR: Bound - no exception", 0dh, 0ah, 0
    mov dword [counter], 0
    print_ %string:"Testing now: ARRAY BOUNDS EXCEEDED with bounds", 0dh, 0
    mov dword [current_exception], ARRAY_BOUNDS_EXCEEDED
    mov dword [currentskip], 2
    mov ebx, $
    mov eax, -1
    bound eax, [ebx]
    expect dword [counter], 1
_
    setmsg_ %string:"ERROR: wrong opcode LOCK - no exception", 0dh, 0ah, 0
    mov dword [counter], 0
    print_ %string:"Testing now: CPU-dependant via incorrect bt", 0dh, 0
    push dword [lock_exception] ; INVALID LOCK SEQUENCE or ILLEGAL INSTRUCTION
    pop dword [current_exception]
    mov dword [currentskip], 4
    lock bt [eax], eax
    expect dword [counter], 1
_
    setmsg_ %string:"ERROR: invalid mode LOCK - no exception", 0dh, 0ah, 0
    mov dword [counter], 0
    print_ %string:"Testing now: INVALID LOCK SEQUENCE via incorrect mode access", 0dh, 0
    mov dword [currentskip], 3
    lock add eax, eax
    expect dword [counter], 1
_
    setmsg_ %string:"ERROR: invalid opcode LOCK - no exception", 0dh, 0ah, 0
    mov dword [counter], 0
    print_ %string:"Testing now: INVALID LOCK SEQUENCE via incorrect opcode", 0dh, 0
    mov dword [currentskip], 2
    lock wait
    expect dword [counter], 1
_
    setmsg_ %string:"ERROR: privileged instruction - no exception", 0dh, 0ah, 0
    mov dword [counter], 0
    print_ %string:"Testing now: PRIVILEGED_INSTRUCTION via privileged opcode", 0dh, 0
    mov dword [current_exception], PRIVILEGED_INSTRUCTION
    mov dword [currentskip], 1
    hlt
    expect dword [counter], 1
_
    setmsg_ %string:"ERROR: privileged instruction (vmware present?) - no exception", 0dh, 0ah, 0
    mov dword [counter], 0
    print_ %string:"Testing now: PRIVILEGED_INSTRUCTION via VmWare Backdoor", 0dh, 0
    mov dword [current_exception], PRIVILEGED_INSTRUCTION
    mov dword [currentskip], 1
    mov eax, 'hXMV'
    mov ecx, 10
    mov dx, 'XV'
    in eax, dx
    expect dword [counter], 1
_
    setmsg_ %string:"ERROR: privileged operand - no exception", 0dh, 0ah, 0
    mov dword [counter], 0
    print_ %string:"Testing now: PRIVILEGED_INSTRUCTION via privileged operand", 0dh, 0
    mov dword [current_exception], PRIVILEGED_INSTRUCTION
    mov dword [currentskip], 3
    mov eax, cr0
    expect dword [counter], 1
_
    clearSEH
    print_ ''
    retn
_c

lock_exception dd 0
prefix_exception dd 0
current_exception dd 0
currentskip db 0
counter dd 0

;%strings
_d

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


disassembly:
    ; the following lines are just to test common mistakes in output gather together for easy visual testing

    PREFIX_OPERANDSIZE
        bswap eax
    bswap eax

; branch hints
    PREFIX_BRANCH_TAKEN
        jz $ + 2
    PREFIX_BRANCH_NOT_TAKEN
        jnz $ + 2

; xor ecx, ecx
    loopne $

; str is only word in memory
    str eax
    str ax
    str [eax]

; smsw is not defined 16 bit, but actually reliable
    smsw eax
    smsw ax
    retn

    call word $ + 3
    db 66h
        retn
    db 66h
        loopz  $ - 1 ; looping to IP
    db 67h
        loopz $ - 1 ; looping depending on CX
    db 66h
    db 67h
        loopz $ - 2 ; looping depending on CX, to IP
    jecxz $
    jcxz $
    db 66h
        jecxz $ - 1
    db 66h
        jcxz $ - 1
    db 66h
        jmp $ + 2

    db 0f7h, 0c8h ; test eax, xx
        dd 0
    db 0f6h, 0c8h ; test al, xx
        db 0

    db 0f1h ; IceBP
    db 64h  ; mov edi, fs:esi
        movsd
    xlatb      ; reads from [EBX + AL]
    db 67h     ; reads from [BX + AL]
        xlatb
    db 0fh, 0ffh    ; ud0                   ;0fff

    ud1                                     ;0fb9
    ud2                                     ;0f0b
_c

;%strings
_d

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

%macro start64b 0
    %push _64b
    call far 33h:%$in64
    jmp %$next
_c
    bits 64
%$in64:
%endmacro

%macro end64b 0
    bits 32
    retf
_c
%$next:
    %pop
%endmacro

sixtyfour:
    setSEH no64b
    print_ %string:"Testing now: CDQE (64 bits only)", 0dh, 0
    setmsg_ %string:"ERROR: CDQE", 0dh, 0ah, 0
start64b
    mov rax, -1
    mov eax, 012345678h
    cdqe
    mov qword [cdqe_], rax
end64b

    expect dword [cdqe_], 012345678h
    expect dword [cdqe_ + 4], 0
_

    print_ %string:"Testing now: CQO (64 bits only)", 0dh, 0
    setmsg_ %string:"ERROR: CQO", 0dh, 0ah, 0
start64b
    mov rdx, 0
    mov rax, -35h
    cqo
    mov [cqo_], rdx
end64b
    expect dword [cqo_], -1
    expect dword [cqo_ + 4], -1
_

    print_ %string:"Testing now: CMPXCHG16 (64 bits only)", 0dh, 0
    setmsg_ %string:"ERROR: CMPXCHG16 (64 bits)", 0dh, 0ah, 0

start64b
    mov rax, 00a0a0a0a0a0a0a0ah
    mov rdx, 0d0d0d0d0d0d0d0d0h
    mov rcx, 099aabbcc99aabbcch
    mov rbx, 0ddeeff00ddeeff00h
    mov rsi, _cmpxchg16b                     ; [_cmpxchg16b] = 0d0d0d0d0d0d0d0d0h:00a0a0a0a0a0a0a0ah
    lock
        cmpxchg16b [rsi]
end64b
_
    print_ %string:"Testing now: RIP-relative GetIP (64 bits only)", 0dh, 0
    setmsg_ %string:"ERROR: RIP LEA (64 bits)", 0dh, 0ah, 0
start64b
    lea rax, [rip]
rip_:
    mov [rax_], rax
end64b
    expect dword [rax_], rip_
_
    print_ %string:"Testing now: MOVSXD (64 bits)", 0dh, 0
    setmsg_ %string:"ERROR: MOVSXD (64 bits)", 0dh, 0ah, 0
start64b
    mov bl, 80h
    mov rax, -1
    movsx eax, bl   ; al is copied to bl, eax is sign extended 32 bit, rax is zero extented to 64 bit => rax = 00000000ffffff80h
    movsxd rcx, eax
    mov qword [rax_], rax
    mov qword [rcx_], rcx
end64b
    expect dword [rax_], 0ffffff80h
    expect dword [rcx_], 0ffffff80h
    expect dword [rax_ + 4], 0
    expect dword [rcx_ + 4], -1
_

    print_ %string:"Testing now: 15 bytes lock add (64 bits)", 0dh, 0
    setmsg_ %string:"ERROR: 15 bytes LOCK ADD (64 bits)", 0dh, 0
    mov eax , 314159h
start64b
    lock add qword [cs:eax + eax*4 + lockadd - 314159h*5], 0efcdab89h ; F0:2E:67:4C:818480 01234567 89ABCDEF
end64b
    expect dword [lockadd], 0efcdab88h
    expect dword [lockadd + 4], -1
_

    print_ ''
sixtyfour_end:
    clearSEH
    retn
_c

no64b:
    print_ %string:"Info: 64 bits not supported", 0dh, 0ah, 0
    mov edx, [esp + exceptionHandler.pContext + 4]
    mov dword [edx + CONTEXT.regEip], sixtyfour_end
    mov eax, ExceptionContinueExecution
    retn
_c

_cmpxchg16b:
    dq 00a0a0a0a0a0a0a0ah
    dq 0d0d0d0d0d0d0d0d0h
cdqe_ dq -1
cqo_ dq 0
rax_ dq -1
rcx_ dq -1
lockadd dq -1

; just for reference, another 15 bytes operation, in 16 bits.
bits 16
lock add dword [cs: eax + ebx + 01234567h], 01234567h    ; 66:67:f0:2e:81 8418 67452301 efcdab89
bits 32

;%IMPORTS
_d

;%strings
_d

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE
SUBSYSTEM equ IMAGE_SUBSYSTEM_WINDOWS_CUI

;printing handler, for one opcode display operations - not perfect yet
;PRINTME equ 0fabecafeh
;
;printer:
;    mov edx, [esp + exceptionHandler.pContext + 4]
;    mov eax, [edx + CONTEXT.regEip]
;    cmp word [eax],  005c7h
;    cmp dword [eax + 2],  PRINTME
;    jnz not_print
;_
;    mov eax, [eax + 6]
;    push eax
;    call printnl
;
;    mov edx, [esp + exceptionHandler.pContext + 4]
;    add dword [edx + CONTEXT.regEip], 10
;
;    mov eax, ExceptionContinueExecution
;    retn
;_c
;not_print:
;    mov eax, 0
;    retn
