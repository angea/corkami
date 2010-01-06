; A file that contains most x86 opcodes, including AVX, SSE, FPU...
; messy, because released as-is, but interesting, and useful to test the ability of your disassembler
; compile with Yasm

BITS 32

%define int1 db 0f1h

%define _  dd 90909090h;align 8, db 090h    ; turning on alignment makes yasm crawls...

;conditionals
; b = c
; nb = nc
; nbe = a
; nl = ge
; nle = g
; z = e
; z = ne

;prefixes

%define PREFIX_FS db 64h
%define PREFIX_OPERANDSIZE db 66h
%define PREFIX_ADDRESSSIZE db 67h
%define PREFIX_BRANCH_TAKEN db 3eh
%define PREFIX_BRANCH_NOT_TAKEN db 2eh

jmp _start

    lock and word [fs:bx + si], si
_
; branch hints
    PREFIX_BRANCH_TAKEN
    jnz $ + 2
_
    PREFIX_BRANCH_NOT_TAKEN
    jnz $ + 2
_
    movsd
_
    PREFIX_FS
    movsd ;dword [es:edi], dword [fs:esi]
_

;default segments

;ds
mov eax, [ebx]
_
;es
    mov eax, [ebp]
_
    mov eax, [esp]
_
    mov [es:eax], al                ;26 8800
    mov [cs:eax], al                ;2e 8800
    mov [ss:eax], al                ;36 8800
    mov [ds:eax], al                ;3e 8800
    mov [fs:eax], al                ;64 8800
    mov [gs:eax], al                ;65 8800
_

; one byte, no arguments
_
    cwde ; 98 66 version too
    ;cwd
_
    cdq  ; 99 66 version too
    ; cdqe ; 64b only

    nop     ; 90 no operation
_
    cmc     ; F5 complement carry flag
    stc     ; F9 set carry flag
    clc     ; F8 clear carry flag
_
    cli     ; FA clear interruption flag
    sti     ; FB set interruption flag
_
    cld     ; FC clear direction flag
    std     ; FD set direction flag
_
    setalc  ; D6 setalc/salc, set al on carry, undocumented
    salc
_
    xlat    ; D7 table lookup translation
    xlatb
_
    leave   ; C9 high-level procedure exit
_
    int1    ; F1 ICE BreakPoint/INT01, undocumented
    int 1
_
    int3    ; CC interruption 3 (not 'int 3')
    int 3
_
    into    ; CE interruption if overflow flag is set
_
    iretd   ; CF interruption return
_
    ret     ; C3 return
_
    hlt     ; F4 halt
_
    nop
_
    lahf    ; 9F Load Flags into AH Register, (C P A Z only)
_
    sahf    ; 9E Store AH into Flags
_
    wait    ; 9B wait until busy pin inactive (wait for fpu)
_
    daa     ; 27 Decimal Adjust AL after Addition, BCD digits operation
    aaa     ; 37 Adjust AL after Addition, BCD digits operation
    das     ; 2F Decimal Adjust AL after Substraction, BCD digits operation
    aas     ; 3F Adjust AL after Subtraction, BCD digits operation
_
    pushad  ; 60 Push all general registers
    popad   ; 61 Pop all general registers
_
    pushfd  ; 9C push flags register
    popfd   ; 9D pop flags register
_

    ; mnemonic with an argument, but no separate byte in hex encoding
    ; standard register order : ax, cx, dx, bx, sp, bp, si, di
    push eax ; 50
    push ecx ; 51
    push edx ; 52
    push ebx ; 53
    push esp ; 54
    push ebp ; 55
    push esi ; 56
    push edi ; 57
_
    pop eax  ; 58
    pop ecx  ; 59
    pop edx  ; 5A
    pop ebx  ; 5B
    pop esp  ; 5C
    pop ebp  ; 5D
    pop esi  ; 5E
    pop edi  ; 5F

    ; standard segment order: es, cs, ss, ds
    push es ; 06
    push cs ; 0E
    push ss ; 16
    push ds ; 1E
_

    pop es  ; 07
    ; no pop cs
    pop ss  ; 17
    pop ds  ; 1F
_

    inc eax ; 40
    inc ecx ; 41
    inc edx ; 42
    inc ebx ; 43
    inc esp ; 44
    inc ebp ; 45
    inc esi ; 46
    inc edi ; 47

    dec eax ; 48
    dec ecx ; 49
    dec edx ; 4A
    dec ebx ; 4B
    dec esp ; 4C
    dec ebp ; 4D
    dec esi ; 4E
    dec edi ; 4F
_
    ; one immediate byte argument - 'Ib' in intel docs
    int 0ffh    ; CD xx interrupt
_

    ;push_b 255  ; 6a xx push byte

    ;al is hardcoded first argument
    ;the order add/or/adc/sbb/and/sub/xor/cmp is noticeable
    add al, 0 ; 04 xx add
_
    or  al, 0 ; 0c xx logical or
_
    adc al, 0 ; 14 xx add + carry
_
    sbb al, 0 ; 1c xx substract - carry
_
    and al, 0 ; 24 xx logical and
_
    sub al, 0 ; 2c xx substract
_
    xor al, 0 ; 34 xx logical xor
_
    cmp al, 0 ; 3c xx compare
_

    ;8 bit register fixed by the opcode byte
    ;a-c-d-b as usual, low then high
    mov al, 0 ; B0 xx mov
    mov cl, 0 ; B1 xx mov
    mov dl, 0 ; B2 xx mov
    mov bl, 0 ; B3 xx mov
    mov ah, 0 ; B4 xx mov
    mov ch, 0 ; B5 xx mov
    mov dh, 0 ; B6 xx mov
    mov bh, 0 ; B7 xx mov
_

    test al, 0ffh   ; A8 xx
_
    in al, 0ffh     ; E4 xx
    in eax, 0ffh    ; E5 xx
_

    ; for the out opcode, the literal is the 1st operand
    out 0ffh, al    ; E6 xx
    out 0ffh, eax   ; E7 xx
_


    ; one immediate word argument, iw
    retn 01234h   ; C2 xxxx return near
_
    ;retn_ 0       ; is synonym of C3 retn but usually simplified by assemblers
    retf 01234h   ; CA xxxx return far
_

    ;relative byte jump argument, Jb in intel docs
    ; it jumps to <eip_after_jmp> + <argument>
    ; while $ in assembler means the starts of the instruction
    ; those are 'short' jumps
    jmp $       ; EB xx so this is actually a jump with a negative argument
_
    jmp $ + 2   ; encodes itself as EB 00
_
    loop   $ + 2        ; e2 xx decrement ?ecx then jump if ?cx is not null

    PREFIX_ADDRESSSIZE
    loop   $ + 2        ; e2 xx decrement ?ecx then jump if ?cx is not null
_
    loope  $ + 2        ; E1 xx decrement ?ecx then jump if ?cx is not null and Z is set
    ; = loopz

    PREFIX_ADDRESSSIZE
    loope  $ + 2        ; E1 xx decrement ?ecx then jump if ?cx is not null and Z is set
_
    loopne $ + 2        ; E0 xx decrement ?ecx then jump if ?cx is not null and Z is not set
    ; = loopnz
    PREFIX_ADDRESSSIZE
    loopne $ + 2        ; E0 xx decrement ?ecx then jump if ?cx is not null and Z is not set
_
    jecxz  $ + 2        ; e3 xx jump if ecx is null
    jcxz  $ + 2        ; e3 xx jump if cx is null

_


    ; 2 arguments, one immediate word, one immediate byte, Iw/Ib in Intel docs
    enter 03141h,059h ; C8 dw0, db1
_

    ;grammar stuff (mnemonic that change their spelling according to the conditions)
    ; iret is byte/word based, iretd is dword based
    iretw
_
    iretd
_

    ; AAM/AAD are usually rendered differently, by default it's a 10 0xA division
    ; so some assemblers like MASM don't accept an argument
    aam         ; d4 0a
    aam 255     ; d4 xx
    aad         ; d5 0a
    aad 255     ; d5 xx
_

    ; pusha is default mode pushaw/pushad. same for popa
    pusha   ; default mode
    pushaw  ; specificly word
    pushad  ; specificly dword
    popad
    popaw
    popa
_
    int3
    int_3

    ; 91-97
    ;xchg
    ;verif 66 et 67 sur opcode ci dessus

    ;Ew,Gw
    ;arpl  ; 63
    ;Gv, Ma
    ;bound ; 62
    ;prefix
    ; cs 2e
    ; ds 3e
    ; es 26
    ; ss 36
    ; fs 64
    ; gs 65
    ; f2 repne
    ; f3 repz

    ;Eb,Gb
    ; add... 00 + test 84 + 86 xchg + 88 mov
    add [eax], al ; 00 xx add
