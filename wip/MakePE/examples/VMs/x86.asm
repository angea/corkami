; simple fibonacci number calculator, virtualized into a similar architecture like x86

%include '../../onesec.hdr'

_MOV equ 0
_MOVr equ 1
_ADD equ 2
_ADDr equ 3
_JNZ equ 4
_EXIT equ 5

EntryPoint:
    mov esi, virtual_code ; esi is our virtual EIP
nop
vm_fetch:
    lodsd
    lea edi , [handlers + eax * 4]
    jmp dword [edi]
nop
MOV_handler:
    lodsd
    mov ebx, eax
    lodsd
    lea edi, [regs + ebx * 4]
    mov dword [edi], eax
    jmp vm_fetch
nop
MOVr_handler:
    lodsd
    mov ebx, eax
    lodsd
    mov eax, [regs + eax * 4]
    lea edi, [regs + ebx * 4]
    mov dword [edi], eax
    jmp vm_fetch
nop
ADD_handler:
    lodsd
    mov ebx, eax
    lodsd
    lea edi, [regs + ebx * 4]
    add dword [edi], eax
    mov eax, dword [edi]
    mov [ZF], eax
    jmp vm_fetch
nop
ADDr_handler:
    lodsd
    mov ebx, eax
    lodsd
    mov eax, [regs + eax * 4]
    lea edi, [regs + ebx * 4]
    add dword [edi], eax
    mov eax, dword [edi]
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
    mov eax, dword [regs + 0 * 4]
    jmp vm_exit
nop
vm_exit:
    cmp eax, 2971215073 ; 46th fibonacci number
    jnz bad
    jmp good

%include '..\goodbad.inc'
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

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess

;%IMPORTS

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE

; Ange Albertini, Creative Commons BY, 2009-2010
