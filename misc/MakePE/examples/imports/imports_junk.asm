;manually loaded imports but the trampolines have junk inserted
;to remove references to API in the code during debugging

%include '..\..\standard_hdr.asm'

OEP:
    push MB_ICONINFORMATION ; UINT uType
    push tada               ; LPCTSTR lpCaption
    push helloworld         ; LPCTSTR lpText
    push 0                  ; HWND hWnd
    call MessageBoxA
    push 0                  ; UINT uExitCode
    call ExitProcess
_c
tada db "Tada!", 0
helloworld db "Hello World!", 0
_d
EntryPoint:
    ; TODO: add patching
    call LoadImports
    jmp OEP
_d
MessageBoxA:
    nop
    jmp [iMessageBoxA]
ExitProcess:
    nop
    jmp [iExitProcess]
_c
%include 'imports_loader.inc'
_c
;%IMPORT kernel32.dll!GetProcAddress
;%IMPORT kernel32.dll!LoadLibraryA
_d
;%IMPORTS

%include '..\..\standard_ftr.asm'

;Ange Albertini, BSD Licence, 2010-2011