_
    or  [eax], al ; 08 xx logical or
_
    adc [eax], al ; 10 xx add + carry
_
    sbb [eax], al ; 18 xx substract - carry
_
    and [eax], al ; 20 xx logical and
_
    sub [eax], al ; 28 xx substract
_
    xor [eax], al ; 30 xx logical xor
_
    cmp [eax], al ; 38 xx compare
_
    test [eax], al ; 84
_
    xchg [eax], al ; 86
_
    mov [eax], al ; 88
_

    ;Ev, Gv
    add [eax], eax ; 01 xx add
_
    or  [eax], eax ; 09 xx logical or
_
    adc [eax], eax ; 11 xx add + carry
_
    sbb [eax], eax ; 19 xx substract - carry
_
    and [eax], eax ; 21 xx logical and
_
    sub [eax], eax ; 29 xx substract
_
    xor [eax], eax ; 31 xx logical xor
_
    cmp [eax], eax ; 39 xx compare
_
    test [eax], eax ; 85
_
    xchg [eax], eax ; 87
_
    mov [eax], eax ; 89
_

    ;then Gb,Eb and Gv,Ev, except for test and xchg of course

    add al, [eax] ; 02 xx add
_
    or  al, [eax] ; 0a xx logical or
_
    adc al, [eax] ; 12 xx add + carry
_
    sbb al, [eax] ; 1a xx substract - carry
_
    and al, [eax] ; 22 xx logical and
_
    sub al, [eax] ; 2a xx substract
_
    xor al, [eax] ; 32 xx logical xor
_
    cmp al, [eax] ; 3a xx compare
_

    mov al, [eax]; 8a
_

    add eax, [eax] ; 03 xx add
_
    or  eax, [eax] ; 0b xx logical or
_
    adc eax, [eax] ; 13 xx add + carry
_
    sbb eax, [eax] ; 1b xx substract - carry
_
    and eax, [eax] ; 23 xx logical and
_
    sub eax, [eax] ; 2b xx substract
_
    xor eax, [eax] ; 33 xx logical xor
_
    cmp eax, [eax] ; 3b xx compare
_

    mov eax, [eax]; 8b
_

    ;rAX, Iz
    ; add...05
    ; test a9
    add eax, 012345678h ; 03 xx add
_
    or  eax, 012345678h ; 0b xx logical or
_
    adc eax, 012345678h ; 13 xx add + carry
_
    sbb eax, 012345678h ; 1b xx substract - carry
_
    and eax, 012345678h ; 23 xx logical and
_
    sub eax, 012345678h ; 2b xx substract
_
    xor eax, 012345678h ; 33 xx logical xor
_
    cmp eax, 012345678h ; 3b xx compare
_

    test eax, 012345678h
_

    ;Jz
    call 012345678h
    jmp  012345678h
    ;call e8
    ;jmp e9


    ;groups
    ;Eb,lb
    ;group 1, 80-83, Eb,Ib, Ev,Iz Eb,Ib Ev,Ib
    ;group 2,
    ; D9E0                fchs
    ; D9E1                fabs
    ; 90                  nop
    ; F60000              test        b,[eax],0
    ; F60800              test        b,[eax],0
    ; F70000000000        test   [ds:eax]         ,[eax],0
    ; F70800000000        test   [ds:eax]         ,[eax],0
    ; 90                  nop
    ; 8C00                mov         [eax],es
    ; 90                  nop
    ; 0FB700              movzx   [ds:eax]     [ds:eax]     [ds:eax]         ,w,[eax]
    ; 0FB600              movzx   [ds:eax]     [ds:eax]     [ds:eax]         ,b,[eax]
    ; 0FB68000000000      movzx   [ds:eax]     [ds:eax]     [ds:eax]         ,b,[eax][0]
    ; 90                  nop
    ; C03000          [ds:eax]     [ds:eax]         l         b,[eax],0
    ; C13000          [ds:eax]     [ds:eax]         l    [ds:eax]         ,[eax],0
    ; 90                  nop
    ; F20F38F0            #UD
    ; 00F2            [ds:eax]     [ds:eax]     [ds:eax]              [ds:eax]         l,dh
    ; 0F38F1              #UD
    ; 0090660F3A14    [ds:eax]     [ds:eax]     [ds:eax]                  [eax][0143A0F66],dl
    ; 0000            [ds:eax]     [ds:eax]     [ds:eax]                  [eax],al
    ; 660F3A15            #UD
    ; 0000            [ds:eax]     [ds:eax]     [ds:eax]                  [eax],al
    ; 660F3A16            #UD
    ; 0000            [ds:eax]     [ds:eax]     [ds:eax]                  [eax],al
    ; 90                  nop
    ; 660F3A20            #UD
    ; 0000            [ds:eax]     [ds:eax]     [ds:eax]                  [eax],al
    ; 660F3A22            #UD
    ; 0000            [ds:eax]     [ds:eax]     [ds:eax]                  [eax],al
    ; 90                  nop
    ; 660F3A17            #UD
    ; 0000            [ds:eax]     [ds:eax]     [ds:eax]                  [eax],al
    ; 90                  nop

    clts        ; 0f 06
_
    loadall     ; 0f 07
_
    wrmsr       ; 0f 30
    rdtsc       ; 0f 31
    rdmsr       ; 0f 32
    rdpmc       ; 0f 33
_
    sysenter    ; 0f 34
    sysexit     ; 0f 35
_
    getsec ; 0f 37 missing!
_
    cpuid                       ; 0f a2
_
    push    fs                  ; 0f a0
    pop     fs                  ; 0f a1
    push    gs                  ; 0f a8
    pop     gs                  ; 0f a9
_
    invd                        ; 0f 08
    wbinvd                      ; 0f 09
_
    vmcall                      ; 0f 01 c1
    vmlaunch                    ; 0f 01 c2
    vmresume                    ; 0f 01 c3
    vmxoff                      ; 0f 01 c4
_
    monitor                     ; 0f 01 c8
    mwait                       ; 0f 01 c9
_
    xgetbv                      ; 0f 01 d0
    xsetbv                      ; 0f 01 d1
_
    vmrun                       ; 0f 01 d8
    vmmcall                     ; 0f 01 d9
    vmload                      ; 0f 01 da
    vmsave                      ; 0f 01 db
_
    stgi                        ; 0f 01 dc
    clgi                        ; 0f 01 dd
_
    skinit                      ; 0f 01 de
_
    invlpga                     ; 0f 01 df
_
    pause                       ; f3 90
_
    vmread  [eax],eax       ; 0f 78 00
    vmwrite eax, dword [eax]       ; 0f 79 00
_
    ;swapgs                 ; 0F 1F F8 64B ONLY?
;_
    rdtscp                  ; 0f 01 f9
_
    lar eax, [eax]          ; 0f 02 *
    lsl eax, [eax]          ; 0f 03 *
_
    movups xmm0, [eax]      ; 0f 10 *
    movups [eax], xmm0      ; 0f 11 *
_
    movlps xmm0, [eax]      ; 0f 12 *
    movlps [eax], xmm0      ; 0f 13 *
_
    unpcklps xmm0, [eax]    ; 0f 14 *
    unpckhps xmm0, [eax]    ; 0f 15 *
_
    movhps xmm0, [eax]      ; 0f 16 *
    movhps [eax], xmm0      ; 0f 17 *
_
    prefetchnta [eax]
_
    movupd xmm0, [eax]      ; 66 0f 10 *
    movupd [eax], xmm0      ; 66 0f 11 *
_
    movlpd xmm0, [eax]      ; 66 0f 12 *
    movlpd [eax], xmm0      ; 66 0f 13 *
_
    unpcklpd xmm0, [eax]    ; 66 0f 14 *
    unpckhpd xmm0, [eax]    ; 66 0f 15 *
_
    movhpd xmm0, [eax]      ; 66 0f 16 *
    movhpd [eax], xmm0      ; 66 0f 17 *
_
    movss xmm0, [eax]   ; f3 0f 10 *
    movss [eax], xmm0   ; f3 0f 11 *
_
    movsldup xmm0, [eax]; f3 0f 12 *
    movshdup xmm0, [eax]; f3 0f 16 *
_
    movsd xmm0, [eax]   ; f2 0f 10 *
    movsd [eax], xmm0   ; f2 0f 11 *
_
    movddup xmm0, [eax] ; f2 0f 12 *
_
    mov eax, cr0 ; 0f 20 ??
    mov eax, dr0 ; 0f 21 ??
    mov cr0, eax ; 0f 22 ??
    mov dr0, eax ; 0f 23
_
    movaps xmm0, [eax]      ; 0f 28 *
    movaps [eax], xmm0      ; 0f 29 *
_
    movntps [eax] , xmm0    ; 0f 2b *
