; A file that contains most x86 opcodes, including AVX, SSE, FPU...
; not complete yet
; compile with Yasm

bits 32

%define int1 db 0f1h

%define _  ;times 15 db 090h ;align 8, db 090h    ; turning on alignment makes yasm crawls...

;prefixes

%define PREFIX_FS db 64h
%define PREFIX_OPERANDSIZE db 66h
%define PREFIX_ADDRESSSIZE db 67h
%define PREFIX_BRANCH_TAKEN db 3eh
%define PREFIX_BRANCH_NOT_TAKEN db 2eh

jmp _start
_start:

; one byte, no arguments
    cwde                                    ;98
    cbw                                     ;6698
    cdq                                     ;99
    cwd                                     ;6699
_
    cmc                                     ;F5 complement carry flag
    stc                                     ;F9 set carry flag
    clc                                     ;F8 clear carry flag
_
    cli                                     ;FA clear interruption flag
    sti                                     ;FB set interruption flag
_
    cld                                     ;FC clear direction flag
    std                                     ;FD set direction flag
_
    setalc                                  ;D6 setalc/salc, set al on carry, undocumented
    salc
_
    xlat                                    ;D7 table lookup translation
    xlatb
_
    leave                                   ;C9 high-level procedure exit
_
    int1                                    ;F1 ICE BreakPoint/INT01, undocumented = icebp
    int 1                                   ;CD 01
    int3                                    ;CC interruption 3 (not 'int 3')
    int 3                                   ;CD 03
_
    into                                    ;CE interruption if overflow flag is set
_
    iretd                                   ;CF interruption return
    iretw                                   ;66CF
    iret                                    ;66CF grammar stuff
_
    ret                                     ;C3 return
    retn 01234h                             ;C2 xxxx return near
    db 0c2h, 0,0                            ;C2 is synonym of C3 retn but usually simplified by assemblers
    retf 01234h                             ;CA xxxx return far
    retf                                    ;cb
_
    hlt                                     ;F4 halt
_
    lahf                                    ;9F Load Flags into AH Register, (C P A Z only)
    sahf                                    ;9E Store AH into Flags
_
    pushfd                                  ;9C push flags register
    popfd                                   ;9D pop flags register
    pushf                                   ;669C
    popf                                    ;669D
_
    ; pusha is default mode pushaw/pushad. same for popa
    pushaw                                  ;6660 specificly word
    pushad                                  ;60 specificly dword
    pusha                                   ;60? depends on the assembler
    popad                                   ;61
    popaw                                   ;6661
    popa                                    ;6661
_
    daa                                     ;27 Decimal Adjust AL after Addition, BCD digits operation
    aaa                                     ;37 Adjust AL after Addition, BCD digits operation
    das                                     ;2F Decimal Adjust AL after Substraction, BCD digits operation
    aas                                     ;3F Adjust AL after Subtraction, BCD digits operation
_
    ; mnemonic with an argument, but no separate byte in hex encoding
    ; standard register order : ax, cx, dx, bx, sp, bp, si, di
    push eax                                ;50
    push ecx                                ;51
    push edx                                ;52
    push ebx                                ;53
    push esp                                ;54
    push ebp                                ;55
    push esi                                ;56
    push edi                                ;57
_
    pop eax                                 ;58
    pop ecx                                 ;59
    pop edx                                 ;5A
    pop ebx                                 ;5B
    pop esp                                 ;5C
    pop ebp                                 ;5D
    pop esi                                 ;5E
    pop edi                                 ;5F
_
    push dword [eax]                        ;ff30
    pop dword [eax]                         ;8f00
_
    ; standard segment order: es, cs, ss, ds
    push es                                 ;06
    push cs                                 ;0E
    push ss                                 ;16
    push ds                                 ;1E
_
    pop es                                  ;07
    ; no pop cs
    pop ss                                  ;17
    pop ds                                  ;1F
_
    push 0                                  ;6a 00
    push 01234578h                          ;68 00000000
_
    push fs                                 ;0fa0
    pop fs                                  ;0fa1
    push gs                                 ;0fa8
    pop gs                                  ;0fa9
_
    inc eax                                 ;40
    inc ecx                                 ;41
    inc edx                                 ;42
    inc ebx                                 ;43
    inc esp                                 ;44
    inc ebp                                 ;45
    inc esi                                 ;46
    inc edi                                 ;47
    dec eax                                 ;48
    dec ecx                                 ;49
    dec edx                                 ;4a
    dec ebx                                 ;4b
    dec esp                                 ;4c
    dec ebp                                 ;4d
    dec esi                                 ;4e
    dec edi                                 ;4f
    inc byte [eax]                          ;fe00
    inc dword [eax]                         ;ff00
    dec byte [eax]                          ;fe08
    dec dword [eax]                         ;ff08
_
    ;8 bit register fixed by the opcode byte
    ;a-c-d-b as usual, low then high
    mov al, 0                               ;B0 xx mov
    mov cl, 0                               ;B1 xx mov
    mov dl, 0                               ;B2 xx mov
    mov bl, 0                               ;B3 xx mov
    mov ah, 0                               ;B4 xx mov
    mov ch, 0                               ;B5 xx mov
    mov dh, 0                               ;B6 xx mov
    mov bh, 0                               ;B7 xx mov
    test al, 0ffh                           ;A8 xx
_
    in al, 0ffh                             ;E4 xx
    in eax, 0ffh                            ;E5 xx
    in al, dx                               ;ec
    in eax, dx                              ;ed

_
    ;for the out opcode, the literal is the 1st operand
    out 0ffh, al                            ;E6 xx
    out 0ffh, eax                           ;E7 xx
    out dx, al                              ;ee
    out dx, eax                             ;ef
_
    loop   $ + 2                            ;e2 xx decrement ecx then jump if ecx is not null
    loope  $ + 2      ;=loopz               ;e1 xx decrement ecx then jump if ecx is not null and Z is set
    loopne $ + 2      ;=loopnz              ;e0 xx decrement ecx then jump if ecx is not null and Z is not set
    ;same thing, on cx (loopw for some disassembler)
    PREFIX_OPERANDSIZE
    loop   $ + 2                            ;67e2 xx decrement ?ecx then jump if ?cx is not null
    PREFIX_OPERANDSIZE
    loope $ + 2                             ;67e0 xx decrement ?ecx then jump if ?cx is not null and Z is not set
    PREFIX_OPERANDSIZE
    loopne $ + 2                            ;67e0 xx decrement ?ecx then jump if ?cx is not null and Z is not set
_
    jecxz  $ + 2                            ;e3 xx jump if ecx is null
    jcxz  $ + 2                             ;e3 xx jump if cx is null
_
    ; 2 arguments, one immediate word, one immediate byte, Iw/Ib in Intel docs
    enter 03141h,059h                       ;C8 dw0, db1
_
    ; AAM/AAD are usually rendered differently, by default it's a 10 0xA division
    ; so some assemblers like MASM don't accept an argument
    aam                                     ;d4 0a
    aam 255                                 ;d4 xx
    aad                                     ;d5 0a
    aad 255                                 ;d5 xx
    adx                                     ;d4 TODO
    amx                                     ;d5 TODO
_
    adc [eax], al                           ;10 xx add + carry
    adc [eax], eax                          ;11 xx add + carry
    adc al, [eax]                           ;12 xx add + carry
    adc eax, [eax]                          ;13 xx add + carry
    adc eax, 012345678h                     ;13 xx add + carry
    adc al, 0                               ;14 xx add + carry
    add [eax], al                           ;00 xx add
    add [eax], eax                          ;01 xx add
    add al, [eax]                           ;02 xx add
    add eax, [eax]                          ;03 xx add
    add eax, 012345678h                     ;03 xx add
    add al, 0                               ;04 xx add
    add byte [eax], 0x0                     ;8000 00
    add dword [eax], 0x0                    ;8100 00000000
    add byte [eax], 0x0                     ;8200 00    TODO enforce encoding
    add dword [eax], 0x0                    ;8300 00 TODO enforce encoding
    and [eax], al                           ;20 xx logical and
    and [eax], eax                          ;21 xx logical and
    and al, [eax]                           ;22 xx logical and
    and eax, [eax]                          ;23 xx logical and
    and eax, 012345678h                     ;23 xx logical and
    and al, 0                               ;24 xx logical and
    cmp [eax], al                           ;38 xx compare
    cmp [eax], eax                          ;39 xx compare
    cmp al, [eax]                           ;3a xx compare
    cmp eax, [eax]                          ;3b xx compare
    cmp eax, 012345678h                     ;3b xx compare
    cmp al, 0                               ;3c xx compare
    mov [eax], al                           ;8800
    mov [eax], eax                          ;8900
    mov al, [eax]                           ;8a00
    mov al, [0x0]                           ;a0 00000000
    mov eax, [0x0]                          ;a1 00000000
    mov [0x0], al                           ;a2 00000000
    mov [0x0], eax                          ;a3 00000000 ; enforce
    mov al, 0x0                             ;b0 00
    mov cl, 0x0                             ;b1 00
    mov dl, 0x0                             ;b2 00
    mov bl, 0x0                             ;b3 00
    mov ah, 0x0                             ;b4 00
    mov ch, 0x0                             ;b5 00
    mov dh, 0x0                             ;b6 00
    mov bh, 0x0                             ;b7 00
    mov eax, 0x0                            ;b8 00000000
    mov ecx, 0x0                            ;b9 00000000
    mov edx, 0x0                            ;ba 00000000
    mov ebx, 0x0                            ;bb 00000000
    mov esp, 0x0                            ;bc 00000000
    mov ebp, 0x0                            ;bd 00000000
    mov esi, 0x0                            ;be 00000000
    mov edi, 0x0                            ;bf 00000000
    or  [eax], al                           ;08 xx logical or
    or  [eax], eax                          ;09 xx logical or
    or  eax, 012345678h                     ;0b xx logical or
    or  eax, [eax]                          ;0b xx logical or
    or  al, 0                               ;0c xx logical or
    sbb [eax], al                           ;18 xx substract - carry
    sbb [eax], eax                          ;19 xx substract - carry
    sbb al, [eax]                           ;1a xx substract - carry
    sbb eax, 012345678h                     ;1b xx substract - carry
    sbb eax, [eax]                          ;1b xx substract - carry
    sbb al, 0                               ;1c xx substract - carry
    sub [eax], al                           ;28 xx substract
    sub [eax], eax                          ;29 xx substract
    sub al, [eax]                           ;2a xx substract
    sub eax, [eax]                          ;2b xx substract
    sub eax, 012345678h                     ;2b xx substract
    sub al, 0                               ;2c xx substract
    test [eax], al                          ;8400
    test [eax], eax                         ;8500
    test al, 0x0                            ;a8 00
    test eax, 0x0                           ;a9 00000000
    test byte [eax], 0x0                    ;f600 00
    test dword [eax], 0x0                   ;f700 00000000
    xchg [eax], al                          ;8600
    xchg [eax], eax                         ;8700
    xor [eax], al                           ;30 xx logical xor
    xor [eax], eax                          ;31 xx logical xor
    xor al, [eax]                           ;32 xx logical xor
    xor eax, [eax]                          ;33 xx logical xor
    xor eax, 012345678h                     ;33 xx logical xor
    xor al, 0                               ;34 xx logical xor
_
    ;Jz
    call 012345678h                         ;e8
    call far 0x0:0x0                        ;9a 00000000 0000 = callf
    call [eax]                              ;ff10
    call far [eax]                          ;ff18
    jmp short $ + 2                         ;eb
    jmp near $ + 5                          ;e9
    jmp far 0x0:0x0                         ;ea 00000000 0000 = jmpf
    jmp [eax]                               ;ff20
    jmp far [eax]                           ;ff28
_
    clts                                    ;0f06
_
    loadall                                 ;0f07
_
;   getsec                                  ;0f37 not in yasm
    db 0fh, 37h,
_
    cpuid                                   ;0fa2
_
    push    fs                              ;0fa0
    pop     fs                              ;0fa1
    push    gs                              ;0fa8
    pop     gs                              ;0fa9
_
    invd                                    ;0f08
    wbinvd                                  ;0f09
_
    vmcall                                  ;0f01 c1
    vmlaunch                                ;0f01 c2
    vmresume                                ;0f01 c3
    vmxoff                                  ;0f01 c4
_
    monitor                                 ;0f01 c8
    mwait                                   ;0f01 c9
_
    xgetbv                                  ;0f01 d0
    xsetbv                                  ;0f01 d1
_
    vmrun                                   ;0f01 d8
    vmmcall                                 ;0f01 d9
    vmload                                  ;0f01 da
    vmsave                                  ;0f01 db
_
    stgi                                    ;0f01 dc
    clgi                                    ;0f01 dd
_
    skinit                                  ;0f01 de
_
    invlpga                                 ;0f01 df
_
    pause                                   ;f390
_
    vmread  [eax],eax                       ;0f78 00
    vmwrite eax, dword [eax]                ;0f79 00
_
    rdtscp                                  ;0f01 f9
_
    lar eax, [eax]                          ;0f02
    lsl eax, [eax]                          ;0f03
_
    movups xmm0, [eax]                      ;0f10
    movups [eax], xmm0                      ;0f11
_
_
    unpcklps xmm0, [eax]                    ;0f14
    unpckhps xmm0, [eax]                    ;0f15
_
    movlps xmm0, [eax]                      ;0f12
    movlps [eax], xmm0                      ;0f13
    movhlps xmm0, xmm0                      ;0f12
    movlhps xmm0, xmm0                      ;0f16
    movhps xmm0, [eax]                      ;0f16
    movhps [eax], xmm0                      ;0f17
_
    mov eax, cr0                            ;0f20 ??
    mov eax, dr0                            ;0f21 ??
    mov cr0, eax                            ;0f22 ??
    mov dr0, eax                            ;0f23
_
    movmskps eax, xmm0                      ;0f50c0
    movmskpd eax, xmm0                      ;660f50 c0
_
    pavgb mm0, [eax]                        ;0fe0
_
    popcnt eax , [eax]                      ;0fb8
_
    crc32 eax, byte [eax]                   ;f20f 38 f0
    crc32 eax, [eax]                        ;f20f 38 f1
_
    syscall                                 ;0f05 64b only ?
    sysret                                  ;0f07 64b only ?
_
    clts                                    ;0f06
_
    invd                                    ;0f08
    wbinvd                                  ;0f09
_
    ud2                                     ;0f0b
_
    prefetch [eax]                          ;0f0d00
    prefetchnta [eax]                       ;0f1800
    prefetcht0 [eax]                        ;0f18 08
    prefetcht1 [eax]                        ;0f18 10
    prefetcht2 [eax]                        ;0f18 18
_
    movaps xmm0, dqword [eax]               ;0f2800
    movaps dqword [eax], xmm0               ;0f2900
_
    movntps dqword [eax], xmm0              ;0f2b00
    movntsd qword [eax], xmm0               ;f20f2b00
    movntpd dqword [eax], xmm0              ;660f2b00
    movntss dword [eax], xmm0               ;f30f2b00
_
    ucomiss xmm0, dword [eax]               ;0f2e00
    comiss xmm0, dword [eax]                ;0f2f00
    ucomisd xmm0, qword [eax]               ;660f2e00
    comisd xmm0, qword [eax]                ;660f2f00
_
    wrmsr                                   ;0f30
    rdtsc                                   ;0f31
    rdmsr                                   ;0f32
    rdpmc                                   ;0f33
_
    sysenter                                ;0f34
    sysexit                                 ;0f35
_
    sqrtps xmm0, dqword [eax]               ;0f5100
    sqrtpd xmm0, dqword [eax]               ;660f5100
    sqrtsd xmm0, qword [eax]                ;f20f5100
    sqrtss xmm0, dword [eax]                ;f30f5100
    rsqrtps xmm0, dqword [eax]              ;0f5200
    rsqrtss xmm0, dword [eax]               ;f30f5200
_
    rcpps xmm0, dqword [eax]                ;0f5300
    rcpss xmm0, dword [eax]                 ;f30f5300
_
    andps xmm0, dqword [eax]                ;0f5400
    andnps xmm0, dqword [eax]               ;0f5500
    andpd xmm0, [eax]                       ;660f54
    andnpd xmm0, [eax]                      ;660f55
_
    orps xmm0, dqword [eax]                 ;0f5600
    xorps xmm0, dqword [eax]                ;0f5700
    orpd xmm0, dqword [eax]                 ;660f5600
    xorpd xmm0, dqword [eax]                ;660f5700
_
    addps xmm0, dqword [eax]                ;0f5800
    subps xmm0, dqword [eax]                ;0f5c00
    mulps xmm0, dqword [eax]                ;0f5900
    divps xmm0, dqword [eax]                ;0f5e00
    addpd xmm0, dqword [eax]                ;660f5800
    subpd xmm0, dqword [eax]                ;660f5c00
    mulpd xmm0, dqword [eax]                ;660f5900
    divpd xmm0, dqword [eax]                ;660f5e00
_
    minps xmm0, dqword [eax]                ;0f5d00
    maxps xmm0, dqword [eax]                ;0f5f00
    minpd xmm0, dqword [eax]                ;660f5d00
    maxpd xmm0, dqword [eax]                ;660f5f00
    minsd xmm0, qword [eax]                 ;f20f5d00
    maxsd xmm0, qword [eax]                 ;f20f5f00
    minss xmm0, dword [eax]                 ;f30f5d00
    maxss xmm0, dword [eax]                 ;f30f5f00
