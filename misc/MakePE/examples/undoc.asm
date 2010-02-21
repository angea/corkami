; undocumented opcodes and undocumented opcodes behavior

%include '../onesec.hdr'

%define _ align 16, db 90h

SINGLE_STEP equ 80000004h
ACCESS_VIOLATION equ 0c0000005h
%define PREFIX_FS db 64h
%define PREFIX_OPERANDSIZE db 66h
%define PREFIX_ADDRESSSIZE db 67h

%macro SEH_before 0
    %push SEH
    push  %$handler
    push dword [fs:0]
    mov [fs:0], esp
%endmacro

%macro SEH_after 1
%$after:
    jmp %$next
%$handler:
    mov edx, [esp + 4]
    cmp dword [edx], %1
    jnz bad
    mov eax, [esp + 0ch]
    mov dword [eax + 0b8h], %$after
    xor eax, eax
    retn
%$next:
    pop dword [fs:0]
    add esp, 4
    %pop
%endmacro

EntryPoint:

    mov eax, 0ffffffffh

;   clc                                     ; carry flag is cleared on startup
    salc                                    ; setalc => will clear AL
    cmp al, 0
    jnz bad

;   stc
;   salc
;   cmp al, 0ffh
;   jnz bad
_
;    mov eax, 12345678h
;    bswap eax
;    cmp eax, 78563412h
;    jnz bad

    mov eax, 12345678h
    PREFIX_OPERANDSIZE
    bswap eax                               ; bswap ax = xor ax, ax
    cmp eax, 12340000h
    jnz bad
_
    mov ax, 0325h
    aad 7                                   ; ah = 0, al = ah * 7 + al => al = 3Ah
    cmp ax, 003Ah
    jnz bad

    aam 3                                   ; ah = al / 3, al = al % 3 => ah = 13h, al = 1
    cmp ax, 1301h
    jnz bad

    smsw eax
    cmp eax, 08001003bh
    jnz bad

    ; FPU JUNK - just ignored here
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
    mov eax, _eax

    db 0f7h, 08h                            ; test dword [eax], 012345678h
        dd 012345678h
_
    jnp bad

    db 0c1h, 30h, 8                         ; sal [ebx], 8
_
    cmp dword [eax], 34567800h
    jnz bad

    mov eax, 0
    db 0fh, 1fh, 00                         ; nop [eax] ; doesn't trigger an exception
    db 0fh, 019h, 084h, 0c0h
        dd 080000000h                       ; hint_nop [eax + eax * 8 - 080000000h]

    SEH_before
    db 0f1h                                 ;ICEBP
    SEH_after SINGLE_STEP

    SEH_before

    push EntryPoint                         ; pretending to be a standard push/ret
    PREFIX_OPERANDSIZE
        retn

    SEH_after ACCESS_VIOLATION
    add esp, 2                              ; cleaning the extra word
_
    mov ebx, [fs:0]
    mov esi, 0
    mov edi, buffer
    PREFIX_FS
        movsd                               ; movsd from FS to DS
    cmp ebx, dword [buffer]
    jnz bad
_
    mov ecx, 0ffff0001h
    PREFIX_ADDRESSSIZE
        loop bad                            ; will check cx, thus not jump
    loop take_it                            ; will check ECX, thus jump
    jmp bad
take_it:
_
    jmp good

%include 'goodbad.inc'

_eax dd 12345678h
buffer dd 0

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess

;%IMPORTS

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE

; Ange Albertini, Creative Commons BY, 2010