EntryPoint:
    call LoadImports

    push MB_ICONINFORMATION ; UINT uType
    push tada               ; LPCTSTR lpCaption
    push helloworld         ; LPCTSTR lpText
    push 0                  ; HWND hWnd
    call MessageBoxA
    push 0                  ; UINT uExitCode
    Call ExitProcess

tada db "Tada!", 0
helloworld db "Hello World!", 0