_
    cvtpi2ps xmm0 , [eax]   ; 0f 2a *
    cvttps2pi mm0 , [eax]   ; 0f 2c *
    cvtps2pi mm0 , [eax]    ; 0f 2d *
_
    ucomiss xmm0 , [eax]    ; 0f 2e *
    comiss xmm0 , [eax]     ; 0f 2e *
_
    movmskps eax, xmm0 ; 0F50C0
_
    punpcklbw mm0, [eax] ; 0F60 *
_
    pshufw mm0, [eax], 00h ; 0F70 *
_
    xadd [eax], al    ; 0f c0
_
    pavgb mm0, [eax]    ; 0f e0
_
    popcnt eax , [eax] ; 0FB8 *
    popcnt eax, [eax] ; f3 0f b8 * ??
_
    lddqu xmm0, [eax] ; f2 0f f0 00
_
    bsr eax, [eax] ; 0f bd *
_
    lzcnt eax, [eax] ; f3 0f bd *
_
    ;db 0fh, 024h, 0c0h, 00
_
    crc32 eax, byte [eax]   ; f2 0f 38 f0 *
    crc32 eax, [eax]        ; f2 0f 38 f1 *
_
    syscall                         ;0f05 64b only
_
    clts                            ;0f06
_
    sysret                          ;0f07 64b only
_
    invd                            ;0f08
_
    wbinvd                          ;0f09
_
    ud2                             ;0f0b
_
    prefetch [eax]                  ;0f0d00
_
    femms                           ;0f0e
_
    movups xmm0, dqword [eax]       ;0f1000
_
    movups dqword [eax], xmm0       ;0f1100
_
    movlps xmm0, qword [eax]        ;0f1200
    movlps qword [eax], xmm0        ;0f1300
_
    unpcklps xmm0, dqword [eax]     ;0f1400
    unpckhps xmm0, dqword [eax]     ;0f1500
_
    movhps xmm0, qword [eax]        ;0f1600
    movhps qword [eax], xmm0        ;0f1700
_
    prefetchnta [eax]               ;0f1800
;_
    ;nop dword [eax]                 ;0f1f00
_
    movaps xmm0, dqword [eax]       ;0f2800
    movaps dqword [eax], xmm0       ;0f2900
_
    cvtpi2ps xmm0, qword [eax]      ;0f2a00
_
    movntps dqword [eax], xmm0      ;0f2b00
_
    cvttps2pi mm0, qword [eax]      ;0f2c00
_
    cvtps2pi mm0, qword [eax]       ;0f2d00
_
    ucomiss xmm0, dword [eax]       ;0f2e00
    comiss xmm0, dword [eax]        ;0f2f00
_
    wrmsr                           ;0f30
    rdtsc                           ;0f31
    rdmsr                           ;0f32
    rdpmc                           ;0f33
_
    sysenter                        ;0f34
    sysexit                         ;0f35
_
    cmovo eax, [eax]                ;0f4000
    cmovno eax, [eax]               ;0f4100
    cmovb eax, [eax]                ;0f4200
    cmovae eax, [eax]               ;0f4300
    cmovz eax, [eax]                ;0f4400
    cmovnz eax, [eax]               ;0f4500
    cmovbe eax, [eax]               ;0f4600
    cmova eax, [eax]                ;0f4700
    cmovs eax, [eax]                ;0f4800
    cmovns eax, [eax]               ;0f4900
    cmovp eax, [eax]                ;0f4a00
    cmovnp eax, [eax]               ;0f4b00
    cmovl eax, [eax]                ;0f4c00
    cmovge eax, [eax]               ;0f4d00
    cmovle eax, [eax]               ;0f4e00
    cmovg eax, [eax]                ;0f4f00
_
    sqrtps xmm0, dqword [eax]       ;0f5100
    rsqrtps xmm0, dqword [eax]      ;0f5200
_
    rcpps xmm0, dqword [eax]        ;0f5300
_
    andps xmm0, dqword [eax]        ;0f5400
    andnps xmm0, dqword [eax]       ;0f5500
_
    orps xmm0, dqword [eax]         ;0f5600
    xorps xmm0, dqword [eax]        ;0f5700
_
    addps xmm0, dqword [eax]        ;0f5800
    subps xmm0, dqword [eax]        ;0f5c00
    mulps xmm0, dqword [eax]        ;0f5900
    divps xmm0, dqword [eax]        ;0f5e00
_
    cvtps2pd xmm0, qword [eax]      ;0f5a00
    cvtdq2ps xmm0, dqword [eax]     ;0f5b00
_
    minps xmm0, dqword [eax]        ;0f5d00
    maxps xmm0, dqword [eax]        ;0f5f00
_
    punpcklbw mm0, qword [eax]      ;0f6000
    punpcklwd mm0, qword [eax]      ;0f6100
    punpckldq mm0, qword [eax]      ;0f6200
_
    packsswb mm0, qword [eax]       ;0f6300
    packuswb mm0, qword [eax]       ;0f6700
_
    pcmpgtb mm0, qword [eax]        ;0f6400
    pcmpgtw mm0, qword [eax]        ;0f6500
    pcmpgtd mm0, qword [eax]        ;0f6600
_
    punpckhbw mm0, qword [eax]      ;0f6800
    punpckhwd mm0, qword [eax]      ;0f6900
    punpckhdq mm0, qword [eax]      ;0f6a00
_
    packssdw mm0, qword [eax]       ;0f6b00
_
    pshufb mm0, qword [eax]         ;0f380000
    pshufw mm0, qword [eax], 0x0    ;0f7000 00
_
    pcmpeqb mm0, qword [eax]        ;0f7400
    pcmpeqw mm0, qword [eax]        ;0f7500
    pcmpeqd mm0, qword [eax]        ;0f7600
_
    emms                            ;0f77
_
    movd mm0, dword [eax]           ;0f6e00
    movq mm0, qword [eax]           ;0f6f00
    movd dword [eax], mm0           ;0f7e00
    movq qword [eax], mm0           ;0f7f00
_
    seto byte [eax]                 ;0f9000
    setno byte [eax]                ;0f9100
    setb byte [eax]                 ;0f9200
    setae byte [eax]                ;0f9300
    setz byte [eax]                 ;0f9400
    setnz byte [eax]                ;0f9500
    setbe byte [eax]                ;0f9600
    seta byte [eax]                 ;0f9700
    sets byte [eax]                 ;0f9800
    setns byte [eax]                ;0f9900
    setp byte [eax]                 ;0f9a00
    setnp byte [eax]                ;0f9b00
    setl byte [eax]                 ;0f9c00
    setge byte [eax]                ;0f9d00
    setle byte [eax]                ;0f9e00
    setg byte [eax]                 ;0f9f00
_
    cpuid                           ;0fa2
_
    bt [eax], eax                   ;0fa300
_
    shld [eax], eax, 0x0            ;0fa400 00
    shld [eax], eax, cl             ;0fa500
_
    push fs                         ;0fa0
    pop fs                          ;0fa1
    push gs                         ;0fa8
    pop gs                          ;0fa9
_
    rsm                             ;0faa
_
    bts [eax], eax                  ;0fab00
_
    shrd [eax], eax, 0x0            ;0fac00 00
    shrd [eax], eax, cl             ;0fad00
_
    fxsave [eax]                    ;0fae00
_
    imul eax, [eax]                 ;0faf00
_
    cmpxchg [eax], al               ;0fb000
    cmpxchg [eax], eax              ;0fb100
    cmpxchg8b [eax]
_
    vmptrld [eax]
    vmclear [eax]
    vmxon [eax]
    vmptrst [eax]
_
    lss eax, dword [eax]            ;0fb200
_
    btr [eax], eax                  ;0fb300
_
    lfs eax, dword [eax]            ;0fb400
    lgs eax, dword [eax]            ;0fb500
_
    movzx eax, byte [eax]           ;0fb600
    movzx eax, word [eax]           ;0fb700
_
    ud2                             ;0fb9
_
    btc [eax], eax                  ;0fbb00
_
    bsf eax, [eax]                  ;0fbc00
_
    bsr eax, [eax]                  ;0fbd00
_
    movsx eax, byte [eax]           ;0fbe00
    movsx eax, word [eax]           ;0fbf00
_
    xadd [eax], al                  ;0fc000
    xadd [eax], eax                 ;0fc100
_
    cmpeqps xmm0, dqword [eax]      ;0fc20000
_
    movnti [eax], eax               ;0fc300
_
    pinsrw mm0, word [eax], 0x0     ;0fc400 00
    pextrw eax, mm0, 0              ; 0fc5c000
_
    shufps xmm0, dqword [eax], 0x0  ;0fc600 00
_
    bswap eax                       ;0fc8
    bswap ecx                       ;0fc9
    bswap edx                       ;0fca
    bswap ebx                       ;0fcb
    bswap esp                       ;0fcc
    bswap ebp                       ;0fcd
    bswap esi                       ;0fce
    bswap edi                       ;0fcf