_
    punpcklbw mm0, qword [eax]              ;0f6000
    punpcklwd mm0, qword [eax]              ;0f6100
    punpckldq mm0, qword [eax]              ;0f6200
    punpcklbw xmm0, dqword [eax]            ;660f6000
    punpcklwd xmm0, dqword [eax]            ;660f6100
    punpckldq xmm0, dqword [eax]            ;660f6200
_
    packsswb mm0, qword [eax]               ;0f6300
    packuswb mm0, qword [eax]               ;0f6700
    packsswb xmm0, dqword [eax]             ;660f6300
    packuswb xmm0, dqword [eax]             ;660f6700
_
    pcmpgtb mm0, qword [eax]                ;0f6400
    pcmpgtw mm0, qword [eax]                ;0f6500
    pcmpgtd mm0, qword [eax]                ;0f6600
    pcmpgtb xmm0, dqword [eax]              ;660f6400
    pcmpgtw xmm0, dqword [eax]              ;660f6500
    pcmpgtd xmm0, dqword [eax]              ;660f6600
_
    punpckhbw mm0, qword [eax]              ;0f6800
    punpckhwd mm0, qword [eax]              ;0f6900
    punpckhdq mm0, qword [eax]              ;0f6a00
    punpckhbw xmm0, dqword [eax]            ;660f6800
    punpckhwd xmm0, dqword [eax]            ;660f6900
    punpckhdq xmm0, dqword [eax]            ;660f6a00
_
    packssdw mm0, qword [eax]               ;0f6b00
    packssdw xmm0, dqword [eax]             ;660f6b00
_
    pshufb mm0, qword [eax]                 ;0f380000
    pshufw mm0, qword [eax], 0x0            ;0f700000
    pshufb xmm0, dqword [eax]               ;660f380000
    pshufd xmm0, dqword [eax], 0x0          ;660f700000
    pshuflw xmm0, dqword [eax], 0x0         ;f20f700000
    pshufhw xmm0, dqword [eax], 0x0         ;f30f7000 00
_
    pcmpeqb mm0, qword [eax]                ;0f7400
    pcmpeqw mm0, qword [eax]                ;0f7500
    pcmpeqd mm0, qword [eax]                ;0f7600
    pcmpeqb xmm0, dqword [eax]              ;660f7400
    pcmpeqw xmm0, dqword [eax]              ;660f7500
    pcmpeqd xmm0, dqword [eax]              ;660f7600
_
    emms                                    ;0f77
    femms                                   ;0f0e
    cpuid                                   ;0fa2
    rsm                                     ;0faa
_
    movd mm0, dword [eax]                   ;0f6e00
    movq mm0, qword [eax]                   ;0f6f00
    movd dword [eax], mm0                   ;0f7e00
    movq qword [eax], mm0                   ;0f7f00
    movd xmm0, dword [eax]                  ;660f6e00
    movdqa xmm0, dqword [eax]               ;660f6f00
    movd dword [eax], xmm0                  ;660f7e00
    movdqa dqword [eax], xmm0               ;660f7f00
    movdqu xmm0, dqword [eax]               ;f30f6f00
    movq xmm0, qword [eax]                  ;f30f7e00
    movdqu dqword [eax], xmm0               ;f30f7f00
_
    bt [eax], eax                           ;0fa300
    bts [eax], eax                          ;0fab00
    btr [eax], eax                          ;0fb300
_
    shld [eax], eax, 0x0                    ;0fa400 00
    shld [eax], eax, cl                     ;0fa500
    shrd [eax], eax, 0x0                    ;0fac00 00
    shrd [eax], eax, cl                     ;0fad00
_
    fxsave [eax]                            ;0fae00
_
    cmpxchg [eax], al                       ;0fb000
    cmpxchg [eax], eax                      ;0fb100
    cmpxchg8b [eax]                         ;0fc7c0
    lock cmpxchg8b [eax]                    ;f00fc7c0 famous for crashing pentiums
_
    vmptrld [eax]                           ;0fc730
    vmclear [eax]                           ;660fc730
    vmxon [eax]                             ;f30fc730
    vmptrst [eax]                           ;0fc738
_
    lss eax, dword [eax]                    ;0fb200
    lfs eax, dword [eax]                    ;0fb400
    lgs eax, dword [eax]                    ;0fb500
_
    movzx eax, byte [eax]                   ;0fb600
    movzx eax, word [eax]                   ;0fb700
_
    ud2                                     ;0fb9
_
    btc [eax], eax                          ;0fbb00
_
    bsf eax, [eax]                          ;0fbc00
    bsr eax, [eax]                          ;0fbd00
_
    movsx eax, byte [eax]                   ;0fbe00
    movsx eax, word [eax]                   ;0fbf00
_
    xadd [eax], al                          ;0fc000
    xadd [eax], eax                         ;0fc100
_
    movnti [eax], eax                       ;0fc300
_
    pinsrw mm0, word [eax], 0x0             ;0fc400 00
    pinsrw xmm0, word [eax], 0x0            ;660fc400 00
    pextrw eax, mm0, 0                      ;0fc5c000
    pextrw eax, xmm0, 0                     ;660fc5c000
    pextrb eax, xmm0, 0                     ;660f3a14c000
    pextrd eax, xmm0, 0                     ;660f3a16c000
_
    shufps xmm0, dqword [eax], 0x0          ;0fc600 00
_
    bswap eax                               ;0fc8
    bswap ecx                               ;0fc9
    bswap edx                               ;0fca
    bswap ebx                               ;0fcb
    bswap esp                               ;0fcc
    bswap ebp                               ;0fcd
    bswap esi                               ;0fce
    bswap edi                               ;0fcf
_
    PREFIX_OPERANDSIZE                      ;660fce
    bswap eax ; xor ax, ax : result officially undefined, actually typically 0
_
    psubusb mm0, qword [eax]                ;0fd800
    psubusw mm0, qword [eax]                ;0fd900
_
    pand mm0, qword [eax]                   ;0fdb00
    pandn mm0, qword [eax]                  ;0fdf00
    por mm0, qword [eax]                    ;0feb00
    pxor mm0, qword [eax]                   ;0fef00
_
    paddusb mm0, qword [eax]                ;0fdc00
    paddusw mm0, qword [eax]                ;0fdd00
_
    pmaxub mm0, qword [eax]                 ;0fde00
    pminub mm0, qword [eax]                 ;0fda00
_
    pavgb mm0, qword [eax]                  ;0fe000
    pavgw mm0, qword [eax]                  ;0fe300
_
    movntq qword [eax], mm0                 ;0fe700
    movntdq dqword [eax], xmm0              ;660fe700
_
    psubsb mm0, qword [eax]                 ;0fe800
    psubsw mm0, qword [eax]                 ;0fe900
_
    pminsw mm0, qword [eax]                 ;0fea00
    pmaxsw mm0, qword [eax]                 ;0fee00
_
    paddsb mm0, qword [eax]                 ;0fec00
    paddsw mm0, qword [eax]                 ;0fed00
_
    psraw mm0, qword [eax]                  ;0fe100
    psrad mm0, qword [eax]                  ;0fe200
    psraw xmm0, dqword [eax]                ;660fe100
    psrad xmm0, dqword [eax]                ;660fe200
    psraw mm0, 0                            ;0f71e000
    psrad mm0, 0                            ;0f72e000
    psraw xmm0, 0                           ;660f71e000
    psrad xmm0, 0                           ;660f72e000
_
    psrlw mm0, 0                            ;0f71d000
    psrld mm0, 0                            ;0f72d000
    psrlq mm0, 0                            ;0f73d000
    psllw mm0, 0                            ;0f71f000
    pslld mm0, 0                            ;0f72f000
    psllq mm0, 0                            ;0f73f000
    psrlw xmm0, 0                           ;660f71d000
    psrld xmm0, 0                           ;660f72d000
    psrlq xmm0, 0                           ;660f73d000
    psllw xmm0, 0                           ;660f71f000
    pslld xmm0, 0                           ;660f72f000
    psllq xmm0, 0                           ;660f73f000
    psrldq xmm0, 0                          ;660f73d800
    pslldq xmm0, 0                          ;660f73f800

    psrlw mm0, qword [eax]                  ;0fd100
    psrld mm0, qword [eax]                  ;0fd200
    psrlq mm0, qword [eax]                  ;0fd300
    psrlw xmm0, dqword [eax]                ;660fd100
    psrld xmm0, dqword [eax]                ;660fd200
    psrlq xmm0, dqword [eax]                ;660fd300
    psllw mm0, qword [eax]                  ;0ff100
    pslld mm0, qword [eax]                  ;0ff200
    psllq mm0, qword [eax]                  ;0ff300
    psllw xmm0, dqword [eax]                ;660ff100
    pslld xmm0, dqword [eax]                ;660ff200
    psllq xmm0, dqword [eax]                ;660ff300
