; EXE with exports, calling itself.

%include '..\standard_hdr.asm'

EntryPoint:
    call MyExport
    push 0                  ; UINT uExitCode
    call ExitProcess
;%IMPORT kernel32.dll!ExitProcess
;%EXPORT MyExport
    push MB_ICONINFORMATION ; UINT uType
    push tada               ; LPCTSTR lpCaption
    push helloworld         ; LPCTSTR lpText
    push 0                  ; HWND hWnd
    call MessageBoxA
    retn
;%IMPORT own_exports.exe!MyExport
;%IMPORT user32.dll!MessageBoxA

tada db "Tada!", 0
helloworld db "Hello World!", 0

;%IMPORTS

;%EXPORTS own_exports.exe

%include '..\standard_ftr.asm'
