; DLL with minimal export table, and relocations

%include '..\standard_hdr.asm'

; same image_base as PE on purpose, to show relocations

CHARACTERISTICS EQU IMAGE_FILE_EXECUTABLE_IMAGE | IMAGE_FILE_LINE_NUMS_STRIPPED | IMAGE_FILE_LOCAL_SYMS_STRIPPED | IMAGE_FILE_32BIT_MACHINE | IMAGE_FILE_DLL

EntryPoint:
    retn 3 * 4
_
;%EXPORT Export
    push MB_ICONINFORMATION ; UINT uType
;%reloc 1
    push tada               ; LPCTSTR lpCaption
;%reloc 1
    push helloworld         ; LPCTSTR lpText
    push 0                  ; HWND hWnd
    call MessageBoxA
    push 0                  ; UINT uExitCode
    call ExitProcess

tada db "Tada!", 0
helloworld db "Hello World!", 0

;%reloc 2
;%IMPORT user32.dll!MessageBoxA
;%reloc 2
;%IMPORT kernel32.dll!ExitProcess
;%IMPORTS

;%EXPORTS dll.dll

;%relocs

%include '..\standard_ftr.asm'