_
    PREFIX_OPERANDSIZE
    bswap eax ; xor ax, ax : result officially undefined, actually typically 0
_
    psrlw mm0, qword [eax]          ;0fd100
    psrld mm0, qword [eax]          ;0fd200
    psrlq mm0, qword [eax]          ;0fd300
_
    pmulhw mm0, qword [eax]         ;0fe500
    pmullw mm0, qword [eax]         ;0fd500
_
    psubusb mm0, qword [eax]        ;0fd800
    psubusw mm0, qword [eax]        ;0fd900
_
    pand mm0, qword [eax]           ;0fdb00
    pandn mm0, qword [eax]          ;0fdf00
    por mm0, qword [eax]            ;0feb00
    pxor mm0, qword [eax]           ;0fef00
_
    paddusb mm0, qword [eax]        ;0fdc00
    paddusw mm0, qword [eax]        ;0fdd00
_
    pmaxub mm0, qword [eax]         ;0fde00
    pminub mm0, qword [eax]         ;0fda00
_
    pavgb mm0, qword [eax]          ;0fe000
    pavgw mm0, qword [eax]          ;0fe300
_
    psraw mm0, qword [eax]          ;0fe100
    psrad mm0, qword [eax]          ;0fe200
_
    pmulhuw mm0, qword [eax]        ;0fe400
_
    movntq qword [eax], mm0         ;0fe700
_
    psubsb mm0, qword [eax]         ;0fe800
    psubsw mm0, qword [eax]         ;0fe900
_
    pminsw mm0, qword [eax]         ;0fea00
    pmaxsw mm0, qword [eax]         ;0fee00
_
    paddsb mm0, qword [eax]         ;0fec00
    paddsw mm0, qword [eax]         ;0fed00
_
    psllw mm0, qword [eax]          ;0ff100
    pslld mm0, qword [eax]          ;0ff200
    psllq mm0, qword [eax]          ;0ff300
_
    pmuludq mm0, qword [eax]        ;0ff400
_
    pmaddwd mm0, qword [eax]        ;0ff500
_
    psadbw mm0, qword [eax]         ;0ff600
_
    psubb mm0, qword [eax]          ;0ff800
    psubw mm0, qword [eax]          ;0ff900
    psubd mm0, qword [eax]          ;0ffa00
    psubq mm0, qword [eax]          ;0ffb00
_
    paddb mm0, qword [eax]          ;0ffc00
    paddw mm0, qword [eax]          ;0ffd00
    paddd mm0, qword [eax]          ;0ffe00
    paddq mm0, qword [eax]          ;0ffe00
_
    bound eax, [eax]                ;6200
_
    arpl [eax], ax                  ;6300
_
    shld [eax], ax, 0x0             ;66 0fa400 00
    shld [eax], ax, cl              ;66 0fa500
_
    rsm                             ;66 0faa
_
    shrd [eax], ax, 0x0             ;66 0fac00 00
    shrd [eax], ax, cl              ;66 0fad00
_
    lss ax, word [eax]              ;66 0fb200
_
    lfs ax, word [eax]              ;66 0fb400
_
    lgs ax, word [eax]              ;66 0fb500
_
    movzx ax, byte [eax]            ;66 0fb600
    movzx ax, [eax]                 ;66 0fb700
_
    ud2                             ;66 0fb9
_
    movsx ax, byte [eax]            ;66 0fbe00
    movsx ax, [eax]                 ;66 0fbf00
_
    xadd [eax], al                  ;66 0fc000
    xadd [eax], ax                  ;66 0fc100
_
    movnti [eax], eax               ;66 0fc300
_
    movupd xmm0, dqword [eax]       ;660f1000
    movupd dqword [eax], xmm0       ;660f1100
_
    movlpd xmm0, qword [eax]        ;660f1200
    movlpd qword [eax], xmm0        ;660f1300
_
    unpcklpd xmm0, dqword [eax]     ;660f1400
    unpckhpd xmm0, dqword [eax]     ;660f1500
_
    movhpd xmm0, qword [eax]        ;660f1600
    movhpd qword [eax], xmm0        ;660f1700
_
    movapd xmm0, dqword [eax]       ;660f2800
    movapd dqword [eax], xmm0       ;660f2900
_
_
    movntpd dqword [eax], xmm0      ;660f2b00
_
    cvtpi2pd xmm0, qword [eax]      ;660f2a00
    cvttpd2pi mm0, dqword [eax]     ;660f2c00
    cvtpd2pi mm0, dqword [eax]      ;660f2d00 ??
_
    ucomisd xmm0, qword [eax]       ;660f2e00
    comisd xmm0, qword [eax]        ;660f2f00
_
    pshufb xmm0, dqword [eax]       ;660f380000
    pshufd xmm0, dqword [eax], 0x0  ;660f7000 00
_
    sqrtpd xmm0, dqword [eax]       ;660f5100
_
    orpd xmm0, dqword [eax]         ;660f5600
    xorpd xmm0, dqword [eax]        ;660f5700
_
    addpd xmm0, dqword [eax]        ;660f5800
    subpd xmm0, dqword [eax]        ;660f5c00
_
    mulpd xmm0, dqword [eax]        ;660f5900
    divpd xmm0, dqword [eax]        ;660f5e00
_
    cvtpd2ps xmm0, dqword [eax]     ;660f5a00
    cvtps2dq xmm0, dqword [eax]     ;660f5b00
_
    minpd xmm0, dqword [eax]        ;660f5d00
    maxpd xmm0, dqword [eax]        ;660f5f00
_
    punpcklbw xmm0, dqword [eax]    ;660f6000
    punpcklwd xmm0, dqword [eax]    ;660f6100
    punpckldq xmm0, dqword [eax]    ;660f6200
_
    packsswb xmm0, dqword [eax]     ;660f6300
_
    pcmpgtb xmm0, dqword [eax]      ;660f6400
    pcmpgtw xmm0, dqword [eax]      ;660f6500
    pcmpgtd xmm0, dqword [eax]      ;660f6600
_
    packuswb xmm0, dqword [eax]     ;660f6700
_
    punpckhbw xmm0, dqword [eax]    ;660f6800
    punpckhwd xmm0, dqword [eax]    ;660f6900
    punpckhdq xmm0, dqword [eax]    ;660f6a00
_
    packssdw xmm0, dqword [eax]     ;660f6b00
_
    punpcklqdq xmm0, dqword [eax]   ;660f6c00
    punpckhqdq xmm0, dqword [eax]   ;660f6d00
_
    movd xmm0, dword [eax]          ;660f6e00
    movd dword [eax], xmm0          ;660f7e00
_
    movdqa xmm0, dqword [eax]       ;660f6f00
    movdqa dqword [eax], xmm0       ;660f7f00
_
    pcmpeqb xmm0, dqword [eax]      ;660f7400
    pcmpeqw xmm0, dqword [eax]      ;660f7500
    pcmpeqd xmm0, dqword [eax]      ;660f7600
_
    extrq xmm0, 0x0, 0x0            ;660f7800 00 00
    extrq xmm0, xmm0                ;660f7900
_
    haddpd xmm0, dqword [eax]       ;660f7c00
    hsubpd xmm0, dqword [eax]       ;660f7d00
_
    cmppd xmm0, dqword [eax], 0     ;660fc20000
_
    cmpeqpd xmm0, dqword [eax]      ;660fc20000
    cmpltpd xmm0, dqword [eax]      ;660fc20001
    cmplepd xmm0, dqword [eax]      ;660fc20002
    cmpunordpd xmm0, dqword [eax]   ;660fc20003
    cmpneqpd xmm0, dqword [eax]     ;660fc20004
    cmpnltpd xmm0, dqword [eax]     ;660fc20005
    cmpnlepd xmm0, dqword [eax]     ;660fc20006
    cmpordpd xmm0, dqword [eax]     ;660fc20007
_
    pinsrw xmm0, word [eax], 0x0    ;660fc400 00
    pextrw eax, xmm0, 0             ;66 0fc5c000
_
    shufpd xmm0, dqword [eax], 0x0  ;660fc600 00
_
    addsubpd xmm0, dqword [eax]     ;660fd000
_
    psrlw xmm0, dqword [eax]        ;660fd100
    psrld xmm0, dqword [eax]        ;660fd200
    psrlq xmm0, dqword [eax]        ;660fd300
_
    paddq xmm0, dqword [eax]        ;660fd400
_
    pmullw xmm0, dqword [eax]       ;660fd500
_
    movq qword [eax], xmm0          ;660fd600
_
    psubusb xmm0, dqword [eax]      ;660fd800
    psubusw xmm0, dqword [eax]      ;660fd900
