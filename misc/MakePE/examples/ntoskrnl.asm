; DLL with minimal export table, and relocations

%include '..\standard_hdr.asm'

EntryPoint:
    retn 3 * 4

Export:
    mov eax, [esp]
    mov ebx, [esp+4]
    push eax
    push MB_ICONINFORMATION ; UINT uType
reloc1_1:
    push Driver             ; LPCTSTR lpCaption
reloc2_1:
    push ebx                ; LPCTSTR lpText
    push 0                  ; HWND hWnd
    call MessageBoxA
    retn

Driver db "Hello usermode driver!", 0

reloc3_2:
;%IMPORT user32.dll!MessageBoxA
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

aDllName db 'ntoskrnl.exe', 0

aExport db 'DbgPrint', 0

EXPORT_SIZE equ $ - Exports_Directory

;relocations start
DIRECTORY_ENTRY_BASERELOC:
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

DIRECTORY_ENTRY_BASERELOC_SIZE  equ $ - DIRECTORY_ENTRY_BASERELOC
%include '..\standard_ftr.asm'
