%include '../header.inc'

MEM_RESERVE        equ 2000h
MEM_TOP_DOWN       equ 100000h
MB_ICONINFORMATION equ 040h

EntryPoint:
    mov eax, res
    fldpi
    movq qword [eax], mm7
    cmp dword [eax], 2168c235h
    jnz bad
    cmp dword [eax+4], 0c90fdaa2h
    jnz bad
    ; not testing FST nor cr0 yet ;)
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
res dq 0

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