_
    pmullw mm0, qword [eax]                 ;0fd500
    pmullw xmm0, dqword [eax]               ;660fd500
    pmulhuw mm0, qword [eax]                ;0fe400
    pmulhuw xmm0, dqword [eax]              ;660fe400
    pmulhw mm0, qword [eax]                 ;0fe500
    pmulhw xmm0, dqword [eax]               ;660fe500
    pmuludq mm0, qword [eax]                ;0ff400
    pmuludq xmm0, dqword [eax]              ;660ff400
_
    pmaddwd mm0, qword [eax]                ;0ff500
    pmaddwd xmm0, dqword [eax]              ;660ff500
    psadbw mm0, qword [eax]                 ;0ff600
    psadbw xmm0, dqword [eax]               ;660ff600
_
    maskmovq mm0, mm0                       ;0ff7
    maskmovdqu xmm0, xmm0                   ;660ff7
    pmovmskb eax, mm0                       ;0fd7
_
    psubb mm0, qword [eax]                  ;0ff800
    psubw mm0, qword [eax]                  ;0ff900
    psubd mm0, qword [eax]                  ;0ffa00
    psubq mm0, qword [eax]                  ;0ffb00
_
    paddb mm0, qword [eax]                  ;0ffc00
    paddw mm0, qword [eax]                  ;0ffd00
    paddd mm0, qword [eax]                  ;0ffe00
    paddq mm0, qword [eax]                  ;0ffe00
_
    bound eax, [eax]                        ;6200
_
    arpl [eax], ax                          ;6300
_
    movupd xmm0, dqword [eax]               ;660f1000
    movupd dqword [eax], xmm0               ;660f1100
_
    movlpd xmm0, qword [eax]                ;660f1200
    movlpd qword [eax], xmm0                ;660f1300
_
    unpcklpd xmm0, dqword [eax]             ;660f1400
    unpckhpd xmm0, dqword [eax]             ;660f1500
_
    movhpd xmm0, qword [eax]                ;660f1600
    movhpd qword [eax], xmm0                ;660f1700
_
    movapd xmm0, dqword [eax]               ;660f2800
    movapd dqword [eax], xmm0               ;660f2900
_
    punpcklqdq xmm0, dqword [eax]           ;660f6c00
    punpckhqdq xmm0, dqword [eax]           ;660f6d00
_
    extrq xmm0, 0x0, 0x0                    ;660f7800 00 00
    extrq xmm0, xmm0                        ;660f7900
_
    haddpd xmm0, dqword [eax]               ;660f7c00
    hsubpd xmm0, dqword [eax]               ;660f7d00
    haddps xmm0, dqword [eax]               ;f20f7c00
    hsubps xmm0, dqword [eax]               ;f20f7d00
_
    shufpd xmm0, dqword [eax], 0x0          ;660fc600 00
_
    addsubpd xmm0, dqword [eax]             ;660fd000
_
    paddq xmm0, dqword [eax]                ;660fd400
_
    movq qword [eax], xmm0                  ;660fd600
    movdq2q mm0, xmm0                       ;f20fd6
    movq2dq xmm0, mm0                       ;f30fd6
_
    psubusb xmm0, dqword [eax]              ;660fd800
    psubusw xmm0, dqword [eax]              ;660fd900
_
    pminub xmm0, dqword [eax]               ;660fda00
    pmaxub xmm0, dqword [eax]               ;660fde00
_
    pand xmm0, dqword [eax]                 ;660fdb00
    pandn xmm0, dqword [eax]                ;660fdf00
_
    paddusb xmm0, dqword [eax]              ;660fdc00
    paddusw xmm0, dqword [eax]              ;660fdd00
_
    pavgb xmm0, dqword [eax]                ;660fe000
    pavgw xmm0, dqword [eax]                ;660fe300
_
    psubsb xmm0, dqword [eax]               ;660fe800
    psubsw xmm0, dqword [eax]               ;660fe900
_
    pminsw xmm0, dqword [eax]               ;660fea00
    pmaxsw xmm0, dqword [eax]               ;660fee00
_
    por xmm0, dqword [eax]                  ;660feb00
_
    paddsb xmm0, dqword [eax]               ;660fec00
    paddsw xmm0, dqword [eax]               ;660fed00
_
    pxor xmm0, dqword [eax]                 ;660fef00
_
    psubb xmm0, dqword [eax]                ;660ff800
    psubw xmm0, dqword [eax]                ;660ff900
    psubd xmm0, dqword [eax]                ;660ffa00
    psubq xmm0, dqword [eax]                ;660ffb00
_
    paddb xmm0, dqword [eax]                ;660ffc00
    paddw xmm0, dqword [eax]                ;660ffd00
    paddd xmm0, dqword [eax]                ;660ffe00
    paddq xmm0, dqword [eax]                ;660ffe00
_
    imul eax, [eax], 012345678h             ;690000000000
    imul eax, [eax], 0                      ;6b0000
    imul eax, [eax]                         ;0faf00
_
    insb                                    ;6c
    insd                                    ;6d
_
    outsb                                   ;6e
    outsd                                   ;6f
_
; FLAGS
; b = c = nae
; nb = nc = ae
; z = e
; nz = ne
; be = na
; nbe = a
; p = jpe
; np = po
; l = nge
; nl = ge
; le = ng
; nle = g

    jo $ + 2                                ;70 00
    jno $ + 2                               ;71 00
    jb  $ + 2                               ;72 00
    jae $ + 2                               ;73 00
    jz  $ + 2                               ;74 00
    jnz $ + 2                               ;75 00
    jbe $ + 2                               ;76 00
    ja  $ + 2                               ;77 00
    js  $ + 2                               ;78 00
    jns $ + 2                               ;79 00
    jp  $ + 2                               ;7a 00
    jnp $ + 2                               ;7b 00
    jl  $ + 2                               ;7c 00
    jge $ + 2                               ;7d 00
    jle $ + 2                               ;7e 00
    jg  $ + 2                               ;7f 00
_
    jo  dword $ + 6                         ;0f80 00000000
    jno dword $ + 6                         ;0f81 00000000
    jb  dword $ + 6                         ;0f82 00000000
    jae dword $ + 6                         ;0f83 00000000
    jz  dword $ + 6                         ;0f84 00000000
    jnz dword $ + 6                         ;0f85 00000000
    jbe dword $ + 6                         ;0f86 00000000
    ja  dword $ + 6                         ;0f87 00000000
    js  dword $ + 6                         ;0f88 00000000
    jns dword $ + 6                         ;0f89 00000000
    jp  dword $ + 6                         ;0f8a 00000000
    jnp dword $ + 6                         ;0f8b 00000000
    jl  dword $ + 6                         ;0f8c 00000000
    jge dword $ + 6                         ;0f8d 00000000
    jle dword $ + 6                         ;0f8e 00000000
    jg  dword $ + 6                         ;0f8f 00000000
_
    seto [eax]                              ;660f9000
    setno [eax]                             ;660f9100
    setb [eax]                              ;660f9200
    setae [eax]                             ;660f9300
    setz [eax]                              ;660f9400
    setnz [eax]                             ;660f9500
    setbe [eax]                             ;660f9600
    seta [eax]                              ;660f9700
    sets [eax]                              ;660f9800
    setns [eax]                             ;660f9900
    setp [eax]                              ;660f9a00
    setnp [eax]                             ;660f9b00
    setl [eax]                              ;660f9c00
    setge [eax]                             ;660f9d00
    setle [eax]                             ;660f9e00
    setg [eax]                              ;660f9f00
_
    cmovo eax, [eax]                        ;0f4000
    cmovno eax, [eax]                       ;0f4100
    cmovb eax, [eax]                        ;0f4200
    cmovae eax, [eax]                       ;0f4300
    cmovz eax, [eax]                        ;0f4400
    cmovnz eax, [eax]                       ;0f4500
    cmovbe eax, [eax]                       ;0f4600
    cmova eax, [eax]                        ;0f4700
    cmovs eax, [eax]                        ;0f4800
    cmovns eax, [eax]                       ;0f4900
    cmovp eax, [eax]                        ;0f4a00
    cmovnp eax, [eax]                       ;0f4b00
    cmovl eax, [eax]                        ;0f4c00
    cmovge eax, [eax]                       ;0f4d00
    cmovle eax, [eax]                       ;0f4e00
    cmovg eax, [eax]                        ;0f4f00
_
    mov al, [eax]                           ;8a00
    mov eax, [eax]                          ;8b00
_
    mov [eax], es                           ;8c00
    mov es, [eax]                           ;8e00
_
    lea eax, [eax]                          ;8d00
_
    pop dword [eax]                         ;8f00
_
    nop                                     ;90
_
    xchg eax, eax                           ;90
    xchg ecx, eax                           ;91
    xchg edx, eax                           ;92
    xchg ebx, eax                           ;93
    xchg esp, eax                           ;94
    xchg ebp, eax                           ;95
    xchg esi, eax                           ;96
    xchg edi, eax                           ;97
