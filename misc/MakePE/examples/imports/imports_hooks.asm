;IAT based and API based imports hooks

%include '..\..\standard_hdr.asm'

EntryPoint:
    push 0                      ; BOOL bRebootAfterShutdown *fake*
    push MB_ICONINFORMATION     ; BOOL bForceAppsClosed
    push tada                   ; DWORD dwTimeout
    push helloworld             ; LPTSTR lpMessage
    push 0                      ; LPTSTR lpMachineName
    call InitiateSystemShutdownA
    add esp, 4
_
    push 0      ; LPCTSTR lpFileName
    call DeleteFileA
    retn        ; fake
_c
;%IMPORT advapi32.dll!InitiateSystemShutdownA
;%IMPORT kernel32.dll!DeleteFileA
_c

TLS:
    call hook
    retn
_c

hook:
    ; IAT hook
    push dword [__imp__MessageBoxA]
    pop dword [__imp__InitiateSystemShutdownA]
_
    ; code hook
    ; make code writeable
    push lpflOldProtect             ; PDWORD lpflOldProtect
    push PAGE_EXECUTE_READWRITE     ; DWORD flNewProtect
    push 010h                       ; SIZE_T dwSize
    push dword [__imp__DeleteFileA] ; LPVOID lpAddress
    call VirtualProtect
_
    ; patch code
    mov ebx, [__imp__DeleteFileA]
    mov eax, [__imp__ExitProcess]
    mov byte [ebx], 068h            ; 68 xxxxxxxx   push xxxxxxxx
    mov dword [ebx + 1], eax
    mov byte [ebx + 5], 0c3h        ; C3            retn
    retn
_c
;%IMPORT kernel32.dll!VirtualProtect
;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess
_d
lpflOldProtect dd 0
tada db "Tada!", 0
helloworld db "Hello World!",0
_d
;%IMPORTS
_d
Image_Tls_Directory32:
    StartAddressOfRawData dd Characteristics
    EndAddressOfRawData   dd Characteristics
    AddressOfIndex        dd Characteristics
    AddressOfCallBacks    dd SizeOfZeroFill
;Callbacks: ; embedded structure
    SizeOfZeroFill        dd TLS
    Characteristics       dd 0

%include '..\..\standard_ftr.asm'

;Ange Albertini, BSD Licence, 2010-2011