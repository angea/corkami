; empty entry point file, looks buggy as much as possible but TLS is setting things correctly
; would look better with split sections or other code in header

%include '..\standard_hdr.asm'

stub:
    push MB_ICONINFORMATION     ; UINT uType
    push aEntryPoint            ; LPCTSTR lpCaption
    push helloworld             ; LPCTSTR lpText
    push 0                      ; HWND hWnd
    call MessageBoxA
    push 0                      ; UINT uExitCode
    call ExitProcess

TLS:
    mov eax, [fs:0]
    add eax, 4
    mov dword [eax], stub
;    push stub
;    push dword [fs:0]
;    mov [fs:0], esp

    mov dword [Callbacks], 0    ; preventing TLS to be re-executed
    mov eax, EntryPoint
    jmp eax

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

EntryPoint:
    times 10h add [eax], al
%include '..\standard_ftr.asm'

; Ange Albertini, Creative Commons BY, 2009-2010