_
    movsb                                   ;a4
    movsw                                   ;a5
    movsd                                   ;a5
    cmpsb                                   ;a6
    cmpsw                                   ;a7
    cmpsd                                   ;a7
    stosb                                   ;aa
    stosw                                   ;ab
    stosd                                   ;ab
    lodsb                                   ;ac
    lodsw                                   ;ad
    lodsd                                   ;ad
    scasb                                   ;ae
    scasw                                   ;af
    scasd                                   ;af
_
    rol byte [eax], 0x0                     ;c000 00
    rol dword [eax], 0x0                    ;c100 00
_
    les eax, dword [eax]                    ;c400
    lds eax, dword [eax]                    ;c500
_
    mov byte [eax], 0x0                     ;c600 00
    mov dword [eax], 0x0                    ;c700 00000000
_
    rol byte [eax], 0                       ;d000
    rol dword [eax], 0                      ;d100
_
    rol byte [eax], cl                      ;d200
    rol dword [eax], cl                     ;d300
_
    movsd xmm0, qword [eax]                 ;f20f1000
    movsd qword [eax], xmm0                 ;f20f1100
_
    movddup xmm0, qword [eax]               ;f20f1200
_
    cvtps2pd xmm0, qword [eax]              ;0f5a00
    cvtpd2ps xmm0, dqword [eax]             ;660f5a00
    cvtsd2ss xmm0, qword [eax]              ;f20f5a00
    cvtss2sd xmm0, dword [eax]              ;f30f5a00
_
    cvtdq2ps xmm0, dqword [eax]             ;0f5b00
    cvtps2dq xmm0, dqword [eax]             ;660f5b00
    cvttps2dq xmm0, dqword [eax]            ;f30f5b00
_
    cvttpd2dq xmm0, dqword [eax]            ;660fe600
    cvtpd2dq xmm0, dqword [eax]             ;f20fe600
    cvtdq2pd xmm0, qword [eax]              ;f30fe600
_
    cvttps2pi mm0, qword [eax]              ;0f2c00
    cvttpd2pi mm0, dqword [eax]             ;660f2c00
    cvttsd2si eax, qword [eax]              ;f20f2c00
    cvttss2si eax, dword [eax]              ;f30f2c00
_
    cvtpi2ps xmm0, qword [eax]              ;0f2a00
    cvtpi2pd xmm0, qword [eax]              ;660f2a00
    cvtsi2sd xmm0, dword [eax]              ;f20f2a00
    cvtsi2ss xmm0, dword [eax]              ;f30f2a00
_
    cvtps2pi mm0, qword [eax]               ;0f2d00
    cvtsd2si eax, qword [eax]               ;f20f2d00
    cvtss2si eax, dword [eax]               ;f30f2d00
    cvtpd2pi mm0, dqword [eax]              ;660f2d00
_
    addsd xmm0, qword [eax]                 ;f20f5800
    subsd xmm0, qword [eax]                 ;f20f5c00
    mulsd xmm0, qword [eax]                 ;f20f5900
    divsd xmm0, qword [eax]                 ;f20f5e00
_
    cmpps xmm0, [eax], 0                    ;0fc20000
_
    cmpeqps xmm0, [eax]                     ;0fc20000
    cmpltps xmm0, [eax]                     ;0fc20001
    cmpleps xmm0, [eax]                     ;0fc20002
    cmpunordps xmm0, [eax]                  ;0fc20003
    cmpneqps xmm0, [eax]                    ;0fc20004
    cmpnltps xmm0, [eax]                    ;0fc20005
    cmpnleps xmm0, [eax]                    ;0fc20006
    cmpordps xmm0, [eax]                    ;0fc20007
_
    cmpsd xmm0, [eax], 0                    ;f20fc20000
_
    cmpeqsd xmm0, [eax]                     ;f20fc20000
    cmpltsd xmm0, [eax]                     ;f20fc20001
    cmplesd xmm0, [eax]                     ;f20fc20002
    cmpunordsd xmm0, [eax]                  ;f20fc20003
    cmpneqsd xmm0, [eax]                    ;f20fc20004
    cmpnltsd xmm0, [eax]                    ;f20fc20005
    cmpnlesd xmm0, [eax]                    ;f20fc20006
    cmpordsd xmm0, [eax]                    ;f20fc20007
_
    cmppd xmm0, dqword [eax], 0             ;660fc20000 ; grammar difference with what's next...
_
    cmpeqpd xmm0, dqword [eax]              ;660fc20000
    cmpltpd xmm0, dqword [eax]              ;660fc20001
    cmplepd xmm0, dqword [eax]              ;660fc20002
    cmpunordpd xmm0, dqword [eax]           ;660fc20003
    cmpneqpd xmm0, dqword [eax]             ;660fc20004
    cmpnltpd xmm0, dqword [eax]             ;660fc20005
    cmpnlepd xmm0, dqword [eax]             ;660fc20006
    cmpordpd xmm0, dqword [eax]             ;660fc20007
_
    cmpss xmm0, [eax], 0                    ;f30fc20000 grammar
_
    cmpeqss xmm0, [eax]                     ;f30fc20000
    cmpltss xmm0, [eax]                     ;f30fc20001
    cmpless xmm0, [eax]                     ;f30fc20002
    cmpunordss xmm0, [eax]                  ;f30fc20003
    cmpneqss xmm0, [eax]                    ;f30fc20004
    cmpnltss xmm0, [eax]                    ;f30fc20005
    cmpnless xmm0, [eax]                    ;f30fc20006
    cmpordss xmm0, [eax]                    ;f30fc20007
_
    addsubps xmm0, dqword [eax]             ;f20fd000
_
    lddqu xmm0, [eax]                       ;f20ff000
_
    movss xmm0, dword [eax]                 ;f30f1000
    movss dword [eax], xmm0                 ;f30f1100
_
    movsldup xmm0, dqword [eax]             ;f30f1200
    movshdup xmm0, dqword [eax]             ;f30f1600
_
    addss xmm0, dword [eax]                 ;f30f5800
    subss xmm0, dword [eax]                 ;f30f5c00
    mulss xmm0, dword [eax]                 ;f30f5900
    divss xmm0, dword [eax]                 ;f30f5e00
_
    lzcnt eax, [eax]                        ;f30fbd00
_
;XOP
    vpmadcsswd  xmm0, xmm0, xmm0, xmm0      ;8fe878a6c000
_
    vcvtph2ps   xmm0, xmm0, 0               ;8fe878a0c000
    vcvtps2ph   xmm0, xmm0, 0               ;8fe878a1c000
_
    vfmaddpd xmm0, xmm0, xmm0, xmm0         ;c4e37969c000
    vfmaddps xmm0, xmm0, xmm0, xmm0         ;c4e37968c000
    vfmaddsd xmm0, xmm0, xmm0, xmm0         ;c4e3796bc000
    vfmaddss xmm0, xmm0, xmm0, xmm0         ;c4e3796ac000
    vfmaddpd ymm0, ymm0, ymm0, ymm0         ;c4e37d69c000
    vfmaddps ymm0, ymm0, ymm0, ymm0         ;c4e37d68c000
    vfmsubpd ymm0, ymm0, ymm0, ymm0         ;c4e37d6dc000
    vfmsubps ymm0, ymm0, ymm0, ymm0         ;c4e37d6cc000

_
    vfmaddsubpd xmm0, xmm0, xmm0, xmm0      ;c4e3795dc000
    vfmaddsubps xmm0, xmm0, xmm0, xmm0      ;c4e3795cc000
    vfmsubaddpd xmm0, xmm0, xmm0, xmm0      ;c4e3795fc000
    vfmsubaddps xmm0, xmm0, xmm0, xmm0      ;c4e3795ec000
    vfmaddsubpd ymm0, ymm0, ymm0, ymm0      ;c4e37d5dc000
    vfmaddsubps ymm0, ymm0, ymm0, ymm0      ;c4e37d5cc000
    vfmsubaddps ymm0, ymm0, ymm0, ymm0      ;c4e37d5ec000
    vfmsubaddpd ymm0, ymm0, ymm0, ymm0      ;c4e37d5fc000
_
    vfmsubpd xmm0, xmm0, xmm0, xmm0         ;c4e3796dc000
    vfmsubps xmm0, xmm0, xmm0, xmm0         ;c4e3796cc000
    vfmsubsd xmm0, xmm0, xmm0, xmm0         ;c4e3796fc000
    vfmsubss xmm0, xmm0, xmm0, xmm0         ;c4e3796ec000
