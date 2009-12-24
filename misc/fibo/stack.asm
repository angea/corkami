; simple fibonacci number calculator, virtualized into a stack machine architecture

.386
.model flat, stdcall
option casemap :none

include c:\masm32\include\kernel32.inc
includelib c:\masm32\lib\kernel32.lib

_PUSH equ 0
_PUSHr equ 1
_ADD equ 2
_POPr equ 3
_JNZ equ 4
_EXIT equ 5

DUMMY equ 0

.code smc ; /SECTION:smc,erw

Main proc

vm_start:
    mov esi, virtual_code ; esi is our virtual EIP
nop
vm_fetch:
    lodsd
    lea edi , [handlers + eax * 4]
    jmp dword ptr [edi]
nop
PUSH_handler:
    lodsd
    push eax
    jmp vm_fetch
nop
PUSHr_handler:
    lodsd
    mov eax, [regs + eax * 4]
    push eax
    jmp vm_fetch
nop
ADD_handler:
    pop eax
    pop ebx
    add ebx, eax
    push ebx
    mov [ZF], ebx
    jmp vm_fetch
nop
POPr_handler:
    lodsd
    pop ebx
    mov [regs + eax * 4], ebx
    jmp vm_fetch
nop
JNZ_handler:
    lodsd
    mov ebx, [ZF]
    cmp ebx, 0
    jz vm_fetch
    lea eax, [virtual_code + eax]
    mov esi, eax
    jmp vm_fetch
nop
EXIT_handler:
    mov eax, dword ptr [regs]
    jmp vm_exit
nop
vm_exit:
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
handlers dd PUSH_handler, PUSHr_handler, ADD_handler, POPr_handler, JNZ_handler, EXIT_handler

virtual_code:
dd _PUSH, 046   ; mov ecx, 046
dd _POPr, 0

dd _PUSH, 0     ; mov eax, 0
dd _POPr, 1

dd _PUSH, 1     ; mov ebx, 1
dd _POPr, 2
LOOP_ equ $ - virtual_code
dd _PUSHr, 2    ; mov edx, ebx ; _loop, 30
dd _POPr, 3

dd _PUSHr, 1    ; add edx, eax
dd _PUSHr, 3
dd _ADD
dd _POPr, 3

dd _PUSHr, 2    ; mov eax, ebx
dd _POPr, 1

dd _PUSHr, 3    ; mov ebx, edx
dd _POPr, 2

dd _PUSH, -1    ; add ecx, -1
dd _PUSHr, 0
dd _ADD
dd _POPr, 0

dd _JNZ, LOOP_  ; jnz LOOP_

dd _PUSHr, 2    ; mov ecx, ebx
dd _POPr, 0

dd _EXIT        ; (exit)

regs dd 0, 0, 0, 0
ZF dd 0

Main Endp

End Main

; Ange Albertini, 2009
