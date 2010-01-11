; concept file where all procedures are supposed to be executed at the same memory address,
; thus making it 'undumpable' by standard terms,
; as representation of disassembly doesn't allow different codes at same address

; original idea by Piotr Krysiuk

; compile with makepe

%include '../onesec.hdr'

%macro callr 2
    db 0e8h,
    dd %1  +  (%2 - Buffer) - ($ + 4)
%endmacro

EntryPoint:
    call _proc1
    call _proc2

Buffer:
    times 20h db 0

_proc1
    pushad
    mov esi, proc1
    jmp next

_proc2:
    pushad
    mov esi, proc2
    jmp next

next:
    mov edi, Buffer
    mov al, 0
    mov ecx, 20h
    rep stosb
    mov ecx, 20h
    mov edi, Buffer
    rep movsb
    popad
    jmp Buffer

proc1:
MB_ICONINFORMATION equ 040h
    push MB_ICONINFORMATION ; UINT uType
    push tada               ; LPCTSTR lpCaption
    push helloworld         ; LPCTSTR lpText
    push 0                  ; HWND hWnd
    callr MessageBoxA, proc1
    retn
PROC1LEN equ $ - proc1

proc2:
    push 0                  ; UINT uExitCode
    callr ExitProcess, proc2
PROC2LEN equ $ - proc2

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess

tada db "Tada!", 0
helloworld db "Hello World!", 0

;%IMPORTS

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE

;Ange Albertini 2010
