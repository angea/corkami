; small segment checker for experimentation (fails)

%include '..\..\onesec.hdr'

%macro print_ 1
    push ds

    push ss
    pop ds

    inc dword [ss:counter]

    push MB_ICONINFORMATION ; UINT uType
    push %string:"message", 0 ; LPCTSTR lpCaption
    push %1
    push 0                  ; HWND hWnd
    call MessageBoxA

    pop ds
    _
%endmacro

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
    push fs
    pop dword [FS_]
    push ds
    pop dword [DS_]

    push fs
    pop ds
_
;    gsloop
;_
    push ds
    pop eax
    cmp ax, word [ss:FS_]
    jz ds_ok1
_
    print_ %string:"DS doesn't have FS value", 0
ds_ok1:
    setSEH handler
    int3
_c

handler:
    push ds
    pop eax
    cmp ax, word [ss:DS_]
    jz ds_ok2
_
    print_ %string:"DS should have the original DS value in the SEH handler, but didn't", 0
ds_ok2:

    mov eax, [esp + exceptionHandler.pContext + 4]
    mov dword [ss:eax + CONTEXT.regEip], returnfromSEH
    mov eax, ExceptionContinueExecution
    retn

returnfromSEH:
    push ds
    pop eax
    cmp ax, word [ss:DS_]
    jz ds_ok3
_
    print_ %string:"DS should be restored to its initial value, but wasn't", 0

ds_ok3:
    cmp dword [ss:counter], 0
    jnz end_
    print_ %string:"no error detected", 0
end_:
    push 0                  ; UINT uExitCode
    call ExitProcess


;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess

_d

DS_ dd 0
FS_ dd 0

counter dd 0

;%IMPORTS
;%strings


SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE


;Ange Albertini, Creative Commons BY, 2009-2010
