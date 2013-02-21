; (tentative of) multi-subsystem PE
; would display Hello World no matter what the subsystem.

; not working, need work on imports loading

%include '..\..\standard_hdr.asm'

SUBSYSTEM equ IMAGE_SUBSYSTEM_WINDOWS_CUI
;CARACTERISTICS EQU IMAGE_FILE_EXECUTABLE_IMAGE | IMAGE_FILE_32BIT_MACHINE

STD_OUTPUT_HANDLE equ -11

EntryPoint:
    pushad
    push cs
    pop eax
    cmp ax, 01bh            ; XP user mode ?
    jz not_driver
    cmp ax, 023h            ; Win7 user mode
    jz not_driver

    jmp driver

nop
not_driver:
    popad
    mov eax, [OPTIONAL_HEADER.Subsystem]
    cmp eax, 3
    jz console
    cmp eax, 2
    jz gui
    jmp end_

nop
console:
    push STD_OUTPUT_HANDLE  ; DWORD nStdHandle
    call GetStdHandle
    mov [hConsoleOutput], eax

    push 0                          ; LPVOID lpReserved
    push lpNumbersOfCharsWritten    ; LPWORD lpNumbersOfCharsWritten
    push HELLOWORLD_LEN             ; DWORD nNumbersOfCharsToWrite
    push helloworld                 ; VOID *lpBuffer
    push dword [hConsoleOutput]     ; HANDLE hConsoleOutput
    call WriteConsoleA
jmp end_

align 16, int3


nop
driver:
;%reloc 1
    push helloworld     ; PCHAR  Format
;    call DbgPrint
    add esp, 4

    popad
    mov eax, STATUS_DEVICE_CONFIGURATION_ERROR
    retn 8

align 16, int3

;%reloc 2
;IMPORT ntoskrnl.exe!DbgPrint

align 16, int3

;%reloc 2
;%IMPORT kernel32.dll!GetStdHandle
;%reloc 2
;%IMPORT kernel32.dll!WriteConsoleA

align 16, int3

gui:
    push MB_ICONINFORMATION ; UINT uType
    push tada               ; LPCTSTR lpCaption
    push helloworld         ; LPCTSTR lpText
    push 0                  ; HWND hWnd
    call MessageBoxA
jmp end_
align 16, int3

;%reloc 2
;%IMPORT user32.dll!MessageBoxA

align 16, int3

end_:
    push 0                  ; UINT uExitCode
    call ExitProcess
    retn

align 16, int3

;%reloc 2
;%IMPORT kernel32.dll!ExitProcess

align 16, int3

lpNumbersOfCharsWritten dd 0
hConsoleOutput dd 0

align 16, db 0

tada db "Tada!", 0
helloworld db "Hello World!"
    HELLOWORLD_LEN equ $ - helloworld
db 0

align 16, db 0

;%IMPORTS
align 16, db 0
;%relocs

%include '..\..\standard_ftr.asm'

; Ange Albertini, BSD Licence 2011