_
    pminub xmm0, dqword [eax]       ;660fda00
    pmaxub xmm0, dqword [eax]       ;660fde00
_
    pand xmm0, dqword [eax]         ;660fdb00
    pandn xmm0, dqword [eax]        ;660fdf00
_
    paddusb xmm0, dqword [eax]      ;660fdc00
    paddusw xmm0, dqword [eax]      ;660fdd00
_
    pavgb xmm0, dqword [eax]        ;660fe000
    pavgw xmm0, dqword [eax]        ;660fe300
_
    psraw xmm0, dqword [eax]        ;660fe100
    psrad xmm0, dqword [eax]        ;660fe200
_
    pmulhuw xmm0, dqword [eax]      ;660fe400
    pmulhw xmm0, dqword [eax]       ;660fe500
_
    cvttpd2dq xmm0, dqword [eax]    ;660fe600
_
    movntdq dqword [eax], xmm0      ;660fe700
_
    psubsb xmm0, dqword [eax]       ;660fe800
    psubsw xmm0, dqword [eax]       ;660fe900
_
    pminsw xmm0, dqword [eax]       ;660fea00
    pmaxsw xmm0, dqword [eax]       ;660fee00
_
    por xmm0, dqword [eax]          ;660feb00
_
    paddsb xmm0, dqword [eax]       ;660fec00
    paddsw xmm0, dqword [eax]       ;660fed00
_
    pxor xmm0, dqword [eax]         ;660fef00
_
    psllw xmm0, dqword [eax]        ;660ff100
    pslld xmm0, dqword [eax]        ;660ff200
    psllq xmm0, dqword [eax]        ;660ff300
_
    pmuludq xmm0, dqword [eax]      ;660ff400
_
    pmaddwd xmm0, dqword [eax]      ;660ff500
_
    psadbw xmm0, dqword [eax]       ;660ff600
_
    psubb xmm0, dqword [eax]        ;660ff800
    psubw xmm0, dqword [eax]        ;660ff900
    psubd xmm0, dqword [eax]        ;660ffa00
    psubq xmm0, dqword [eax]        ;660ffb00
_
    paddb xmm0, dqword [eax]        ;660ffc00
    paddw xmm0, dqword [eax]        ;660ffd00
    paddd xmm0, dqword [eax]        ;660ffe00
    paddq xmm0, dqword [eax]        ;660ffe00
_
    add [bx+si], al                 ;67 0000
_
    push 0                        ;6a 00
    push 01234578h                ;68 00000000
_
    imul eax, [eax], 012345678h   ;6900 00000000
    imul eax, [eax], 0            ;6b00 00
_
    insb                            ;6c
    insd                            ;6d
_
    outsb                           ;6e
    outsd                           ;6f
_
_start:
    jo $ + 2                       ;70 00
    jno $ + 2                      ;71 00
    jb  $ + 2                      ;72 00
    jae $ + 2                      ;73 00
    jz  $ + 2                      ;74 00
    jnz $ + 2                      ;75 00
    jbe $ + 2                      ;76 00
    ja  $ + 2                      ;77 00
    js  $ + 2                      ;78 00
    jns $ + 2                      ;79 00
    jp  $ + 2                      ;7a 00
    jnp $ + 2                      ;7b 00
    jl  $ + 2                      ;7c 00
    jge $ + 2                      ;7d 00
    jle $ + 2                      ;7e 00
    jg  $ + 2                      ;7f 00
_
    jo word  $ + 5                 ;66 0f80 0000
    jno word $ + 5                ;66 0f81 0000
    jb word  $ + 5                ;66 0f82 0000
    jae word $ + 5                ;66 0f83 0000
    jz word  $ + 5                ;66 0f84 0000
    jnz word $ + 5                ;66 0f85 0000
    jbe word $ + 5                ;66 0f86 0000
    js word  $ + 5                ;66 0f88 0000
    jns word $ + 5                ;66 0f89 0000
    jp word  $ + 5                ;66 0f8a 0000
    jnp word $ + 5                ;66 0f8b 0000
    jl word  $ + 5                ;66 0f8c 0000
    jge word $ + 5                ;66 0f8d 0000
    jle word $ + 5                ;66 0f8e 0000
    jg word  $ + 5                ;66 0f8f 0000
_
    jo  dword $ + 6     ;0f80 00000000
    jno dword $ + 6     ;0f81 00000000
    jb  dword $ + 6     ;0f82 00000000
    jae dword $ + 6     ;0f83 00000000
    jz  dword $ + 6     ;0f84 00000000
    jnz dword $ + 6     ;0f85 00000000
    jbe dword $ + 6     ;0f86 00000000
    ja  dword $ + 6     ;0f87 00000000
    js  dword $ + 6     ;0f88 00000000
    jns dword $ + 6     ;0f89 00000000
    jp  dword $ + 6     ;0f8a 00000000
    jnp dword $ + 6     ;0f8b 00000000
    jl  dword $ + 6     ;0f8c 00000000
    jge dword $ + 6     ;0f8d 00000000
    jle dword $ + 6     ;0f8e 00000000
    jg  dword $ + 6     ;0f8f 00000000
_
    seto byte [eax]                 ;66 0f9000
    setno byte [eax]                ;66 0f9100
    setb byte [eax]                 ;66 0f9200
    setae byte [eax]                ;66 0f9300
    setz byte [eax]                 ;66 0f9400
    setnz byte [eax]                ;66 0f9500
    setbe byte [eax]                ;66 0f9600
    seta byte [eax]                 ;66 0f9700
    sets byte [eax]                 ;66 0f9800
    setns byte [eax]                ;66 0f9900
    setp byte [eax]                 ;66 0f9a00
    setnp byte [eax]                ;66 0f9b00
    setl byte [eax]                 ;66 0f9c00
    setge byte [eax]                ;66 0f9d00
    setle byte [eax]                ;66 0f9e00
    setg byte [eax]                 ;66 0f9f00
_
    add byte [eax], 0x0             ;8000 00
    add dword [eax], 0x0            ;8100 00000000
    add byte [eax], 0x0             ;8200 00    TODO enforce encoding
    add dword [eax], 0x0            ;8300 00
_
    test [eax], al                  ;8400
    test [eax], eax                 ;8500
_
    xchg [eax], al                  ;8600
    xchg [eax], eax                 ;8700
_
    mov [eax], al                   ;8800
    mov [eax], eax                  ;8900
_
    mov al, [eax]                   ;8a00
    mov eax, [eax]                  ;8b00
_
    mov [eax], es                   ;8c00
    mov es, [eax]                   ;8e00
_
    lea eax, [eax]                  ;8d00
_
    pop dword [eax]                 ;8f00
_
    nop                             ;90
_
    xchg eax, eax                   ;90
    xchg ecx, eax                   ;91
    xchg edx, eax                   ;92
    xchg ebx, eax                   ;93
    xchg esp, eax                   ;94
    xchg ebp, eax                   ;95
    xchg esi, eax                   ;96
    xchg edi, eax                   ;97
_
    cwde                            ;98
    cdq                             ;99
_
    call far 0x0:0x0                ;9a 00000000 0000
_
    wait                            ;9b
_
    pushf                           ;9c
    popf                            ;9d
    sahf                            ;9e
    lahf                            ;9f
_
    mov al, [0x0]                   ;a0 00000000
    mov eax, [0x0]                  ;a1 00000000
    mov [0x0], al                   ;a2 00000000
    mov [0x0], eax                  ;a3 00000000 ; enforce
_
    movsb                           ;a4
    movsd                           ;a5
_
    cmpsb                           ;a6
    cmpsd                           ;a7
_
    stosb                           ;aa
    stosd                           ;ab
_
    lodsb                           ;ac
    lodsd                           ;ad
_
    scasb                           ;ae
    scasd                           ;af
_
    test al, 0x0                    ;a8 00
    test eax, 0x0                   ;a9 00000000
_
    mov al, 0x0                     ;b0 00
    mov cl, 0x0                     ;b1 00
    mov dl, 0x0                     ;b2 00
    mov bl, 0x0                     ;b3 00
    mov ah, 0x0                     ;b4 00
    mov ch, 0x0                     ;b5 00
    mov dh, 0x0                     ;b6 00
    mov bh, 0x0                     ;b7 00
_
    mov eax, 0x0                    ;b8 00000000
    mov ecx, 0x0                    ;b9 00000000
    mov edx, 0x0                    ;ba 00000000
    mov ebx, 0x0                    ;bb 00000000
    mov esp, 0x0                    ;bc 00000000
    mov ebp, 0x0                    ;bd 00000000
    mov esi, 0x0                    ;be 00000000
    mov edi, 0x0                    ;bf 00000000
_
    rol byte [eax], 0x0             ;c000 00
    rol dword [eax], 0x0            ;c100 00
