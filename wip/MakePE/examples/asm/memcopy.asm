; various opcodes to do copies of several dword at once
; WIP

%include '..\..\onesec.hdr'

%macro rpush 1
    push ebp
    add dword [esp], %1 - base
%endmacro

%macro copymovsd 3                          ; copies 4 * size
    mov esi, %1
    mov edi, %2
    mov ecx, %3
    rep movsd
%endmacro

%macro copyall 2                            ; copies 8 dword at 'once'
    mov [espsave], esp
    mov esp, %1
    popad
    mov esp, %2 + 8 * 4
    pushad
    mov esp, [espsave]
    push dword [%1 + 4 * 3]
    pop dword [%2 + 4 * 3]
%endmacro


%macro copyf 2                              ; ???
    mov esi, %1 - 5 * 4
    mov edi, %2
    frstor [esi]
    fsave [edi]
%endmacro

%macro copyfx 2                             ; ???
    mov esi, %1 - 5 * 4
    mov edi, %2
    fxrstor [esi]
    fxsave [edi]
%endmacro

_movsd:
    copymovsd start, buffer, 1 + ((end - start) >> 2)
    retn

_copyall:
    pushad
    copyall start, buffer
    copyall start + 8 * 4, buffer + 8 * 4
    popad
    retn
clear:
    mov eax, 0
    mov edi, buffer
    mov ecx, 100 / 4
    rep stosd
    retn

EntryPoint:
    mov edi, buffer
    call _movsd
    call clear

    call _copyall
    call clear

    copyf start, buffer
    call clear

    copyfx start, buffer
    call clear

    popad
    jmp buffer

start:
    call $+5
base:
    pop ebp

    push MB_ICONINFORMATION ; UINT uType
    push tada              ; LPCTSTR lpCaption
    push helloworld        ; LPCTSTR lpText
    push 0                  ; HWND hWnd
    call [__imp__MessageBoxA]
    push 0                  ; UINT uExitCode
    call [__imp__ExitProcess]
end:
;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess

espsave dd 0
align 16, db 0
buffer:
times 100 db 0
tada db "Tada!", 0
helloworld db "Hello World!", 0


;%IMPORTS

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE

;Ange Albertini, Creative Commons BY, 2009-2010
