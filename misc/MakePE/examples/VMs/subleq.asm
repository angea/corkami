; simple fibonacci number calculator, virtualized into a SUBLEQ machine architecture

; SUBLEQ substract branch if lower or equal
; a machine with only one opcode, so there are only arguments:
; a, b, c:
;   [b] = [b] - [a]
;   if [b] < 0 : goto [c]
; if c is omitted (0xFFFFFFFF here), c is set as next position, thus no jump.
; Z is an address expected NULL at Zero at the start of each instruction block

; NOTE: Target operand = 2nd.

%include '../../onesec.hdr'

; standard opcode
%macro _OP 3
    dd %1 - virtual_code, %2 - virtual_code, %3 - virtual_code
%endmacro

; opcode with no branch => c = @next_line
%macro _NB 2
    dd %1 - virtual_code, %2 - virtual_code, %%1 - virtual_code
%%1:
%endmacro

%macro _CLR 1
    _NB %1, %1
%endmacro

%macro _CLZ 0
    _NB Z, Z
%endmacro

%macro _JMP 1  ; clears Z too
    _OP Z, Z, %1
%endmacro

%macro _ADD 2
    _NB %1, Z
    _NB Z, %2
    _CLZ
%endmacro

%macro _MOV 2
    _CLR %2
    _ADD %1, %2
%endmacro

%macro _JNZ 2
    _OP %1, Z, %%PZ     ; branch if b >= 0
    _JMP %2
%%PZ:                   ; positive or zero
    _CLZ
    _OP Z, %1, %%Z      ; branch if b <= 0 => with previous if b = 0
    _JMP %2
%%Z:                    ; zero
%endmacro

EntryPoint:
    mov esi, virtual_code
nop
vm_fetch:
    cmp esi, _end
    jz vm_end
nop
    mov eax, dword [esi + 0 * 4]
    mov ebx, dword [esi + 1 * 4]
    mov ecx, dword [esi + 2 * 4]
    add esi, 3 * 4

    mov eax, dword [eax + virtual_code]
    sub [ebx + virtual_code],eax
    cmp dword [ebx + virtual_code], 0
    jg vm_fetch
    lea esi, [ecx + virtual_code]
    jmp vm_fetch
nop
vm_end:
    mov eax, [reg0]
    cmp eax, 2971215073 ; 46th fibonacci number
    jnz bad
    jmp good

%include '..\goodbad.inc'

align 4
virtual_code:
_MOV rom1, reg0     ; mov ecx, 046
_MOV Z, reg1        ; mov eax, 0
_MOV rom2, reg2     ; mov ebx, 1
LOOP_ equ $
_MOV reg2, reg3     ; mov edx, ebx
_ADD reg1, reg3     ; add edx, eax
_MOV reg2, reg1     ; mov eax, ebx
_MOV reg3, reg2     ; mov ebx, edx

_ADD rom3, reg0     ; add ecx, -1
_JNZ reg0, LOOP_    ; jnz _loop
_MOV reg2, reg0     ; mov ecx, ebx
_end:
dd 0
align 4
virtual_memory:
registers:
    Z dd 0
    reg0 dd 0
    reg1 dd 0
    reg2 dd 0
    reg3 dd 0
dd 0
align 4
rom:
    rom1 dd 046
    rom2 dd 1
    rom3 dd -1

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess

;%IMPORTS

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE

; Ange Albertini, Creative Commons BY, 2009-2010