_
    vfnmaddpd xmm0, xmm0, xmm0, xmm0        ;c4e37979c000
    vfnmaddps xmm0, xmm0, xmm0, xmm0        ;c4e37978c000
    vfnmaddsd xmm0, xmm0, xmm0, xmm0        ;c4e3797bc000
    vfnmaddss xmm0, xmm0, xmm0, xmm0        ;c4e3797ac000
    vfnmaddpd ymm0, ymm0, ymm0, ymm0        ;c4e37d79c000
    vfnmaddps ymm0, ymm0, ymm0, ymm0        ;c4e37d78c000
_
    vfnmsubpd xmm0, xmm0, xmm0, xmm0        ;c4e3797dc000
    vfnmsubps xmm0, xmm0, xmm0, xmm0        ;c4e3797cc000
    vfnmsubsd xmm0, xmm0, xmm0, xmm0        ;c4e3797fc000
    vfnmsubss xmm0, xmm0, xmm0, xmm0        ;c4e3797ec000
    vfnmsubpd ymm0, ymm0, ymm0, ymm0        ;c4e37d7dc000
    vfnmsubps ymm0, ymm0, ymm0, ymm0        ;c4e37d7cc000
    vfnmsubss xmm0, xmm0, xmm0, xmm0        ;c4e3797ec000
    vfnmsubsd xmm0, xmm0, xmm0, xmm0        ;c4e3797fc000
_
    vfrczpd     xmm0, xmm0                  ;8fe97881c0
    vfrczps     xmm0, xmm0                  ;8fe97880c0
    vfrczsd     xmm0, xmm0                  ;8fe97883c0
    vfrczss     xmm0, xmm0                  ;8fe97882c0
_
    vpcmov      xmm0, xmm0, xmm0, xmm0      ;8fe878a2c000
_
    vpcomb      xmm0, xmm0, xmm0, 0         ;8fe878ccc000
    vpcomd      xmm0, xmm0, xmm0, 0         ;8fe878cec000
    vpcomq      xmm0, xmm0, xmm0, 0         ;8fe878cfc000
_
    vpcomub     xmm0, xmm0, xmm0, 0         ;8fe878ecc000
    vpcomud     xmm0, xmm0, xmm0, 0         ;8fe878eec000
    vpcomuq     xmm0, xmm0, xmm0, 0         ;8fe878efc000
    vpcomuw     xmm0, xmm0, xmm0, 0         ;8fe878edc000
_
    vpcomw      xmm0, xmm0, xmm0, 0         ;8fe878cdc000
_
    vphaddbd    xmm0, xmm0                  ;8fe978c2c0
    vphaddbq    xmm0, xmm0                  ;8fe978c3c0
    vphaddbw    xmm0, xmm0                  ;8fe978c1c0
    vphadddq    xmm0, xmm0                  ;8fe978cbc0
_
    vphaddubd   xmm0, xmm0                  ;8fe978d2c0
    vphaddubq   xmm0, xmm0                  ;8fe978d3c0
    vphaddubw   xmm0, xmm0                  ;8fe978d1c0
    vphaddudq   xmm0, xmm0                  ;8fe978dbc0
    vphadduwd   xmm0, xmm0                  ;8fe978d6c0
    vphadduwq   xmm0, xmm0                  ;8fe978d7c0
_
    vphaddwd    xmm0, xmm0                  ;8fe978c6c0
    vphaddwq    xmm0, xmm0                  ;8fe978c7c0
_
    vphsubbw    xmm0, xmm0                  ;8fe978e1c0
    vphsubdq    xmm0, xmm0                  ;8fe978e3c0
    vphsubwd    xmm0, xmm0                  ;8fe978e2c0
_
    vpmacsdd    xmm0, xmm0, xmm0, xmm0      ;8fe8789ec000
_
    vpmacsdqh   xmm0, xmm0, xmm0, xmm0      ;8fe8789fc000
    vpmacsdql   xmm0, xmm0, xmm0, xmm0      ;8fe87897c000
_
    vpmacssdd   xmm0, xmm0, xmm0, xmm0      ;8fe8788ec000
_
    vpmacssdqh  xmm0, xmm0, xmm0, xmm0      ;8fe8788fc000
    vpmacssdql  xmm0, xmm0, xmm0, xmm0      ;8fe87887c000
_
    vpmacsswd   xmm0, xmm0, xmm0, xmm0      ;8fe87886c000
    vpmacssww   xmm0, xmm0, xmm0, xmm0      ;8fe87885c000
_
    vpmacswd    xmm0, xmm0, xmm0, xmm0      ;8fe87896c000
    vpmacsww    xmm0, xmm0, xmm0, xmm0      ;8fe87895c000
_
    vpmadcsswd  xmm0, xmm0, xmm0, xmm0      ;8fe878a6c000
_
    vpmadcswd   xmm0, xmm0, xmm0, xmm0      ;8fe878b6c000
_
    vpperm      xmm0, xmm0, xmm0, xmm0      ;8fe878a3c000
_
    vprotb      xmm0, xmm0, xmm0            ;8fe97890c0
    vprotd      xmm0, xmm0, xmm0            ;8fe97892c0
    vprotq      xmm0, xmm0, xmm0            ;8fe97893c0
    vprotw      xmm0, xmm0, xmm0            ;8fe97891c0
_
    vpshab      xmm0, xmm0, xmm0            ;8fe97898c0
    vpshad      xmm0, xmm0, xmm0            ;8fe9789ac0
    vpshaq      xmm0, xmm0, xmm0            ;8fe9789bc0
    vpshaw      xmm0, xmm0, xmm0            ;8fe97899c0
_
    vpshlb      xmm0, xmm0, xmm0            ;8fe97894c0
    vpshld      xmm0, xmm0, xmm0            ;8fe97896c0
    vpshlq      xmm0, xmm0, xmm0            ;8fe97897c0
    vpshlw      xmm0, xmm0, xmm0            ;8fe97895c0
_
;FPU
    f2xm1                                   ;d9f0 ; 2 to the x power minus 1
    fabs                                    ;d9e1 absolute value of st0(0)
    fadd dword [eax]                        ;d800
    fadd qword [eax]                        ;dc00
    fadd st0,st0                            ;d8c0
    faddp st0,st0                           ;dec0
    fbld tword [eax]                        ;df20
    fbstp tword [eax]                       ;df30
    fchs                                    ;d9e0
    fclex                                   ;9b dbe2
    fcmovb st0,st0                          ;dac0
    fcmovbe st0,st0                         ;dad0
    fcmove st0,st0                          ;dac8
    fcmovnb st0,st0                         ;dbc0
    fcmovnbe st0,st0                        ;dbd0
    fcmovne st0,st0                         ;dbc8
    fcmovnu st0,st0                         ;dbd8
    fcmovu st0,st0                          ;dad8
    fcom dword [eax]                        ;d810
    fcom qword [eax]                        ;dc10
    fcom st0                                ;d8d0
    fcomi st0,st0                           ;dbf0
    fcomip st0, st0                         ;dff0 compare st0(0) to st0(i) and set cpu flags and pop st0(0)
    fcomp dword [eax]                       ;d818
    fcomp qword [eax]                       ;dc18
    fcomp st0                               ;d8d8
    fcompp                                  ;ded9 compare st0(0) to st0(1) and pop both registers
    fcos                                    ;d9ff
    fdecstp                                 ;d9f6 decrease stack pointer
    db 0dbh, 0e1h ;   fdisi                 ;dbe1
    fdiv dword [eax]                        ;d830
    fdiv qword [eax]                        ;dc30
    fdiv st0,st0                            ;d8f0
    fdiv st0,st0                            ;dcf8
    fdivp st0,st0                           ;def8
    fdivr dword [eax]                       ;d838
    fdivr qword [eax]                       ;dc38
    fdivr st0,st0                           ;d8f8
    fdivr st0,st0                           ;dcf0
    fdivrp st0,st0                          ;def0
    db 0dbh, 0e0h ;   feni                  ;dbe0
    ffree st0                               ;ddc0
    ffreep st0                              ;dfc0 undoc ?
    fiadd dword [eax]                       ;da00
    fiadd word [eax]                        ;de00
    ficom dword [eax]                       ;da10
    ficom word [eax]                        ;de10
    ficomp dword [eax]                      ;da18
    ficomp word [eax]                       ;de18
    fidiv dword [eax]                       ;da30
    fidiv word [eax]                        ;de30
    fidivr dword [eax]                      ;da38
    fidivr word [eax]                       ;de38
    fild dword [eax]                        ;db00
    fild qword [eax]                        ;df28
    fild word [eax]                         ;df00
    fimul dword [eax]                       ;da08
    fimul word [eax]                        ;de08
    fincstp                                 ;d9f7 increase stack pointer
    finit                                   ;dbe3
    fist dword [eax]                        ;db10
    fist word [eax]                         ;df10
    fistp dword [eax]                       ;db18
    fistp qword [eax]                       ;df38
    fistp word [eax]                        ;df18
    fisttp word [eax]                       ;df08
    fisub dword [eax]                       ;da20
    fisub word [eax]                        ;de20
    fisubr dword [eax]                      ;da28
    fisubr word [eax]                       ;de28
    fld dword [eax]                         ;d900
    fld qword [eax]                         ;dd00
    fld st0                                 ;d9c0
    fld tword [eax]                         ;db28
    fld1                                    ;d9e8
    fldcw word [eax]                        ;d928
    fldenv [eax]                            ;d920
    fldl2e                                  ;d9ea load the log base 2 of e (napierian constant)
    fldl2t                                  ;d9e9 load the log base 2 of ten
    fldlg2                                  ;d9ec load the log base 10 of 2 (common log of 2)
    fldln2                                  ;d9ed load the log base e of 2 (natural log of 2)
    fldpi                                   ;d9eb
    fldz                                    ;d9ee
    fmul dword [eax]                        ;d808
    fmul qword [eax]                        ;dc08
    fmul st0,st0                            ;d8c8
    fmul st0,st0                            ;dcc8
    fmulp st0,st0                           ;dec8
    fnclex                                  ;9bdbe2
    fndisi                                  ;dbe2
    fneni                                   ;dbe1
    fninit                                  ;9bdbe3
    fnop                                    ;d9d0
    fnsave [eax]                            ;9bdd30
    fnstcw word [eax]                       ;9bd938
    fnstenv [eax]                           ;9bd930
    fnstsw word [eax]                       ;9bdd38
    fpatan                                  ;d9f3 partial arctangent of the ratio st0(1)/st0(0)
    fprem                                   ;d9f8
    fprem1                                  ;d9f5 partial remainder 1
    fptan                                   ;d9f2
    frndint                                 ;d9fc round st0(0) to an integer
    frstor [eax]                            ;dd20
    frstpm                                  ; TODO replaced by fwait ?
    fsave [eax]                             ;dd30
    fscale                                  ;d9fd scale st0(0) by st0(1)
    fsetpm                                  ;dbe4
    db 0dbh, 0e4h       ;fnsetpm            ;dbe4
    fsin                                    ;d9fe
    fsincos                                 ;d9fb sine and cosine of the angle value in st0(0)
    fsqrt                                   ;d9fa
    ;fstsg ax ; TODO
    fst dword [eax]                         ;d910
    fst qword [eax]                         ;dd10
    fst st0                                 ;ddd0
    fstcw word [eax]                        ;d938
    fstenv [eax]                            ;d930
    fstp dword [eax]                        ;d918
    fstp qword [eax]                        ;dd18
    fstp st0                                ;ddd8
    fstp tword [eax]                        ;db38
    fstsw word [eax]                        ;dd38
    fsub dword [eax]                        ;d820
    fsub qword [eax]                        ;dc20
    fsub st0,st0                            ;d8e0
