%include '..\..\standard_hdr.asm'

SUBSYSTEM equ IMAGE_SUBSYSTEM_WINDOWS_CUI

STD_OUTPUT_HANDLE equ -11

init:
    push STD_OUTPUT_HANDLE  ; DWORD nStdHandle
    call GetStdHandle
    mov [hConsoleOutput], eax
    retn
_c

print:
    pushad
    mov edi, [esp + 24h]
    mov esi, edi
    xor al, al
    cld
    push -1
    pop ecx
    repnz scasb
    not ecx
    sub edi, ecx
    dec ecx
_
    push 0                          ; LPVOID lpReserved
    push lpNumbersOfCharsWritten    ; LPWORD lpNumbersOfCharsWritten
    push ecx                        ; DWORD nNumbersOfCharsToWrite
    push edi                        ; VOID *lpBuffer
    push dword [hConsoleOutput]     ; HANDLE hConsoleOutput
    call WriteConsoleA
    popad
    retn 4
_c

EntryPoint:
    call init
_
    push %string:"Hello world!", 0dh, 0ah, 0
    call print
_
    push 0                  ; UINT uExitCode
    call ExitProcess
_c

;%IMPORT kernel32.dll!GetStdHandle
;%IMPORT kernel32.dll!WriteConsoleA
;%IMPORT kernel32.dll!ExitProcess
_c

lpNumbersOfCharsWritten dd 0
hConsoleOutput dd 0
_d

;%strings
_d

;%IMPORTS
_d

%include '..\..\standard_ftr.asm'

; Ange Albertini, Creative Commons BY, 2009-2010