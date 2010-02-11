; DLL with minimal export table, and relocations

;%DEFINE DIRECTORY_ENTRY_BASERELOC_SIZE Directory_Entry_Basereloc
;%DEFINE CHARACTERISTICS

%include '..\standard_hdr.asm'

; same image_base as PE on purpose, to show relocations

CHARACTERISTICS EQU IMAGE_FILE_EXECUTABLE_IMAGE | IMAGE_FILE_LINE_NUMS_STRIPPED | IMAGE_FILE_LOCAL_SYMS_STRIPPED | IMAGE_FILE_32BIT_MACHINE | IMAGE_FILE_DLL

EntryPoint:
    cmp dword [esp + 8], DLL_PROCESS_ATTACH ; DWORD fdwReason
    jnz bye
    push MB_ICONINFORMATION ; UINT uType
reloc1_1:
    push tada               ; LPCTSTR lpCaption
reloc2_1:
    push helloworld         ; LPCTSTR lpText
    push 0                  ; HWND hWnd
    call MessageBoxA
bye:
    retn 3 * 4

tada db "Tada!", 0
helloworld db "Hello World!", 0

reloc3_2:
;%IMPORT user32.dll!MessageBoxA
;%IMPORTS

;relocations start
Directory_Entry_Basereloc:
block_start:
; relocation block start
    .VirtualAddress dd Section0Start - IMAGEBASE
    .SizeOfBlock dd base_reloc_size_of_block
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc1_1 + 1 - Section0Start)
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc2_1 + 1 - Section0Start)
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc3_2 + 2 - Section0Start)
    base_reloc_size_of_block equ $ - block_start
;relocation block end

;relocations end

DIRECTORY_ENTRY_BASERELOC_SIZE  equ $ - Directory_Entry_Basereloc

%include '..\standard_ftr.asm'

; Ange Albertini 2009-2010