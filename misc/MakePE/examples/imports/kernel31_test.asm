;manually loading imports

%include '..\..\standard_hdr.asm'

%include 'entrypoint.inc'

MessageBoxA:
    jmp [iMessageBoxA]
ExitProcess:
    jmp [iExitProcess]
nop
szUser32 db 'user32.dll', 0
szMessageBoxA db 'MessageBoxA',0
szExitProcess db 'ExitProcess', 0

LoadImports:
    push kernel31.dll   ; LPCTSTR lpFileName
    call LoadLibraryA
    ; mov [hKernel32], eax
    ; push dword [hKernel32]

    push szExitProcess  ; LPCSTR lpProcName
    push eax            ; HMODULE hModule
    call GetProcAddress

    mov [iExitProcess], eax

    push szUser32       ; LPCTSTR lpFileName
    call LoadLibraryA
    ; mov [hUser32], eax
    ; push dword [hUser32]

    push szMessageBoxA  ; LPCSTR lpProcName
    push eax            ; HMODULE hModule
    ; push dword [hUser32]

    call GetProcAddress
    mov [iMessageBoxA], eax
    retn

;hKernel32 dd 0
;hUser32 dd 0


iMessageBoxA dd 0
iExitProcess dd 0
nop
;%IMPORT kernel31.dll!GetProcAddress
;%IMPORT kernel31.dll!LoadLibraryA
nop
;%IMPORTS

%include '..\..\standard_ftr.asm'

;Ange Albertini, Creative Commons BY, 2010