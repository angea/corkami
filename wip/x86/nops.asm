; a 'NOP' tester - testing instructions not affecting general registers

; Ange Albertini, BSD Licence 2013

%include 'common.inc'

_header
    _dprint HdrMsg

    call randreg
    pushad

    nop
    xchg eax, eax
    xchg al, al
;    print_ %string:"Testing[nop]: PAUSE (spin loop hint)", 0dh, 0
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

;    push eax
;    mov eax, _eax
;;    xor eax, eax
;
;;    print_ %string:"Testing[nop]: ADD [eax], al with eax = 0", 0dh, 0
;
;;    mov dword [_eax], _eax + 4
;    add [eax], al
;
;;    print_ %string:"Testing[nop]: LOCK + operators on [0]", 0dh, 0
;    lock adc [eax], eax
;    lock add [eax], eax
;    lock and [eax], eax
;    lock or [eax], eax
;    lock sbb [eax], eax
;    lock sub [eax], eax
;    lock xor [eax], eax
;_
;    lock dec dword [eax]
;    lock inc dword [eax]
;    lock neg dword [eax]
;    lock not dword [eax]
;    add dword [eax], 2
;_
;;    print_ %string:"Testing[nop]: LOCK + CMPXCHG*", 0dh, 0
;;    lock cmpxchg [eax], eax
;    push edx
;;    lock cmpxchg8b [eax]
;    pop edx
;_
;;    print_ %string:"Testing[nop]: LOCK + BT*", 0dh, 0
;    mov dword [_eax], _eax + 4
;    ; lock bt [eax], eax                    ; this one is not valid, and will trigger an exception
;    lock btc [eax], eax
;    lock btr [eax], eax
;    lock bts [eax], eax
;_
;;    print_ %string:"Testing[nop]: superfluous LOCK + atomic eXchanges*", 0dh, 0
;    lock xadd [eax], eax                    ; atomic, superfluous prefix, but no exception
;    lock xchg [eax], eax                    ; atomic, superfluous prefix, but no exception
;
;    mov dword [0], 0
;    pop eax
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
    _dprint into_msg
    into
_
;    print_ %string:"Testing[NOP]: multibyte nop on memory", 0dh, 0
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
_
    add eax, 31415926h
    sub eax, 31415926h
_
    lea eax, [eax + 31415926h]
    sub eax, 31415926h
_
    rol eax, 15
    ror eax, ((15 * 32) & 0ffh) + 15
_
    shl eax, (29 * 32) & 0ffh
_
    fnop
    emms


    _dprint undocFPU

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

    cmp eax, [esp + 1ch]
    jnz error_
    cmp ecx, [esp + 18h]
    jnz error_
    cmp edx, [esp + 14h]
    jnz error_
    cmp ebx, [esp + 10h]
    jnz error_
    cmp ebp, [esp + 8]
    jnz error_
    cmp esi, [esp + 4]
    jnz error_
    cmp edi, [esp + 0]
    jnz error_

    _dprint result
    _dprint success
    _exit 0
error_:
    _print errormsg
    _exit 42
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

_retn4:
    retn 4
_c

_eax dd 0, 0

_dstring HdrMsg, "TEST start : instructions doing nothing on standard registers", 0ah
_dstring into_msg, "  - INTO with OF not set", 0ah
_dstring undocFPU, "  - undocumented FPU", 0ah

_dstring success, "success!", 0ah

_dstring result, "TEST result:"

_string  errormsg, "error!", 0ah
_d

_footer