;   fsub st0,st0                            ;dce8
    fsubp st0,st0                           ;dee8
    fsubr dword [eax]                       ;d828
    fsubr qword [eax]                       ;dc28
    fsubr st0,st0                           ;d8e8
;   fsubr st0,st0                           ;dce0
    fsubrp st0,st0                          ;dee0
    ftst                                    ;d9e4
    fucom st0                               ;dde0
    fucomi st0,st0                          ;dbe8
    fucomip st0                             ;dfe8 unordered compare st0(0) to st0(i) and set cpu flags and pop st0(0)
    fucomp st0                              ;dde8 unordered compare st0(0) to a floating point value and pop st0(0)
    fucompp                                 ;dae9 unordered compare st0(0) to st0(1) and pop both registers
    fxam                                    ;d9e5
    fxch st0                                ;d9c8
    fxtract                                 ;d9f4 extract exponent and significand
    fyl2x                                   ;d9f1
    fyl2xp1                                 ;d9f9 y*log2(x+1)
    fwait                                   ;9b
    nop
    wait                                    ;9b
    nop
_
;fpu aliases
    db 0d9h, 0d8h       ;fstp1 st0          ;d9d8
    db 0dch, 0d0h       ;fcom2              ;dcd0
    db 0dch, 0d8h       ;fcomp3             ;dcd8
    db 0ddh, 0c8h       ;fxch4 st0          ;ddc8
    db 0deh, 0d0h       ;fcomp5 st0         ;ded0
    db 0dfh, 0c8h       ;fxch7 st0          ;dfc8
    db 0dfh, 0d0h       ;fstp8 st0          ;dfd0
    db 0dfh, 0d8h       ;fstp9 st0          ;dfd8
_
    sldt [eax]                              ;0f0000
    sldt eax                                ;660f0000
    str  [eax]                              ;0f0008
    str  eax                                ;660f0008
    lldt [eax]                              ;0f0010
    lldt ax                                 ;0f00d0
    ltr  [eax]                              ;0f0018
    ltr  ax                                 ;0f00d8
    verr [eax]                              ;0f0020
    verr ax                                 ;0f00e0
    verw [eax]                              ;0f0028
    verw ax                                 ;0f00e8
_
    sgdt [eax]                              ;0f0100
    sidt [eax]                              ;0f0108
    lgdt [eax]                              ;0f0110
    lidt [eax]                              ;0f0118
    smsw [eax]                              ;0f0120
    lmsw [eax]                              ;0f0130
    invlpg [eax]                            ;0f0138
_
    smsw ax                                 ;660f01e0
    smsw eax                                ;0f01e0 ;TODO undocumented?
    lmsw ax                                 ;0f01f0
    fxsave [eax]                            ;0fae00
    fxrstor [eax]                           ;0fae08
    ldmxcsr [eax]                           ;0fae10
    stmxcsr [eax]                           ;0fae18
    xsave [eax]                             ;0fae20
    xrstor [eax]                            ;0fae28
    clflush [eax]                           ;0fae38
_
    mfence                                  ;0faef0
    lfence                                  ;0faee8
    sfence                                  ;0faef8
_
    test byte [eax], 0                      ;f6 00 00
    ;alternate encoding
    db 0f6h, 08h, 00 ; test byte [eax], 0   ;f60800

    not  byte [eax]                         ;f610
    neg  byte [eax]                         ;f618
    mul  byte [eax]                         ;f620
    imul byte [eax]                         ;f628
    div  byte [eax]                         ;f630
    idiv byte [eax]                         ;f638

    test dword [eax], 0                     ;f70000
    ;alternate encoding                     ;f70800
    db 0f7h, 08h,
        dd 00 ;     test dword [eax], 0

    not  dword [eax]                        ;f710
    neg  dword [eax]                        ;f718
    mul  dword [eax]                        ;f720
    imul dword [eax]                        ;f728
    div  dword [eax]                        ;f730
    idiv dword [eax]                        ;f738
    rol  byte [eax], 0                      ;c00000
    ror  byte [eax], 0                      ;c00800
    rcl  byte [eax], 0                      ;c01000
    rcr  byte [eax], 0                      ;c01800
    shl  byte [eax], 0                      ;c02000
    shr  byte [eax], 0                      ;c02800
    db 0c0h, 30h, 00h ; sal = shl           ;c03000
    sar  byte [eax], 0                      ;c03800
_
    rol  dword [eax], 0                     ;c10000
    ror  dword [eax], 0                     ;c10800
    rcl  dword [eax], 0                     ;c11000
    rcr  dword [eax], 0                     ;c11800
    shl  dword [eax], 0                     ;c12000
    shr  dword [eax], 0                     ;c12800
    db 0c1h, 30h, 0h ; sal = shl            ;c13000
    sar  dword [eax], 0                     ;c13800
_
    db 0fh, 1fh, 00 ;nop [eax]              ;0f1f00
    db 0fh, 1fh, 01 ;nop [ecx]              ;0f1f01
_
;AVX
    vaddpd xmm0, dqword [eax]               ;660f5800
    vaddpd ymm0, ymm0, ymm0                 ;c5fd58c0
_
    aesdec      xmm0, xmm0                  ;660f38dec0
    aesdeclast  xmm0, xmm0                  ;660f38dfc0
    aesenc      xmm0, xmm0                  ;660f38dcc0
    aesenclast  xmm0, xmm0                  ;660f38ddc0
    aesimc      xmm0, xmm0                  ;660f38dbc0
    aeskeygenassist xmm0, xmm0, 0           ;660f3adfc000
_
    vaesdec      xmm0, xmm0                 ;c4e279dec0
    vaesdeclast  xmm0, xmm0                 ;c4e279dfc0
    vaesenc      xmm0, xmm0                 ;c4e279dcc0
    vaesenclast  xmm0, xmm0                 ;c4e279ddc0
    vaesimc      xmm0, xmm0                 ;c4e279dbc0
    vaeskeygenassist xmm0, xmm0, 0          ;c4e379dfc000
_
    vextractf128 xmm0, ymm0, 0              ;c4e37d19c000
    vbroadcastf128 ymm0, [0]                ;c4e27d1a0500000000
