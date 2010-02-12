; TLS Callbacks list is modified on the fly to insert extra code
; the TLS info is actually reloaded each time it's needed, instead of loaded once for all from the pe header
; ex: set AddressOfCallBacks to 0, and set it to Callbacks during the EntryPoint code.

%include '..\standard_hdr.asm'

TLS0:
;    mov eax, [__imp__ExitProcess]  ; setting a TLS outside the PE
;    mov dword [Callbacks + 4], eax

    mov dword [Callbacks + 4], TLS
    retn

TLS:
    push MB_ICONINFORMATION ; UINT uType
    push aTls1              ; LPCTSTR lpCaption
    push helloworld         ; LPCTSTR lpText
    push 0                  ; HWND hWnd
    call MessageBoxA
    retn

EntryPoint:
;    mov dword [Callbacks], TLS     ; setting TLS at entrypoint enables extra code after ExitProcess
    push 0
    call ExitProcess

aTls1 db "Original CallBack", 0
aTls2 db "Extra CallBack", 0
aEntryPoint db "Entry Point", 0
helloworld db "Hello World!", 0

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess

;%IMPORTS

Image_Tls_Directory32:
    StartAddressOfRawData dd Characteristics ; VA, should point to something null
    EndAddressOfRawData   dd Characteristics ; VA, should point to something null
    AddressOfIndex        dd Characteristics ; VA, should point to something null
    AddressOfCallBacks    dd Callbacks
    SizeOfZeroFill        dd 0
    Characteristics       dd 0

Callbacks:
    dd TLS0
    dd 0294334
    dd 0

%include '..\standard_ftr.asm'

; Ange Albertini 2009-2010