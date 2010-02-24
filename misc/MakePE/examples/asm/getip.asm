; how to get EIP

%include '..\..\onesec.hdr'

EntryPoint:
    call _call
    call _int
    call _fpu
    call _seh
    jmp good

_call:
    call $ + 5
after_call:
    pop edx
    cmp edx, after_call
    jnz bad
    retn

_int:
    int 02eh    ; also works with int 2c
after_int:
    cmp edx, after_int
    jnz bad
    retn

_fpu:
    fnop
    fnstenv [fpuenv]              ; storing fpu environment
    mov edx,[fpuenv.DataPointer]  ; getting the EIP of last fpu operation
    cmp edx, _fpu
    jnz bad
    retn

fpuenv:
    .ControlWord           dd 0
    .StatusWord            dd 0
    .TagWord               dd 0
    .DataPointer           dd 0
    .InstructionPointer    dd 0
    .LastInstructionOpcode dd 0
    dd 0

%macro _before 0
    %push SEH
    setSEH %$handler
%endmacro

%macro _after 1
%$handler:
    mov eax, [esp + 0ch]
    cmp dword [eax + 0b8h], %1
    jnz bad
    mov dword [eax + 0b8h], %$next
    xor eax, eax
    retn
%$next:
    clearSEH
    %pop
%endmacro

_seh:
    _before
    xor eax, eax
on_the_instruction:
    mov [eax], eax
    jmp bad
    _after on_the_instruction
nop
    _before
    db 0f1h
trigger_after_execution:
    jmp bad
    _after trigger_after_execution
nop
    _before
    push 302h           ; TF + 10b
    popf                ; will trigger after the following instruction is executed
    jmp bad
    _after bad
    retn

%include '..\goodbad.inc'

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess

;%IMPORTS

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE

;Ange Albertini, Creative Commons BY, 2010
