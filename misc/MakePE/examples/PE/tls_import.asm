; TLS callbacks actually an import thunk
; it makes the TLS less obvious, only valid after loading
; and since it calls the TLS with the IMAGEBASE as a parameter, 
; an API like WinExec would execute a file named MZ...

; original idea by Peter Ferrié

%include '../onesec.hdr'

EntryPoint:
    push MB_ICONINFORMATION     ; UINT uType
    push aEntryPoint            ; LPCTSTR lpCaption
    push helloworld             ; LPCTSTR lpText
    push 0                      ; HWND hWnd
    call MessageBoxA

    mov dword [AddressOfCallBacks], 0

    push 0                      ; UINT uExitCode
    call ExitProcess
    retn

aEntryPoint db "Entry Point", 0
helloworld db "Hello World!", 0

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess
;%IMPORT kernel32.dll!WinExec

;%IMPORTS
Image_Tls_Directory32:
    StartAddressOfRawData dd Characteristics ; VA, should point to something null
    EndAddressOfRawData   dd Characteristics ; VA, should point to something null
    AddressOfIndex        dd Characteristics ; VA, should point to something null
    AddressOfCallBacks    dd __imp__WinExec
    SizeOfZeroFill        dd 0
    Characteristics       dd 0

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE

;Ange Albertini, Creative Commons BY, 2010
