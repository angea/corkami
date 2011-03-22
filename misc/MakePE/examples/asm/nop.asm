; nop has several interpretations, depending on its true use.
; the true nop, that only consumes one byte, and changes nothing but EIP in the CPU state.
; then, a nop for heap spray is just an uninmportant (it won't fail to execute) opcode that just takes one byte
; then, changing only the standard flags can be seen as a nop.
; or changing only the first entry on the stack...
; in standard forms of obfuscation, changing something then reverting the changes - and only having modified the stack or the flags
; thus by extension, a 'NOP' is one or a sequence of opcodes, that didn't change the standard registers nor the memory.

; changing and reverting the memory is typically NOT seen as a nop, as it could be intercepted by a breakpoint.

%include '..\..\onesec.hdr'

%macro rand 1
    rdtsc
    lea %1, [eax + edx * 8]
%endmacro

randomize:
    rand ebx
    rand ecx
    rand esi
    rand edi
    rand ebp
    retn

EntryPoint:
    call randomize
    pushad
_
    nop
    xchg eax, eax
    xchg al, al
    pause
_
    mov eax, eax
    and eax, eax                            ; should clear Z
    or eax, eax
    xor eax, 0
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
    prefetchnta [eax]   ; no matter the eax value
_
    ; if OF is not set, this just does a nop - a risky nop then
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
    ;int 2dh
_
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
    jmp good
_c

%include '..\goodbad.inc'
_c
;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess
_d

;%IMPORTS

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE

;Ange Albertini, BSD Licence, 2010-2011
