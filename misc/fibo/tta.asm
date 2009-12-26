; simple fibonacci number calculator, virtualized into a TTA machine architecture

; Transport Triggered Architecture
; a machine with only one opcode, so there are only arguments: 
; a, b: mov [a], [b]
; but the target address triggers a special behaviour, and special registers are mapped in memory
;
; conditional operations are done by setting conditional to true and 
; a guard determining if the data transport is squashed or done correctly

.386
.model flat, stdcall
option casemap :none

include c:\masm32\include\kernel32.inc
includelib c:\masm32\lib\kernel32.lib

.code smc   ;  /SECTION:smc,erw

_ADD macro a, b
    dd operand, b        ; add edx, eax
    dd add_trigger, a
    dd a, result
endm

Main proc

vm_start:
    mov [_ip], 0
nop
refresh_ip:
    mov esi, [_ip]
    lea esi, [esi + virtual_code]
nop
vm_fetch:
    mov ebx, dword ptr [esi]
    mov eax, dword ptr [esi + 4]
    add esi, 8
nop
    mov eax, dword ptr [eax]
    cmp [conditional], 0
    jz data_transport
    mov [conditional], 0
    cmp [guard], 0  ; if guard not set then data transport is squashed
    jz vm_fetch     ; data transport squashed
nop
data_transport:
    mov [ebx],eax
    cmp ebx, offset add_trigger
    jz add_triggered
    cmp ebx, offset _ip
    jz refresh_ip
    cmp ebx, offset exit
    jz exit_triggered
    jmp vm_fetch
nop
add_triggered:
    mov eax, [operand]
    mov ebx, [add_trigger]
    add ebx, eax
    mov [result], ebx
    jmp vm_fetch
nop
exit_triggered:
    mov eax, reg0
    ; jmp exit_vm
nop
exit_vm:
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
dd reg0, rom1           ; mov ecx, 046
dd reg1, rom2           ; mov eax, 0
dd reg2, rom3           ; mov ebx, 1
LOOP_ equ $ - virtual_code
dd reg3, reg2           ; mov edx, ebx
_ADD reg3, reg1         ; add edx, eax
dd reg1, reg2           ; mov eax, ebx
dd reg2, reg3           ; mov ebx, edx
_ADD reg0, rom4         ; add ecx, -1

dd guard, reg0
dd conditional, rom3    ; the guard is taken into account
dd _ip, rom5            ; jnz _loop

dd reg0, reg2           ; mov ecx, ebx
dd exit, exit           ;EXIT

virtual_memory:
registers:
    reg0 dd 0
    reg1 dd 0
    reg2 dd 0
    reg3 dd 0
    _ip dd 0
    guard dd 0          ; defines condition
    conditional dd 0    ; defines if transport is conditional or unconditional
triggers:
    operand dd 0
    add_trigger dd 0
    result dd 0
    exit dd 0
rom:
    rom1 dd 046
    rom2 dd 0
    rom3 dd 1
    rom4 dd -1
    rom5 dd LOOP_
Main Endp

End Main

; Ange Albertini, 2009
