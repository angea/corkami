; DLL with minimal export table, and relocations

%include '..\standard_hdr.asm'

; same image_base as PE on purpose, to show relocations

CHARACTERISTICS EQU IMAGE_FILE_EXECUTABLE_IMAGE | IMAGE_FILE_LINE_NUMS_STRIPPED | IMAGE_FILE_LOCAL_SYMS_STRIPPED | IMAGE_FILE_32BIT_MACHINE | IMAGE_FILE_DLL

EntryPoint:
    cmp dword [esp + 8], DLL_PROCESS_ATTACH ; DWORD fdwReason
    jnz bye
    push MB_ICONINFORMATION ; UINT uType
;%reloc 1
    push tada               ; LPCTSTR lpCaption
;%reloc 1
    push helloworld         ; LPCTSTR lpText
    push 0                  ; HWND hWnd
    call MessageBoxA
bye:
    retn 3 * 4

tada db "Tada!", 0
helloworld db "Hello World!", 0

;%reloc 2
;%IMPORT user32.dll!MessageBoxA
;%IMPORTS

;%relocs

%include '..\standard_ftr.asm'

; Ange Albertini, Creative Commons BY, 2009-2010