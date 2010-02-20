;API calls are replaced by IP-based dispatcher

%include '..\standard_hdr.asm'

EntryPoint:
    call LoadImports

    push MB_ICONINFORMATION ; UINT uType
    push tada               ; LPCTSTR lpCaption
    push helloworld         ; LPCTSTR lpText
    push 0                  ; HWND hWnd
msgbox_here:
    call MessageBoxA
    push 0                  ; UINT uExitCode
    Call ExitProcess
nop
tada db "Tada!", 0
helloworld db "Hello World!", 0
nop
MessageBoxA:
    jmp dispatcher
ExitProcess:
    jmp dispatcher

dispatcher:
    cmp dword [esp], msgbox_here + 5
    jnz one
    jmp [iMessageBoxA]
one:
    jmp [iExitProcess]
nop
%include 'imports_loader.inc'
nop
;%IMPORT kernel32.dll!GetProcAddress
;%IMPORT kernel32.dll!LoadLibraryA
nop
;%IMPORTS
%include '..\standard_ftr.asm'

;Ange Albertini, Creative Commons BY, 2010