_
    ret 0x0                         ;c2 0000
    ret                             ;c3
_
    les eax, dword [eax]            ;c400
    lds eax, dword [eax]            ;c500
_
    mov byte [eax], 0x0             ;c600 00
    mov dword [eax], 0x0            ;c700 00000000
_
    enter 0x0, 0x0                  ;c8 0000 00
_
    leave                           ;c9
_
    retf 0x0                        ;ca 0000
    retf                            ;cb
_
    int 0x0                         ;cd 00
_
    rol byte [eax], 0               ;d000
    rol dword [eax], 0              ;d100
_
    rol byte [eax], cl              ;d200
    rol dword [eax], cl             ;d300
_
    in al, 0x0                      ;e4 00
    in eax, 0x0                     ;e5 00
    in al, dx                       ;ec
    in eax, dx                      ;ed
_
    out 0x0, al                     ;e6 00
    out 0x0, eax                    ;e7 00
    out dx, al                      ;ee
    out dx, eax                     ;ef
_
    call 0x1d05                     ;e8 00000000
_
    jmp 0x1d25                      ;e9 00000000
_
    jmp far 0x0:0x0                 ;ea 00000000 0000
_
    jmp $ + 0x1d                   ;eb 00
_
    lock add [eax], al              ;f0 0000
_
    movsd xmm0, qword [eax]         ;f20f1000
    movsd qword [eax], xmm0         ;f20f1100
_
    movddup xmm0, qword [eax]       ;f20f1200
_
    cvtsi2sd xmm0, dword [eax]      ;f20f2a00
_
    movntsd qword [eax], xmm0       ;f20f2b00
_
    cvttsd2si eax, qword [eax]      ;f20f2c00
_
    cvtsd2si eax, qword [eax]       ;f20f2d00
_
    sqrtsd xmm0, qword [eax]        ;f20f5100
_
    addsd xmm0, qword [eax]         ;f20f5800
    subsd xmm0, qword [eax]         ;f20f5c00
    mulsd xmm0, qword [eax]         ;f20f5900
    divsd xmm0, qword [eax]         ;f20f5e00
_
    cvtsd2ss xmm0, qword [eax]      ;f20f5a00
_
    minsd xmm0, qword [eax]         ;f20f5d00
    maxsd xmm0, qword [eax]         ;f20f5f00
_
    pshuflw xmm0, dqword [eax], 0x0 ;f20f7000 00
_
    haddps xmm0, dqword [eax]       ;f20f7c00
    hsubps xmm0, dqword [eax]       ;f20f7d00
_
    cmpsd xmm0, [eax], 0     ;f20fc20000
_
    cmpeqsd xmm0, [eax]      ;f20fc20000
    cmpltsd xmm0, [eax]      ;f20fc20001
    cmplesd xmm0, [eax]      ;f20fc20002
    cmpunordsd xmm0, [eax]   ;f20fc20003
    cmpneqsd xmm0, [eax]     ;f20fc20004
    cmpnltsd xmm0, [eax]     ;f20fc20005
    cmpnlesd xmm0, [eax]     ;f20fc20006
    cmpordsd xmm0, [eax]     ;f20fc20007
_
    addsubps xmm0, dqword [eax]     ;f20fd000
_
    cvtpd2dq xmm0, dqword [eax]     ;f20fe600
_
    lddqu xmm0, [eax]               ;f20ff000
_
    movss xmm0, dword [eax]         ;f30f1000
    movss dword [eax], xmm0         ;f30f1100
_
    movsldup xmm0, dqword [eax]      ;f30f1200
    movshdup xmm0, dqword [eax]     ;f30f1600
_
    cvtsi2ss xmm0, dword [eax]      ;f30f2a00
_
    movntss dword [eax], xmm0       ;f30f2b00
_
    cvttss2si eax, dword [eax]      ;f30f2c00
_
    cvtss2si eax, dword [eax]       ;f30f2d00
_
    sqrtss xmm0, dword [eax]        ;f30f5100
    rsqrtss xmm0, dword [eax]       ;f30f5200
_
    rcpss xmm0, dword [eax]         ;f30f5300
_
    addss xmm0, dword [eax]         ;f30f5800
    subss xmm0, dword [eax]         ;f30f5c00
    mulss xmm0, dword [eax]         ;f30f5900
    divss xmm0, dword [eax]         ;f30f5e00
_
    cvtss2sd xmm0, dword [eax]      ;f30f5a00
_
    cvttps2dq xmm0, dqword [eax]    ;f30f5b00
_
    minss xmm0, dword [eax]         ;f30f5d00
    maxss xmm0, dword [eax]         ;f30f5f00
_
    movdqu xmm0, dqword [eax]       ;f30f6f00
    movdqu dqword [eax], xmm0       ;f30f7f00
_
    pshufhw xmm0, dqword [eax], 0x0 ;f30f7000 00
_
    movq xmm0, qword [eax]          ;f30f7e00
_
    popcnt eax, [eax]               ;f30fb800
_
    lzcnt eax, [eax]                ;f30fbd00
_
    cmpeqss xmm0, dword [eax]       ;f30fc20000
_
    cvtdq2pd xmm0, qword [eax]      ;f30fe600
_
    hlt                             ;f4
_
    cmc                             ;f5
_
    test byte [eax], 0x0            ;f600 00
    test dword [eax], 0x0           ;f700 00000000
_
    clc                             ;f8
    stc                             ;f9
_
    cli                             ;fa
    sti                             ;fb
_
    cld                             ;fc
    std                             ;fd
_
    inc byte [eax]                  ;fe00
    inc dword [eax]                 ;ff00
_
    vpmadcsswd  xmm0, xmm0, xmm0, xmm0
_
    vcvtph2ps   xmm0, xmm0, 0
_
    vcvtps2ph   xmm0, xmm0, 0
_
    vfmaddpd    xmm0, xmm0, xmm0, xmm0
    vfmaddps    xmm0, xmm0, xmm0, xmm0
    vfmaddsd    xmm0, xmm0, xmm0, xmm0
    vfmaddss    xmm0, xmm0, xmm0, xmm0
_
    vfmaddsubpd xmm0, xmm0, xmm0, xmm0
    vfmaddsubps xmm0, xmm0, xmm0, xmm0
_
    vfmsubaddpd xmm0, xmm0, xmm0, xmm0
    vfmsubaddps xmm0, xmm0, xmm0, xmm0
_
    vfmsubpd    xmm0, xmm0, xmm0, xmm0
    vfmsubps    xmm0, xmm0, xmm0, xmm0
    vfmsubsd    xmm0, xmm0, xmm0, xmm0
    vfmsubss    xmm0, xmm0, xmm0, xmm0
_
    vfnmaddpd   xmm0, xmm0, xmm0, xmm0
    vfnmaddps   xmm0, xmm0, xmm0, xmm0
    vfnmaddsd   xmm0, xmm0, xmm0, xmm0
    vfnmaddss   xmm0, xmm0, xmm0, xmm0
_
    vfnmsubpd   xmm0, xmm0, xmm0, xmm0
    vfnmsubps   xmm0, xmm0, xmm0, xmm0
    vfnmsubsd   xmm0, xmm0, xmm0, xmm0
    vfnmsubss   xmm0, xmm0, xmm0, xmm0
_
    vfrczpd     xmm0, xmm0
    vfrczps     xmm0, xmm0
    vfrczsd     xmm0, xmm0
    vfrczss     xmm0, xmm0
_
    vpcmov      xmm0, xmm0, xmm0, xmm0
_
    vpcomb      xmm0, xmm0, xmm0, 0
    vpcomd      xmm0, xmm0, xmm0, 0
    vpcomq      xmm0, xmm0, xmm0, 0
_
    vpcomub     xmm0, xmm0, xmm0, 0
    vpcomud     xmm0, xmm0, xmm0, 0
    vpcomuq     xmm0, xmm0, xmm0, 0
    vpcomuw     xmm0, xmm0, xmm0, 0
_
    vpcomw      xmm0, xmm0, xmm0, 0
_
    vphaddbd    xmm0, xmm0
    vphaddbq    xmm0, xmm0
    vphaddbw    xmm0, xmm0
    vphadddq    xmm0, xmm0
_
    vphaddubd   xmm0, xmm0
    vphaddubq   xmm0, xmm0
    vphaddubw   xmm0, xmm0
    vphaddudq   xmm0, xmm0
    vphadduwd   xmm0, xmm0
    vphadduwq   xmm0, xmm0
_
    vphaddwd    xmm0, xmm0
    vphaddwq    xmm0, xmm0
_
    vphsubbw    xmm0, xmm0
    vphsubdq    xmm0, xmm0
    vphsubwd    xmm0, xmm0
_
    vpmacsdd    xmm0, xmm0, xmm0, xmm0
