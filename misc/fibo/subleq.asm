; simple fibonacci number calculator, virtualized into a SUBLEQ machine architecture

; SUBLEQ substract branch if lower or equal
; a machine with only one opcode, so there are only arguments:
; a, b, c:
;   [b] = [b] - [a]
;   if [b] < 0 : goto [c]
; if c is omitted (0xFFFFFFFF here), c is set as next position, thus no jump.
; Z is an address expected NULL at Zero at the start of each instruction block

; NOTE: Target operand = 2nd.

.386
.model flat, stdcall
option casemap :none

include c:\masm32\include\kernel32.inc
includelib c:\masm32\lib\kernel32.lib

_NB EQU -1

.code smc   ;  /SECTION:smc,erw

Main proc

_CLR macro a
    dd a, a, _NB
endm

_CLZ macro
    dd Z, Z, _NB
endm

_JMP macro label    ; clears Z too
    dd Z, Z, label
endm

_ADD macro a, b
    dd a, Z, _NB
    dd Z, b, _NB
    _CLZ
endm

_MOV macro a, b
    _CLR b
    _ADD a, b
endm

_JNZ macro b, label
    local _PZ, _Z   ; Positive or Zero, Zero
    dd b, Z, _PZ    ; branch if b >= 0
    _JMP label
_PZ:
    _CLZ
    dd Z, b, _Z     ; branch if b <= 0 => with previous if b = 0
    _JMP label
_Z:
endm

vm_start:
    mov esi, virtual_code ; esi is our virtual EIP
nop
vm_fetch:
    cmp esi, offset _end
    jz vm_end
nop
    lodsd
    mov ebx, eax
    mov ebx, dword ptr [ebx]
    lodsd
    mov ecx, eax
    sub [ecx],ebx
nop
    lodsd
    cmp eax, _NB
    jz vm_fetch
nop
    cmp dword ptr [ecx], 0
    jg vm_fetch
    mov esi, eax ;lea esi, [virtual_code + eax]
    jmp vm_fetch
nop
vm_end:
    mov eax, reg0
    cmp eax, 2971215073 ; 46th fibonacci number
    jnz bad
nop
good:
    push 0
    Call ExitProcess
nop
bad:
    push 42
    Call ExitProcess

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
nop
align 4
virtual_memory:
registers:
    Z dd 0
    reg0 dd 0
    reg1 dd 0
    reg2 dd 0
    reg3 dd 0
rom:
    rom1 dd 046
    rom2 dd 1
    rom3 dd -1

Main Endp

End Main

; Ange Albertini, 2009
