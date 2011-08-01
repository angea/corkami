; registers checks on a single FPU operation
;
; a single (fldpi) FPU Load Pi modifies ST0, FST, MM7, CR0
;
; Ange Albertini, BSD Licence 2011

%include '../header.inc'

MEM_RESERVE        equ 2000h
MEM_TOP_DOWN       equ 100000h
MB_ICONINFORMATION equ 040h

EntryPoint:
    smsw ebx
    mov [cr0before], ebx
_
    mov ebx, fstbefore
    fstsw [ebx]
    mov edx, fstafter
_
    fldpi
    smsw ecx
    mov [cr0after], ecx
    fstsw [edx]
    fstp tword [st0after]
    movq qword [_mm7], mm7
_
    cmp word [fstbefore], 0
    jnz bad
    cmp word [fstafter], 03800h
    jnz bad
_
    and dword [cr0before], 0fff0ffffh
    cmp dword [cr0before],  8000003bh
    jnz bad
    and dword [cr0after], 0fff0ffffh
    cmp dword [cr0after],  80000031h
    jnz bad
_
    cmp dword [_mm7], 2168c235h
    jnz bad
    cmp dword [_mm7 + 4], 0c90fdaa2h
    jnz bad
_
    cmp dword [st0after], 02168c235h
    jnz bad
    cmp dword [st0after + 4], 0c90fdaa2h
    jnz bad
    cmp word [st0after + 8], 04000h
    jnz bad
_
    jmp good
_c

good:
    push MB_ICONINFORMATION
    push correct
    push noerrors
    push 0
    call MessageBoxA
bad:
    push 0
    call ExitProcess
_c

_mm7 dq 0
fstbefore dw 0
fstafter dw 0
cr0before dd 0
cr0after dd 0
st0after dt 0
_d

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess
_c

correct db "correct!", 0
noerrors db "No errors detected!", 0
_d

;%IMPORTS

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE
SUBSYSTEM equ 2