_
    vpmacsdqh   xmm0, xmm0, xmm0, xmm0
    vpmacsdql   xmm0, xmm0, xmm0, xmm0
_
    vpmacssdd   xmm0, xmm0, xmm0, xmm0
_
    vpmacssdqh  xmm0, xmm0, xmm0, xmm0
_
    vpmacssdql  xmm0, xmm0, xmm0, xmm0
_
    vpmacsswd   xmm0, xmm0, xmm0, xmm0
    vpmacssww   xmm0, xmm0, xmm0, xmm0
_
    vpmacswd    xmm0, xmm0, xmm0, xmm0
    vpmacsww    xmm0, xmm0, xmm0, xmm0
_
    vpmadcsswd  xmm0, xmm0, xmm0, xmm0
_
    vpmadcswd   xmm0, xmm0, xmm0, xmm0
_
    vpperm      xmm0, xmm0, xmm0, xmm0
_
    vprotb      xmm0, xmm0, xmm0
    vprotd      xmm0, xmm0, xmm0
    vprotq      xmm0, xmm0, xmm0
    vprotw      xmm0, xmm0, xmm0
_
    vpshab      xmm0, xmm0, xmm0
    vpshad      xmm0, xmm0, xmm0
    vpshaq      xmm0, xmm0, xmm0
    vpshaw      xmm0, xmm0, xmm0
_
    vpshlb      xmm0, xmm0, xmm0
    vpshld      xmm0, xmm0, xmm0
    vpshlq      xmm0, xmm0, xmm0
    vpshlw      xmm0, xmm0, xmm0
_
    f2xm1               ;d9f0 ; 2 to the x power minus 1
    fabs      ; absolute value of st0(0)
    fadd dword [eax]    ;d800
    fadd qword [eax]    ;dc00
    fadd st0,st0        ;d8c0
    faddp st0,st0       ;dec0
    fbld tword [eax]    ;df20
    fbstp tword [eax]   ;df30
    fchs
    fclex               ;9b dbe2
    fcmovb st0,st0      ;dac0
    fcmovbe st0,st0     ;dad0
    fcmove st0,st0      ;dac8
    fcmovnb st0,st0     ;dbc0
    fcmovnbe st0,st0    ;dbd0
    fcmovne st0,st0     ;dbc8
    fcmovnu st0,st0     ;dbd8
    fcmovu st0,st0      ;dad8
    fcom dword [eax]    ;d810
    fcom qword [eax]    ;dc10
    fcom st0            ;d8d0
    fcomi st0,st0       ;dbf0
    fcomip st0, st0     ; compare st0(0) to st0(i) and set cpu flags and pop st0(0)
    fcomp dword [eax]   ;d818
    fcomp qword [eax]   ;dc18
    fcomp st0           ;d8d8
    fcompp    ; compare st0(0) to st0(1) and pop both registers
    fcos                ;d9ff
    fdecstp   ; decrease stack pointer
    fdisi               ;dbe1 = ???
    fdiv dword [eax]    ;d830
    fdiv qword [eax]    ;dc30
    fdiv st0,st0        ;d8f0
    fdiv st0,st0        ;dcf8
    fdivp st0,st0       ;def8
    fdivr dword [eax]   ;d838
    fdivr qword [eax]   ;dc38
    fdivr st0,st0       ;d8f8
    fdivr st0,st0       ;dcf0
    fdivrp st0,st0      ;def0
    feni                ;dbe0 = ??
    ffree st0           ;ddc0
    ffreep st0          ;dfc0 undoc ?
    fiadd dword [eax]   ;da00
    fiadd word [eax]    ;de00
    ficom dword [eax]   ;da10
    ficom word [eax]    ;de10
    ficomp dword [eax]  ;da18
    ficomp word [eax]   ;de18
    fidiv dword [eax]   ;da30
    fidiv word [eax]    ;de30
    fidivr dword [eax]  ;da38
    fidivr word [eax]   ;de38
    fild dword [eax]    ;db00
    fild qword [eax]    ;df28
    fild word [eax]     ;df00
    fimul dword [eax]   ;da08
    fimul word [eax]    ;de08
    fincstp   ; increase stack pointer
    finit               ;dbe3
    fist dword [eax]    ;db10
    fist word [eax]     ;df10
    fistp dword [eax]   ;db18
    fistp qword [eax]   ;df38
    fistp word [eax]    ;df18
    fisttp word [eax]
    fisub dword [eax]   ;da20
    fisub word [eax]    ;de20
    fisubr dword [eax]  ;da28
    fisubr word [eax]   ;de28
    fld dword [eax]     ;d900
    fld qword [eax]     ;dd00
    fld st0             ;d9c0
    fld tword [eax]     ;db28
    fld1                ;d9e8
    fldcw word [eax]    ;d928
    fldenv [eax]        ;d920
    fldl2e    ; load the log base 2 of e (napierian constant)
    fldl2t    ; load the log base 2 of ten
    fldlg2    ; load the log base 10 of 2 (common log of 2)
    fldln2    ; load the log base e of 2 (natural log of 2)
    fldpi               ;d9eb
    fldz                ;d9ee
    fmul dword [eax]    ;d808
    fmul qword [eax]    ;dc08
    fmul st0,st0        ;d8c8
    fmul st0,st0        ;dcc8
    fmulp st0,st0       ;dec8
    fnclex              ;9bdbe2
    fndisi              ;dbe2
    fneni               ;dbe1
    fninit              ;9bdbe3
    fnop                ;d9d0
    fnsave [eax]        ;9bdd30
    fnstcw word [eax]   ;9bd938
    fnstenv [eax]       ;9bd930
    fnstsw word [eax]   ;9bdd38
    fpatan    ; partial arctangent of the ratio st0(1)/st0(0)
    fprem               ;d9f8
    fprem1    ; partial remainder 1
    fptan               ;d9f2
    frndint   ; round st0(0) to an integer
    frstor [eax]        ;dd20
    frstpm              ; replaced by fwait ?
    fsave [eax]         ;dd30
    fscale    ; scale st0(0) by st0(1)
    fsetpm              ; db e4
    fsin                ;d9fe
    fsincos   ; sine and cosine of the angle value in st0(0)
    fsqrt               ;d9fa
    ;fstsg ax
    fst dword [eax]     ;d910
    fst qword [eax]     ;dd10
    fst st0             ;ddd0
    fstcw word [eax]    ;d938
    fstenv [eax]        ;d930
    fstp dword [eax]    ;d918
    fstp qword [eax]    ;dd18
    fstp st0            ;ddd8
    fstp tword [eax]   ;db38
    fstsw word [eax]    ;dd38
    fsub dword [eax]    ;d820
    fsub qword [eax]    ;dc20
    fsub st0,st0        ;d8e0
;   fsub st0,st0        ;dce8
    fsubp st0,st0       ;dee8
    fsubr dword [eax]   ;d828
    fsubr qword [eax]   ;dc28
    fsubr st0,st0       ;d8e8
;   fsubr st0,st0       ;dce0
    fsubrp st0,st0      ;dee0
    ftst
    fucom st0           ;dde0
    fucomi st0,st0      ;dbe8
    fucomip st0         ; unordered compare st0(0) to st0(i) and set cpu flags and pop st0(0)
    fucomp st0          ; unordered compare st0(0) to a floating point value and pop st0(0)
    fucomp st0          ;dde8
    fucompp             ; unordered compare st0(0) to st0(1) and pop both registers
    fxam
    fxch st0            ;d9c8
    fxtract             ; extract exponent and significand
    fyl2x               ;d9f1
    fyl2xp1             ; y*log2(x+1)
    fwait               ;9b
    nop

;undocumented fpu
    db 0d9h, 0d8h       ; fstp1 st0
_
    db 0dch, 0d0h       ; fcom2
_
    db 0dch, 0d8h       ; fcomp3
_
    db 0ddh, 0c8h       ; fxch4 st0
_
    db 0deh, 0d0h       ;fcomp5 st0
_
    db 0dfh, 0c8h       ; fxchg7 st0
_
    db 0dfh, 0d0h       ; fstp8 st0
