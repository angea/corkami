;IAT based and API based imports hooks

%include '..\standard_hdr.asm'

EntryPoint:
    call hook
nop
    push 0                      ; BOOL bRebootAfterShutdown *fake*
    push MB_ICONINFORMATION     ; BOOL bForceAppsClosed
    push tada                   ; DWORD dwTimeout
    push helloworld             ; LPTSTR lpMessage
    push 0                      ; LPTSTR lpMachineName
    call InitiateSystemShutdownA
    add esp, 4
nop
    push 0      ; LPCTSTR lpFileName
    call DeleteFileA
    retn        ; cosmetic opcode to split functions
nop
hook:
    ; IAT hook
    push dword [__imp__MessageBoxA]
    pop dword [__imp__InitiateSystemShutdownA]
nop
PAGE_EXECUTE_READWRITE    equ 40h
    ; code hook
    ; make code writeable
    push lpflOldProtect             ; PDWORD lpflOldProtect
    push PAGE_EXECUTE_READWRITE     ; DWORD flNewProtect
    push 010h                       ; SIZE_T dwSize
    push dword [__imp__DeleteFileA] ; LPVOID lpAddress
    call VirtualProtect
nop
    ; patch code
    mov ebx, [__imp__DeleteFileA]
    mov eax, [__imp__ExitProcess]
    mov byte [ebx], 068h            ; 68 xxxxxxxx   push xxxxxxxx
    mov dword [ebx + 1], eax
    mov byte [ebx + 5], 0c3h        ; C3            retn
    retn

lpflOldProtect dd 0
align 16, db 0
tada db "Tada!", 0
helloworld db "Hello World!",0
align 16, db 0

;%IMPORT advapi32.dll!InitiateSystemShutdownA
;%IMPORT kernel32.dll!DeleteFileA

;%IMPORT kernel32.dll!VirtualProtect

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess
;%IMPORTS

%include '..\standard_ftr.asm'

;Ange Albertini, Creative Commons BY, 2010