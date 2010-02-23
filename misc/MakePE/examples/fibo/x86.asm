; simple fibonacci number calculator, virtualized into a similar architecture like x86

.386
.model flat, stdcall
option casemap :none

include c:\masm32\include\kernel32.inc
includelib c:\masm32\lib\kernel32.lib

_MOV equ 0
_MOVr equ 1
_ADD equ 2
_ADDr equ 3
_JNZ equ 4
_EXIT equ 5

.code smc   ;  /SECTION:smc,erw

Main proc

vm_start:
    mov esi, virtual_code ; esi is our virtual EIP
nop
vm_fetch:
    lodsd
    lea edi , [handlers + eax * 4]
    jmp dword ptr [edi]
nop
MOV_handler:
    lodsd
    mov ebx, eax
    lodsd
    lea edi, [regs + ebx * 4]
    mov dword ptr [edi], eax
    jmp vm_fetch
nop
MOVr_handler:
    lodsd
    mov ebx, eax
    lodsd
    mov eax, [regs + eax * 4]
    lea edi, [regs + ebx * 4]
    mov dword ptr [edi], eax
    jmp vm_fetch
nop
ADD_handler:
    lodsd
    mov ebx, eax
    lodsd
    lea edi, [regs + ebx * 4]
    add dword ptr [edi], eax
    mov eax, dword ptr [edi]
    mov [ZF], eax
    jmp vm_fetch
nop
ADDr_handler:
    lodsd
    mov ebx, eax
    lodsd
    mov eax, [regs + eax * 4]
    lea edi, [regs + ebx * 4]
    add dword ptr [edi], eax
    mov eax, dword ptr [edi]
    mov [ZF], eax
    jmp vm_fetch
nop
JNZ_handler:
    lodsd
    mov ebx, eax
    mov eax, [ZF]
    cmp eax, 0
    jz vm_fetch
    lea ebx, [virtual_code + ebx]
    mov esi, ebx
    jmp vm_fetch
nop
EXIT_handler:
    mov eax, dword ptr [regs + 0 * 4]
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

handlers dd MOV_handler, MOVr_handler, ADD_handler, ADDr_handler, JNZ_handler, EXIT_handler

virtual_code:
dd _MOV, 0, 046         ; mov ecx, 046
dd _MOV, 1, 0           ; mov eax, 0
dd _MOV, 2, 1           ; mov ebx, 1
LOOP_ equ $ - virtual_code
dd _MOVr, 3, 2          ; mov edx, ebx ; _loop
dd _ADDr, 3, 1          ; add edx, eax
dd _MOVr, 1, 2          ; mov eax, ebx
dd _MOVr, 2, 3          ; mov ebx, edx
dd _ADD, 0, -1          ; add ecx, -1
dd _JNZ, LOOP_          ; jnz 024h
dd _MOVr, 0, 2          ; mov ecx, ebx
dd _EXIT                ; (exit)

regs dd 0, 0, 0, 0
ZF dd 0

Main Endp

End Main

; Ange Albertini, 2009
