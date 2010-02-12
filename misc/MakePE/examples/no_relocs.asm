; DLL with minimal export table, and relocations

%include '..\standard_hdr.asm'

IMAGEBASE EQU 330000h
CHARACTERISTICS EQU IMAGE_FILE_EXECUTABLE_IMAGE | IMAGE_FILE_32BIT_MACHINE | IMAGE_FILE_DLL

Export:
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

aDllName db 'no_relocs.dll', 0

aExport db 'Export', 0

DIRECTORY_ENTRY_EXPORT_SIZE equ $ - Exports_Directory

%include '..\standard_ftr.asm'

; Ange Albertini, Creative Commons BY, 2009-2010