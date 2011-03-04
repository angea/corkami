; how to get EIP:
; * Call/pop
; * FPU
; * Int 2e
; * Exceptions:
;   * before the instruction
;   * on the instruction
;   * on the next instruction

; the Int2e trick is disabled under Win7

%include '..\..\onesec.hdr'

%macro _ 0
    nop
%endmacro

%macro _c 0
    align 16, int3
%endmacro

%macro _d 0
    align 16, db 0
%endmacro

_callpop:
    call $ + 5
after_call:
    pop edx
    cmp edx, after_call
    jnz bad
    retn
_c

_int:
    int 02eh    ; also works with int 2c
after_int:
    cmp edx, after_int
    jnz bad
    retn
_c

_fpu:
    fnop
    fnstenv [fpuenv]              ; storing fpu environment
    mov edx,[fpuenv.DataPointer]  ; getting the EIP of last fpu operation
    cmp edx, _fpu
    jnz bad
    retn
_c

%macro _before 0
    %push SEH
    setSEH %$handler
%endmacro

%macro _after 1
_c
%$handler:
    mov eax, [esp + exceptionHandler.pContext + 4]
    cmp dword [eax + CONTEXT.regEip], %1
    jnz bad
    mov dword [eax + CONTEXT.regEip], %$next

    mov eax, ExceptionContinueExecution
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
_
    _before
    db 0f1h
trigger_after_execution:
    jmp bad
    _after trigger_after_execution
_
    _before
    push 302h           ; TF + 10b
    popf                ; will trigger after the following instruction is executed
    jmp bad
    _after bad
    retn
_c

TLS:
    ; a TLS to patch out the Int2E trick, not Win7 compatible
    pushad
    mov eax, [fs:18h]
    mov ecx, [eax + 030h]
    xor eax, eax
    or eax, [ecx + 0a8h]
    shl eax,8
    or eax, [ecx + 0a4h]
    cmp eax, 0106h               ; Win7 ? probably need to tune that version check
    jz W7
_
    popad
    retn
_
W7:
    mov byte [disable_me], 090h
    mov dword [disable_me + 1], 090909090h
    popad
    retn
_c

EntryPoint:
    call _callpop

disable_me:
    call _int
    call _fpu
    call _seh
    jmp good
_c

%include '..\goodbad.inc'
_c
;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess

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

Image_Tls_Directory32:
    StartAddressOfRawData dd Characteristics
    EndAddressOfRawData   dd Characteristics
    AddressOfIndex        dd Characteristics
    AddressOfCallBacks    dd SizeOfZeroFill
;Callbacks: ; embedded structure
    SizeOfZeroFill        dd TLS
    Characteristics       dd 0
_d

;%IMPORTS

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE

;Ange Albertini, BSD Licence, 2010-2011
