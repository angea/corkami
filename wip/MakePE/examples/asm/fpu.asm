; simple fibonacci number calculator, only in FPU
; Ange Albertini, BSD Licence, 2009-2012

%include '../../onesec.hdr'

%macro push_ 1
        fild dword [esp_]       ; sub esp, 4
        fild dword [_4]
        fsubp st1
        fistp dword [esp_]

        push dword [esp_]       ; mov [esp], %1
        pop esp
        mov dword [esp], %1
%endmacro

%macro call_ 1
        push_ %%next
        push_ %1
        ret
        %%next:
%endmacro

EntryPoint:
    mov [esp_], esp
    finit
    fild dword [_46]
    fldz
    fld1

_loop:
    fxch st1
    fadd st0, st1

    fld1
    fsubp st3

    fldz
    fcomip st3
    
    jnz _loop

_exit:
    fild qword [true]
    fcomip st1
    jnz bad

    jmp good
_c

bad:
    push_ MB_ICONERROR   ; UINT uType
    push_ error          ; LPCTSTR lpCaption
    push_ errormsg       ; LPCTSTR lpText
    push_ 0              ; HWND hWnd
    call_ MessageBoxA
    push_ 042h
    call_ ExitProcess    ; UINT uExitCode
_c

good:
    push_ MB_ICONINFORMATION ; UINT uType
    push_ success            ; LPCTSTR lpCaption
    push_ successmsg         ; LPCTSTR lpText
    push_ 0                  ; HWND hWnd
    call_ MessageBoxA
    push_ 0
    call_ ExitProcess        ; UINT uExitCode
_c

error db "Bad", 0
errormsg db "Something went wrong...", 0
success db "Good", 0
successmsg db "Expected behaviour occured...", 0
_d

res dt 0
_46 dd 46
_4 dd 4
esp_ dd 0
true dq 2971215073
_d

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess

;%IMPORTS

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE
