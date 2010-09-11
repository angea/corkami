; simple fibonacci number calculator, virtualized into a bit-level virtual machine

%include '../../onesec.hdr'

; args = ecx, ebx, eax
_READ equ 0 ; mov flag[ecx], [ebx:[b.eax]
_WRITE equ 1 ; mov [ecx]:ebx, flag[eax]
_NAND equ 2; and flag[ecx], flag[ebx]

_DUMMY equ 31415926

%macro _MOV 4 ; mov [1:b.2], [3:b.4]
    dd _READ, 0, %3, %4
    dd _WRITE, %1, %2, 0
%endmacro

%macro _NOT 1
    dd _NAND, %1, %1, _DUMMY
%endmacro

%macro _MOVBYTE 2
%assign i 0
%rep    8
    _MOV %1, i, %2, i
%assign i i+1
%endrep

%endmacro

; a nand a <=> not a
; a nand not a <=> t
; f <=> not t
; a or b <=> (not a) nand (not b) <=> (a nand a) nand (b nand b)
; a and b <=> not (a nand b) <=> (a nand b) nand (a nand b)
; a xor b <=> (a or b) and (a nand b) <=> (a nand (not b)) nand ((not a) nand b) <=> (a nand (b nand b)) nand ((a nand a) nand b)

; a nor b <=> not (a or b) <=> ((a nand a) nand (b nand b)) nand ((a nand a) nand (b nand b))
; a == b <=> not (a xor b) <=> (a nand b) nand (a or b) <=> (a nand b) nand ((a nand a) nand (b nand b))

; add a, b, carry <=> carry = a and b / a = a xor b


EntryPoint:
    mov esi, virtual_code ; esi is our virtual EIP
nop
vm_fetch:   ; <opcode:edi> <arg0:ecx> <arg1:ebx> <arg2:eax>
    cmp esi, vm_end
    jz vm_exit

    lodsd
    lea edi , [handlers + eax * 4]

    lodsd
    mov ecx, eax

    lodsd
    mov ebx, eax

    lodsd

    jmp dword [edi]
nop

READ_handler:
    bt [ebx], eax
    jnb read_reset

    bts [flags], ecx
    jmp vm_fetch
read_reset:
    btr [flags], ecx
    jmp vm_fetch


WRITE_handler:
    bt [flags], eax
    jnb short write_reset

    bts [ecx], ebx
    jmp vm_fetch
write_reset:
    btr [ecx], ebx
    jmp vm_fetch


NAND_handler:
    bt [flags], ebx
    setb bl
    bt [flags], ecx
    setb al
    and al, bl
    jz and_reset

    bts [flags], ecx
    jmp vm_fetch

and_reset:
    btr [flags], ecx
    jmp vm_fetch

nop
vm_exit:
    cmp byte [target], 42h; 46th fibonacci number
    jnz bad
    jmp good

%include '..\goodbad.inc'
handlers dd READ_handler, WRITE_handler, NAND_handler

source dd 42h
target dd 0
virtual_code:
    _MOVBYTE target, source
;dd _MOV, 0, 046         ; mov ecx, 046
;dd _MOV, 1, 0           ; mov eax, 0
;dd _MOV, 2, 1           ; mov ebx, 1
;LOOP_ equ $ - virtual_code
;dd _MOVr, 3, 2          ; mov edx, ebx ; _loop
;dd _ADDr, 3, 1          ; add edx, eax
;dd _MOVr, 1, 2          ; mov eax, ebx
;dd _MOVr, 2, 3          ; mov ebx, edx
;dd _ADD, 0, -1          ; add ecx, -1
;dd _JNZ, LOOP_          ; jnz 024h
;dd _MOVr, 0, 2          ; mov ecx, ebx
;dd _EXIT                ; (exit)
vm_end:

regs dd 0, 0, 0, 0
flags dd 0

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess

;%IMPORTS

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE

; Ange Albertini, Creative Commons BY, 2009-2010
