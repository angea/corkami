; if no dll is loaded that imports kernel32.dll (like user32.dll)
; TLS is not executed.
; in this example, User32 is loaded manually, and that's why upon exit, TLS is executed.

%include '..\..\standard_hdr.asm'

TLS:
    push aMessageBoxA       ; LPCSTR lpProcName
    push dword [hUser32]    ; HMODULE hModule
    call GetProcAddress
    push MB_ICONINFORMATION ; UINT uType
    push aTls               ; LPCTSTR lpCaption
    push helloworld         ; LPCTSTR lpText
    push 0                  ; HWND hWnd
    call eax
    retn

EntryPoint:
    push aUser32            ; LPCTSTR lpFileName
    call LoadLibraryA
    mov [hUser32], eax
    push 0                  ; UINT uExitCode
    call ExitProcess
    retn
_
aTls db "TLS Callback", 0
aEntryPoint db "Entry Point", 0
helloworld db "Hello World!", 0

hUser32 dd 0
aUser32 db 'user32.dll', 0
aMessageBoxA db 'MessageBoxA',0

;%IMPORT kernel32.dll!ExitProcess
;%IMPORT kernel32.dll!GetProcAddress
;%IMPORT kernel32.dll!LoadLibraryA
;%IMPORT kernel32.dll!FreeLibrary

;%IMPORTS

Image_Tls_Directory32:
    StartAddressOfRawData dd Characteristics
    EndAddressOfRawData   dd Characteristics
    AddressOfIndex        dd Characteristics
    AddressOfCallBacks    dd Callbacks
    SizeOfZeroFill        dd 0
    Characteristics       dd 0

Callbacks:
    dd TLS
    dd 0

%include '..\..\standard_ftr.asm'

; Ange Albertini, Creative Commons BY, 2009-2010