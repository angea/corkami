%include '../standard_hdr.asm'

SUBSYSTEM equ IMAGE_SUBSYSTEM_WINDOWS_CUI

STD_OUTPUT_HANDLE equ -11

EntryPoint:
    push STD_OUTPUT_HANDLE  ; DWORD nStdHandle
    call GetStdHandle
    mov [hConsoleOutput], eax

;    call GetCommandLineA
;    mov ebx, eax
;    mov edi, eax
;
;    mov al, 0
;    mov ecx, 0xffffffff
;    cld
;    repnz scasb
;    neg ecx
;    sub ecx, 2

;    ; standard GUI calls still work
;    push MB_ICONINFORMATION ; UINT uType
;    push tada               ; LPCTSTR lpCaption
;    push helloworld         ; LPCTSTR lpText
;    push 0                  ; HWND hWnd
;    call MessageBoxA
;IMPORT user32.dll!MessageBoxA

    push 0                          ; LPVOID lpReserved
    push lpNumbersOfCharsWritten    ; LPWORD lpNumbersOfCharsWritten
    push HELLOWORLD_LEN             ; DWORD nNumbersOfCharsToWrite
    push helloworld                 ; VOID *lpBuffer
    push dword [hConsoleOutput]     ; HANDLE hConsoleOutput
    call WriteConsoleA

    push 0                  ; UINT uExitCode
    call ExitProcess
    retn

lpNumbersOfCharsWritten dd 0
hConsoleOutput dd 0
;tada db "Tada!", 0
helloworld db "Hello World!"
    HELLOWORLD_LEN equ $ - helloworld
db 0

;%IMPORT kernel32.dll!GetStdHandle
;IMPORT kernel32.dll!GetCommandLineA
;%IMPORT kernel32.dll!WriteConsoleA
;%IMPORT kernel32.dll!ExitProcess
;%IMPORTS

%include '../standard_ftr.asm'

; Ange Albertini, Creative Commons BY, 2009-2010