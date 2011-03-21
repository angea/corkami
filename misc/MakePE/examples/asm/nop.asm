%include '..\..\onesec.hdr'


EntryPoint:
    pushad
_
    nop
    xchg eax, eax
    mov eax, eax
    xchg al, al
    pause
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
    pushf
    popf
    push ds
    pop ds

_
    inc eax
    dec eax

    nop
    xchg eax, eax
    xchg al, al
_
    db 0fh, 1ch, 00                         ; nop [eax] ; doesn't trigger an exception
    db 0fh, 019h, 084h, 0c0h
        dd 080000000h                       ; hint_nop [eax + eax * 8 - 080000000h]
_

    fnop
    emms
_

    ;int 2dh
_
    ; if OF is not set, this just does a nop
    into
_
    cmp eax, [esp + 1ch]
    jnz bad
    cmp ecx, [esp + 18h]
    jnz bad
    cmp edx, [esp + 14h]
    jnz bad
    cmp ebx, [esp + 10h]
    jnz bad
;    cmp esp, [esp + 0ch]
;    jnz bad
    cmp ebp, [esp + 8]
    jnz bad
    cmp esi, [esp + 4]
    jnz bad
    cmp edi, [esp + 0]
    jnz bad
_
    popad

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
