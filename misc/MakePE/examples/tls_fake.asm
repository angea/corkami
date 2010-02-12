%include '..\standard_hdr.asm'

EntryPoint:
    push MB_ICONINFORMATION ; UINT uType
    push tada               ; LPCTSTR lpCaption
    push helloworld         ; LPCTSTR lpText
    push 0                  ; HWND hWnd
    call MessageBoxA
    push 0                  ; UINT uExitCode
    Call ExitProcess

tada db "Tada!", 0
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

align 4, db 0
Callbacks:
db 'lets fill the Callbacks with some poetry and random blabberring'
;    dd 0

%include '..\standard_ftr.asm'

; Ange Albertini, Creative Commons BY, 2009-2010