_
    db 0dfh, 0d8h       ; fstp9 st0

    sldt [eax]                ;0f0000
    sldt eax                   ;660f0000
    str  [eax]                ;0f0008
    str  eax                   ;660f0008
    lldt [eax]                ;0f0010
    lldt ax                   ;0f00d0
    ltr  [eax]                ;0f0018
    ltr  ax                   ;0f00d8
    verr [eax]                ;0f0020
    verr ax                   ;0f00e0
    verw [eax]                ;0f0028
    verw ax                   ;0f00e8

    sgdt [eax]                ;0f0100
    sidt [eax]                ;0f0108
    lgdt [eax]                ;0f0110
    lidt [eax]                ;0f0118
    smsw [eax]                ;0f0120
    lmsw [eax]                ;0f0130
    invlpg [eax]              ;0f0138

    smsw ax                   ;0f01e0
    smsw eax                  ;0f01e0 ; undocumented?
    lmsw ax                   ;0f01f0
    fxsave [eax]              ;0fae00
    fxrstor [eax]             ;0fae08
    ldmxcsr [eax]             ;0fae10
    stmxcsr [eax]             ;0fae18
    xsave [eax]               ;0fae20
    xrstor [eax]              ;0fae28
    clflush [eax]             ;0fae38

    mfence                    ;0faef0
    lfence                    ;0faee8
    sfence                    ;0faef8

    test byte [eax], 0 ; f6 00 00
    db 0f6h, 08h, 00 ;     test byte [eax], 0

    not  byte [eax]
    neg  byte [eax]
    mul  byte [eax]
    imul byte [eax]
    div  byte [eax]
    idiv byte [eax]

    test dword [eax], 0
    db 0f7h, 08h,
        dd 00 ;     test dword [eax], 0

    not  dword [eax]
    neg  dword [eax]
    mul  dword [eax]
    imul dword [eax]
    div  dword [eax]
    idiv dword [eax]
    rol  byte [eax], 0
    ror  byte [eax], 0
    rcl  byte [eax], 0
    rcr  byte [eax], 0
    shl  byte [eax], 0
    shr  byte [eax], 0
    db 0c0h, 30h, 00h ; sal = shl
    sar  byte [eax], 0

    rol  dword [eax], 0
    ror  dword [eax], 0
    rcl  dword [eax], 0
    rcr  dword [eax], 0
    shl  dword [eax], 0
    shr  dword [eax], 0
    db 0c1h, 30h, 0h ; sal = shl
    sal  dword [eax], 0 ; sal = shl
    sar  dword [eax], 0

    ;inc byte [eax]
    ;dec byte [eax]

    ;inc dword [eax]
    ;dec dword [eax]
    call [eax]
    call far [eax]
    ;jmp [eax]
    ;jmp far [eax]
    push dword [eax]
_
    db 0fh, 1fh, 00 ;nop [eax]
    db 0fh, 1fh, 01 ;nop [ecx]
_
    addpd xmm0, dqword [eax]        ;660f5800
    vaddpd xmm0, dqword [eax]        ;660f5800
    vaddpd ymm0, ymm0, ymm0
_
    aesdec      xmm0, xmm0
    aesdeclast  xmm0, xmm0
    aesenc      xmm0, xmm0
    aesenclast  xmm0, xmm0
    aesimc      xmm0, xmm0
    aeskeygenassist xmm0, xmm0, 0
_
    vaesdec      xmm0, xmm0
    vaesdeclast  xmm0, xmm0
    vaesenc      xmm0, xmm0
    vaesenclast  xmm0, xmm0
    vaesimc      xmm0, xmm0
    vaeskeygenassist xmm0, xmm0, 0
_
    vextractf128 xmm0, ymm0, 0
    vbroadcastf128 ymm0, [0]
_
    vzeroall
    vzeroupper
_
    vbroadcastsd ymm0, [0]
    vbroadcastss ymm0, [eax]
_
    vfmaddpd ymm0, ymm0, ymm0, ymm0
    vfmaddps ymm0, ymm0, ymm0, ymm0
    vfmsubpd ymm0, ymm0, ymm0, ymm0
    vfmsubps ymm0, ymm0, ymm0, ymm0
_
    vfmaddsubpd ymm0, ymm0, ymm0, ymm0
    vfmaddsubps ymm0, ymm0, ymm0, ymm0
    vfmsubaddps ymm0, ymm0, ymm0, ymm0
    vfmsubaddpd ymm0, ymm0, ymm0, ymm0
_
    vfnmaddpd ymm0, ymm0, ymm0, ymm0
    vfnmaddps ymm0, ymm0, ymm0, ymm0
    vfnmaddss xmm0, xmm0, xmm0, xmm0
    vfnmaddsd xmm0, xmm0, xmm0, xmm0
_
    vfnmsubpd ymm0, ymm0, ymm0, ymm0
    vfnmsubps ymm0, ymm0, ymm0, ymm0
    vfnmsubss xmm0, xmm0, xmm0, xmm0
    vfnmsubsd xmm0, xmm0, xmm0, xmm0
_
    vinsertf128 ymm0, ymm0, xmm0, 0
    vperm2f128 ymm0, ymm0, ymm0, 0
_
    vmaskmovps ymm0, ymm0, [0]
    vmaskmovpd ymm0, ymm0, [0]
_
    vpermilpd   ymm0, ymm0, [0]
    vpermilps   ymm0, ymm0, [0]
    ; vpermil2pd   ymm0, ymm0, ymm0, ymm0, 0 ; removed
    ; vpermilmo2ps ymm0, ymm0, ymm0, ymm0
    ; vpermil2ps   ymm0, ymm0, ymm0, ymm0, 0 ; removed
_
    pclmulqdq xmm0, xmm0, 0
_
    vtestps ymm0, ymm0
    vtestpd ymm0, ymm0
_
    vfmadd132pd xmm0, xmm0, xmm0
    vfmadd213pd xmm0, xmm0, xmm0
    vfmadd231pd xmm0, xmm0, xmm0
_
    pshufb xmm0, dqword [eax]       ; 66:0F380000
    phaddw xmm0, dqword [eax]       ; 66:0F380100
    phaddd xmm0, dqword [eax]       ; 66:0F380200
    phaddsw xmm0, dqword [eax]      ; 66:0F380300
    pmaddubsw xmm0, dqword [eax]    ; 66:0F380400
    phsubw xmm0, dqword [eax]       ; 66:0F380500
    phsubd xmm0, dqword [eax]       ; 66:0F380600
    phsubsw xmm0, dqword [eax]      ; 66:0F380700
_
    pblendvb xmm0, xmm0
    blendvps xmm0, xmm0
    blendvpd xmm0, xmm0
_
    ptest xmm0, xmm0
_
    pmovsxbw xmm0, xmm0
    pmovsxbd xmm0, xmm0
    pmovsxbq xmm0, xmm0
    pmovsxwd xmm0, xmm0
    pmovsxwq xmm0, xmm0
    pmovsxdq xmm0, xmm0
_
    pmovzxbw xmm0, xmm0
    pmovzxbd xmm0, xmm0
    pmovzxbq xmm0, xmm0
    pmovzxwd xmm0, xmm0
    pmovzxwq xmm0, xmm0
    pmovzxdq xmm0, xmm0
_
    pcmpgtq  xmm0, xmm0
_
    pmulld xmm0, xmm0
    phminposuw xmm0, xmm0
_
    invept
    invvpid
_
    movbe [eax], eax
    movbe eax, [eax]
_
    psignb xmm0, xmm0
    psignw xmm0, xmm0
    psignd xmm0, xmm0
_
    pmulhrsw xmm0, xmm0
_
    pabsb xmm0, xmm0
    pabsw xmm0, xmm0
    pabsd xmm0, xmm0
_
    pmuldq xmm0, xmm0
    pcmpeqq xmm0, xmm0
    movntdqa xmm0, [eax]
    packusdw xmm0, xmm0
_
    pminsb xmm0, xmm0
    pminsd xmm0, xmm0
    pminuw xmm0, xmm0
    pminud xmm0, xmm0
_
    pmaxsb xmm0, xmm0
    pmaxsd xmm0, xmm0
    pmaxuw xmm0, xmm0
    pmaxud xmm0, xmm0
_
    pextrb eax, xmm0, 0
    pextrw eax, xmm0, 0
    pextrd eax, xmm0, 0
_
    extractps eax, xmm0, 0
_
    pinsrb xmm0, eax, 0
    insertps xmm0, xmm0, 0 ; not eax ?
    pinsrw xmm0, eax, 0
_
    dpps xmm0, xmm0, 0
    dppd xmm0, xmm0, 0
_
    mpsadbw xmm0, xmm0, 0
    pclmulqdq xmm0, xmm0, 0
_
    pcmpestrm xmm0, xmm0, 0
    pcmpestri xmm0, xmm0, 0
    pcmpistrm xmm0, xmm0, 0
    pcmpistri xmm0, xmm0, 0
_
    roundps xmm0, xmm0, 0
    roundpd xmm0, xmm0, 0
    roundss xmm0, xmm0, 0
    roundsd xmm0, xmm0, 0
_
    blendps xmm0, xmm0, 0
    blendpd xmm0, xmm0, 0
    pblendw xmm0, xmm0, 0
_
    palignr xmm0, xmm0, 0   ; 66:0F3A0FC000
    palignr mm0, mm0, 0     ; 0F3A0FC000

; Ange Albertini 2009-2010.