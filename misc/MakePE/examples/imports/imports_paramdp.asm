;imports loading, with a parameter-based dispatcher instead of direct calls to API

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
EntryPoint:
    call LoadImports
    jmp OEP
_c
tada db "Tada!", 0
helloworld db "Hello World!", 0
_d
MessageBoxA:
    push 0
    jmp dispatcher
ExitProcess:
    push 1
    jmp dispatcher
_
dispatcher:
    cmp dword [esp], 1
    jz one
    add esp, 4
    jmp [iMessageBoxA]
one:
    add esp, 4
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