; simple fibonacci number calculator, virtualized into a stack machine architecture

%include '../../onesec.hdr'

_PUSH equ 0
_PUSHr equ 1
_ADD equ 2
_POPr equ 3
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
    mov eax, dword [regs]
    jmp vm_exit
nop
vm_exit:
    cmp eax, 2971215073 ; 46th fibonacci number
    jnz bad
    jmp good

%include '..\goodbad.inc'

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
dd _PUSHr, 2    ; mov edx, ebx
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

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess

;%IMPORTS

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE

; Ange Albertini, Creative Commons BY, 2009-2010
