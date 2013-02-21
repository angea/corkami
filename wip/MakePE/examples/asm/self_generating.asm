; a self-generating polymorphic program works a bit like a VM.
; one part of the code will randomly generate the code defined in the virtual opcode.
; in this minimal example, each handler or junk generator just has 2 choices:
; a 'clean' code generator, and an obfuscated one.

; compile with makepe

%include '../../onesec.hdr'

%macro random 2
    xor eax, eax
    rdtsc
    mul eax
    cmp eax, 080000000h
    js %1
    jmp %2
%endmacro

EntryPoint:
    call generation
    nop                         ; spaceholder for software breakpoint on return
generated_start:
    times 0100h db 0

tada db "Tada!", 0
helloworld db "Hello World!", 0

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess

;%IMPORTS

generation:
    mov esi, virtual_start
    mov edi, generated_start
fetch:
    cmp esi, virtual_end        ; did we reach the end of our virtual code?
    jge cleanup                 ; we can clean up our engine and execute our generated code
    call makesomejunk
    xor eax, eax
    lodsb
    lea ebx , [handlers + eax * 4]
    jmp [ebx]

push_handler:
    random push0, push1

push0:
    ; 68 xxxxxxxx push <dword>

    mov al, 068h
    stosb

    lodsd
    stosd

    jmp fetch
push1:
    ; b93d xxxxxxxx mov ecx, <dword> ^ <random> ; simplest obfuscation
    ; 81f1 xxxxxxxx xor ecx, <random>
    ; 51 push ecx
    rdtsc           ; let's get a random value
    add ecx, eax

    mov al, 0b9h
    stosb

    lodsd
    xor eax, ecx
    stosd

    mov ax, 0f181h
    stosw
    mov eax, ecx
    stosd

    mov al, 051h
    stosb
    jmp fetch

call_handler:
    random call0, call1

call0:
    ; e8 xxxxxxxx CALL <relative address>
    mov al, 0e8h  ; mov ecx, immDW
    stosb

    lodsd
    sub eax, edi
    sub eax,  5 - 1     ; 5 for the instruction size, 1 because esi already incremented
    stosd
    jmp fetch

call1:
    ;00: 68 xxxxxxxx push $ + 10
    ;05: 68 xxxxxxxx push <absolute_address>
    ;0a: e8 00000000 call $+5
    ;0f: c3 retn
    ;10: ...

    mov al, 068h
    stosb

    mov eax, edi
    add eax, 010h - 1   ; esi already incremented
    stosd

    mov al, 68h
    stosb

    lodsd
    stosd

    mov al, 0e8h
    stosb

    xor eax, eax
    stosd

    mov al, 0c3h
    stosb
    jmp fetch

makesomejunk: ; generates some junk at edi
    random junk0, junk1
junk0:
            ; no junk
    retn
junk1:
    mov al, 090h
    stosb
    retn

handlers dd push_handler, call_handler

push_ equ 0
call_ equ 1

virtual_start:
    db push_
        dd MB_ICONINFORMATION
    db push_
        dd tada
    db push_
        dd helloworld
    db push_
        dd 0
    db call_
        dd MessageBoxA
    db push_
        dd 0
    db call_
        dd ExitProcess
virtual_end:
    ; if you add cleanup before generated code is executed
    ; there is no constant code of the original program to be found
cleanup:
    xor eax, eax
    mov edi, generation
    mov ecx, after_cleanup - generation
after_cleanup:
    rep stosb
    retn

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE

;Ange Albertini, Creative Commons BY, 2009-2010