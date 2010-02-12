; standard TLS
; using a byte flag to avoid executing twice (just for cosmetic reason)
; looping infinitely if there is a software breakpoint found on the EP

%include '..\standard_hdr.asm'

already_executed db 0
TLS:
    cmp byte [EntryPoint], 0cch     ; let's see if someone put a software breakpoint on the EntryPoint
    jz TLS                          ; and loop infinitely if that's the case

    ; another common trick is to jump beyond the next byte after
    ; jmp EntryPoint + 1 - and terminate before EP is executed

    test byte [already_executed], 1
    jnz tls_end
    mov byte [already_executed], 1
    push MB_ICONINFORMATION     ; UINT uType
    push aTls                   ; LPCTSTR lpCaption
    push helloworld             ; LPCTSTR lpText
    push 0                      ; HWND hWnd
    call MessageBoxA
tls_end:
    retn

EntryPoint:
    nop		; spaceholder for software breakpoint
    push MB_ICONINFORMATION     ; UINT uType
    push aEntryPoint            ; LPCTSTR lpCaption
    push helloworld             ; LPCTSTR lpText
    push 0                      ; HWND hWnd
    call MessageBoxA
    push 0                      ; UINT uExitCode
    call ExitProcess
    retn

aTls db "TLS Callback", 0
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
    dd TLS
    dd 0
%include '..\standard_ftr.asm'

; Ange Albertini 2009-2010