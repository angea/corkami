; DLL with minimal export table, and relocations

%include '..\..\standard_hdr.asm'

IMAGEBASE EQU 330000h
CHARACTERISTICS EQU IMAGE_FILE_EXECUTABLE_IMAGE | IMAGE_FILE_32BIT_MACHINE | IMAGE_FILE_DLL

;%EXPORT Export
    push MB_ICONINFORMATION ; UINT uType
    push tada               ; LPCTSTR lpCaption
    push helloworld         ; LPCTSTR lpText
    push 0                  ; HWND hWnd
    call MessageBoxA
    push 0                  ; UINT uExitCode
    call ExitProcess

EntryPoint:
    retn

tada db "Tada!", 0
helloworld db "Hello World!", 0

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess

;%IMPORTS

;%EXPORTS no_relocs.dll

%include '..\..\standard_ftr.asm'

; Ange Albertini, Creative Commons BY, 2009-2010