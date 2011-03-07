;manually loading imports

%include '..\..\standard_hdr.asm'

OEP:
    push MB_ICONINFORMATION ; UINT uType
    push tada               ; LPCTSTR lpCaption
    push helloworld         ; LPCTSTR lpText
    push 0                  ; HWND hWnd
    call MessageBoxA
    push 0                  ; UINT uExitCode
    Call ExitProcess
_c
tada db "Tada!", 0
helloworld db "Hello World!", 0
_d
MessageBoxA:
    jmp [iMessageBoxA]
ExitProcess:
    jmp [iExitProcess]
_c
EntryPoint:
    call LoadImports
    jmp OEP
_c
%include 'imports_loader.inc'
_c
;%IMPORT kernel32.dll!GetProcAddress
;%IMPORT kernel32.dll!LoadLibraryA
_d
;%IMPORTS

%include '..\..\standard_ftr.asm'

;Ange Albertini, BSD Licence, 2010-2011