; DLL with minimal export table, and relocations

%include '..\standard_hdr.asm'

; same image_base as PE on purpose, to show relocations

CHARACTERISTICS EQU IMAGE_FILE_EXECUTABLE_IMAGE | IMAGE_FILE_LINE_NUMS_STRIPPED | IMAGE_FILE_LOCAL_SYMS_STRIPPED | IMAGE_FILE_32BIT_MACHINE | IMAGE_FILE_DLL

EntryPoint:
    pushad
    call $ + 5
base:
    pop esi
    add esi, bufferstart - base
    mov edi, esi
    mov ecx, BUFFERLEN
loop_here:
    lodsb
    add al, 42h         ; using add will make relocation still work :p
    stosb
    loop loop_here
nop
nop
    popad
    retn 0ch
nop
nop

bufferstart:
Export:
incbin 'packed_dll.enc'
reloc1_1 equ bufferstart + 2
reloc2_1 equ bufferstart + 2 + 5
;Export:
;    push MB_ICONINFORMATION ; UINT uType
;reloc1_1:
;    push tada               ; LPCTSTR lpCaption
;reloc2_1:
;    push helloworld         ; LPCTSTR lpText
;    push 0                  ; HWND hWnd
;    call MessageBoxA
;    push 0                  ; UINT uExitCode
;    call ExitProcess
;_
;tada db "Tada!", 0
;helloworld db "Hello World!", 0
BUFFERLEN equ $ - bufferstart
nop
nop
reloc3_2:
;%IMPORT user32.dll!MessageBoxA
reloc4_2:
;%IMPORT kernel32.dll!ExitProcess
;%IMPORTS

Exports_Directory:
  Characteristics       dd 0
  TimeDateStamp         dd 0
  MajorVersion          dw 0
  MinorVersion          dw 0
  Name                  dd aDllName - IMAGEBASE
  Base                  dd 0
  NumberOfFunctions     dd 1
  NumberOfNames         dd 1
  AddressOfFunctions    dd address_of_functions - IMAGEBASE
  AddressOfNames        dd address_of_names - IMAGEBASE
  AddressOfNameOrdinals dd address_of_name_ordinals - IMAGEBASE

address_of_functions:
    dd Export - IMAGEBASE

address_of_names:
    dd aExport - IMAGEBASE

address_of_name_ordinals:
    dw 0

aDllName db 'packed_dll.dll', 0

aExport db 'Export', 0

EXPORT_SIZE equ $ - Exports_Directory

;relocations start
Directory_Entry_Basereloc:
block_start:
; relocation block start
    .VirtualAddress dd Section0Start - IMAGEBASE
    .SizeOfBlock dd base_reloc_size_of_block
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc1_1 + 1 - Section0Start)
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc2_1 + 1 - Section0Start)
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc3_2 + 2 - Section0Start)
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc4_2 + 2 - Section0Start)
    base_reloc_size_of_block equ $ - block_start
;relocation block end

;relocations end

DIRECTORY_ENTRY_BASERELOC_SIZE  equ $ - Directory_Entry_Basereloc
%include '..\standard_ftr.asm'
