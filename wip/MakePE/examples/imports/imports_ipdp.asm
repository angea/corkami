;API calls are replaced by IP-based dispatcher
%define single_call

%include '..\..\standard_hdr.asm'

OEP:
    push MB_ICONINFORMATION ; UINT uType
    push tada               ; LPCTSTR lpCaption
    push helloworld         ; LPCTSTR lpText
    push 0                  ; HWND hWnd
msgbox_here:
%ifdef single_call
    call dispatcher
%else
    call MessageBoxA
%endif
    push 0                  ; UINT uExitCode
%ifdef single_call
    call dispatcher
%else
    call ExitProcess
%endif
_c

%ifndef single_call
MessageBoxA:
    jmp dispatcher
ExitProcess:
    jmp dispatcher
_d
%endif

tada db "Tada!", 0
helloworld db "Hello World!", 0
_d

EntryPoint:
    call LoadImports
    jmp OEP
_c
dispatcher:
    cmp dword [esp], msgbox_here + 5
    jnz one
    jmp [iMessageBoxA]
one:
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