; tricks based on GS thread switch

%include '../onesec.hdr'

%macro mov_gs 1
    mov ax, %1
    mov gs, ax
%endmacro

%macro cmp_gs 1
    mov ax, gs
    cmp ax, %1
%endmacro

%macro gsloop 0
    mov_gs 3
%%_not:
    cmp_gs 3
    jz %%_not
%endmacro

EntryPoint:
    ; anti stepping
    mov_gs 3
    cmp_gs 3
    jnz bad     ; gs should still be 3

    ; behavior-based anti-emulator
    gsloop      ; infinite loop if gs is not eventually reset

    ; timing based anti-emulator
;gsloop ; not needed, since we just switched in, because gs is 0
    rdtsc
    mov ebx, eax
gsloop
    rdtsc
    sub eax, ebx
    cmp eax, 1000h     ; 2 consecutives rdtsc take less than 70 ticks, we expect a much bigger value here.
    jae good
    jmp bad

%include 'goodbad.inc'

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess

;%IMPORTS
align FILEALIGN,db 0
SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE

;Ange Albertini, Creative Commons BY, 2009-2010
