;small file using En/DecodePointer
;this file would not work under XP SP2 or lower, as En/DecodePointer was added in XP SP3

; patching the import to use kernel31.dll as trampoline will enable it under an older OS.

%include '..\..\standard_hdr.asm'

%include 'entrypoint.inc'

MessageBoxA:
    push dword [iMessageBoxA]
    call DecodePointer
    jmp eax

ExitProcess:
    push dword [iExitProcess]
    call DecodePointer
    jmp eax
nop
szUser32 db 'user32.dll', 0
szMessageBoxA db 'MessageBoxA',0
szExitProcess db 'ExitProcess', 0

LoadImports:
    push kernel32.dll   ; LPCTSTR lpFileName
    call LoadLibraryA
    ; mov [hKernel32], eax
    ; push dword [hKernel32]

    push szExitProcess  ; LPCSTR lpProcName
    push eax            ; HMODULE hModule
    call GetProcAddress

    push eax
    call EncodePointer

    mov [iExitProcess], eax

    push szUser32       ; LPCTSTR lpFileName
    call LoadLibraryA
    ; mov [hUser32], eax
    ; push dword [hUser32]

    push szMessageBoxA  ; LPCSTR lpProcName
    push eax            ; HMODULE hModule
    ; push dword [hUser32]

    call GetProcAddress

    push eax
    call EncodePointer
    mov [iMessageBoxA], eax
    retn

;hKernel32 dd 0
;hUser32 dd 0


iMessageBoxA dd 0
iExitProcess dd 0
nop
;%IMPORT kernel32.dll!GetProcAddress
;%IMPORT kernel32.dll!LoadLibraryA
;%IMPORT kernel32.dll!EncodePointer
;%IMPORT kernel32.dll!DecodePointer
nop
;%IMPORTS

%include '..\..\standard_ftr.asm'

;Ange Albertini, Creative Commons BY, 2010