_
    vzeroall                                ;c5fc77
    vzeroupper                              ;c5f877
_
    vbroadcastsd ymm0, [0]                  ;c4e27d190500000000
    vbroadcastss ymm0, [eax]                ;c4e27d1800
_
    vinsertf128 ymm0, ymm0, xmm0, 0         ;c4e37d18c000
    vperm2f128 ymm0, ymm0, ymm0, 0          ;c4e37d06c000
_
    vmaskmovps ymm0, ymm0, [0]              ;c4e27d2c0500000000
    vmaskmovpd ymm0, ymm0, [0]              ;c4e27d2d0500000000
_
    vpermilpd   ymm0, ymm0, [0]             ;c4e27d0d0500000000
    vpermilps   ymm0, ymm0, [0]             ;c4e27d0c0500000000
;   vpermil2pd   ymm0, ymm0, ymm0, ymm0, 0  ; removed
;   vpermilmo2ps ymm0, ymm0, ymm0, ymm0
;   vpermil2ps   ymm0, ymm0, ymm0, ymm0, 0  ; removed
_
    pclmulqdq xmm0, xmm0, 0                 ;660f3a44c000
_
    vtestps ymm0, ymm0                      ;c4e27d0ec0
    vtestpd ymm0, ymm0                      ;c4e27d0fc0
_
    vfmadd132pd xmm0, xmm0, xmm0            ;c4e2f998c0
    vfmadd213pd xmm0, xmm0, xmm0            ;c4e2f9a8c0
    vfmadd231pd xmm0, xmm0, xmm0            ;c4e2f9b8c0
_
    pshufb xmm0, dqword [eax]               ;660f380000
    phaddw xmm0, dqword [eax]               ;660f380100
    phaddd xmm0, dqword [eax]               ;660f380200
    phaddsw xmm0, dqword [eax]              ;660f380300
    pmaddubsw xmm0, dqword [eax]            ;660f380400
    phsubw xmm0, dqword [eax]               ;660f380500
    phsubd xmm0, dqword [eax]               ;660f380600
    phsubsw xmm0, dqword [eax]              ;660f380700
_
    pblendvb xmm0, xmm0                     ;660f3810c0
    blendvps xmm0, xmm0                     ;660f3814c0
    blendvpd xmm0, xmm0                     ;660f3815c0
_
    ptest xmm0, xmm0                        ;660f3817c0
_
    pmovsxbw xmm0, xmm0                     ;660f3820c0
    pmovsxbd xmm0, xmm0                     ;660f3821c0
    pmovsxbq xmm0, xmm0                     ;660f3822c0
    pmovsxwd xmm0, xmm0                     ;660f3823c0
    pmovsxwq xmm0, xmm0                     ;660f3824c0
    pmovsxdq xmm0, xmm0                     ;660f3825c0
_
    pmovzxbw xmm0, xmm0                     ;660f3830c0
    pmovzxbd xmm0, xmm0                     ;660f3831c0
    pmovzxbq xmm0, xmm0                     ;660f3832c0
    pmovzxwd xmm0, xmm0                     ;660f3833c0
    pmovzxwq xmm0, xmm0                     ;660f3834c0
    pmovzxdq xmm0, xmm0                     ;660f3835c0
_
    pcmpgtq  xmm0, xmm0                     ;660f3837c0
_
    pmulld xmm0, xmm0                       ;660f3840c0
    phminposuw xmm0, xmm0                   ;660f3841c0
_
    invept ; TODO manually
    invvpid
_
    movbe [eax], eax                        ;0f38f100
    movbe eax, [eax]                        ;0f38f000
_
    psignb xmm0, xmm0                       ;660f3808c0
    psignw xmm0, xmm0                       ;660f3809c0
    psignd xmm0, xmm0                       ;660f380ac0
_
    pmulhrsw xmm0, xmm0                     ;660f380bc0
_
    pabsb xmm0, xmm0                        ;660f381cc0
    pabsw xmm0, xmm0                        ;660f381dc0
    pabsd xmm0, xmm0                        ;660f381ec0
_
    pmuldq xmm0, xmm0                       ;660f3828c0
    pcmpeqq xmm0, xmm0                      ;660f3829c0
    movntdqa xmm0, [eax]                    ;660f382a00
    packusdw xmm0, xmm0                     ;660f382bc0
_
    pminsb xmm0, xmm0                       ;660f3838c0
    pminsd xmm0, xmm0                       ;660f3839c0
    pminuw xmm0, xmm0                       ;660f383ac0
    pminud xmm0, xmm0                       ;660f383bc0
_
    pmaxsb xmm0, xmm0                       ;660f383cc0
    pmaxsd xmm0, xmm0                       ;660f383dc0
    pmaxuw xmm0, xmm0                       ;660f383ec0
    pmaxud xmm0, xmm0                       ;660f383fc0
_
    extractps eax, xmm0, 0                  ;660f3a17c000
_
    pinsrb xmm0, eax, 0                     ;660f3a20c000
    insertps xmm0, xmm0, 0                  ;660f3a21c000 not eax ?
_
    dpps xmm0, xmm0, 0                      ;660f3a40c000
    dppd xmm0, xmm0, 0                      ;660f3a41c000
_
    mpsadbw xmm0, xmm0, 0                   ;660f3a42c000
_
    pcmpestrm xmm0, xmm0, 0                 ;660f3a60c000
    pcmpestri xmm0, xmm0, 0                 ;660f3a61c000
    pcmpistrm xmm0, xmm0, 0                 ;660f3a62c000
    pcmpistri xmm0, xmm0, 0                 ;660f3a63c000
_
    roundps xmm0, xmm0, 0                   ;660f3a08c000
    roundpd xmm0, xmm0, 0                   ;660f3a09c000
    roundss xmm0, xmm0, 0                   ;660f3a0ac000
    roundsd xmm0, xmm0, 0                   ;660f3a0bc000
_
    blendps xmm0, xmm0, 0                   ;660f3a0cc000
    blendpd xmm0, xmm0, 0                   ;660f3a0dc000
    pblendw xmm0, xmm0, 0                   ;660f3a0ec000
_
    palignr xmm0, xmm0, 0                   ;660f3a0fc000
    palignr mm0, mm0, 0                     ;0f3a0fc000
_
;PREFIXES
    lock and word [fs:bx + si], si          ;646766f02130 just for fun
_
; branch hints
    jnz $ + 2                               ;7500
    PREFIX_BRANCH_TAKEN
    jnz $ + 2                               ;3e7500
    PREFIX_BRANCH_NOT_TAKEN
    jnz $ + 2                               ;2e7500
_

;SEGMENTS
;default segments
;ds
    ; eax, ecx, ebx, edx, esi, edi, immediate
    mov eax, [eax]                          ;8b00
;es
    ; es:edi <= ds:esi
    movsd                                   ;a5
;ss
    ; sp, bp
    mov eax, [ebp]                          ;8b4500
    mov eax, [esp]                          ;8b0424
_
    mov eax, [fs:ebp]                       ;648b4500 'undetermined' but works, fault under 64b

    PREFIX_FS
    movsd ;dword [es:edi], dword [fs:esi]   ;64a5 same trick with cmps*
_
    mov [es:eax], eax                       ;26 8900
    mov [cs:eax], eax                       ;2e 8900
    mov [ss:eax], eax                       ;36 8900
    mov [ds:eax], eax                       ;3e 8900
    mov [fs:eax], eax                       ;64 8900
    mov [gs:eax], eax                       ;65 8900
_
    movsb                                   ;a4
    repz movsb                              ;f3a4 = repe
    repnz movsb                             ;f2a4 = repne
_
    mov [eax], eax                          ;8900
    lock mov [eax], eax                     ;f08900
    lock mov eax, eax                       ;f089c0 incorrect, memory only
_
    add [eax], al                           ;0000
    add [bx+si], al                         ;67 0000
    PREFIX_ADDRESSSIZE
    jmp $ + 2                               ;66 EB00 will jump to (word)<NEXT EIP>
    PREFIX_ADDRESSSIZE
    loop $ + 2                              ;66e200
    PREFIX_ADDRESSSIZE
    call $ + 5                              ;66e8000000
    PREFIX_ADDRESSSIZE
    ret                                     ;66e3
_
; just to make the opcodes present, to be moved...
bits 64
    pextrq [eax], xmm0, 0                   ;660f3a16 64b only (for yasm)
    pinsrd xmm0, [eax], 0                   ;660f3a22 64b only (for yasm)
    pinsrq xmm0, [eax], 0                   ;660f3a22 64b only (for yasm)
    swapgs                                  ;0f1f f8  64b only
    cdqe                                    ;98 64b only
    cmpxchg16b [eax]                        ;67480f0c7 64b mode
    db 0fh, 00, 78h,00  ; jmpe              ;0f007800

; Ange Albertini 2009-2010.