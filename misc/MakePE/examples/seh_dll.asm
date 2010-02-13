; DLL with minimal export table, and relocations

%include '..\standard_hdr.asm'

; same image_base as PE on purpose, to show relocations

CHARACTERISTICS EQU IMAGE_FILE_EXECUTABLE_IMAGE | IMAGE_FILE_LINE_NUMS_STRIPPED | IMAGE_FILE_LOCAL_SYMS_STRIPPED | IMAGE_FILE_32BIT_MACHINE | IMAGE_FILE_DLL

EntryPoint:
;    int3
    push esi
    xor esi, esi
    db 64h      ; FS prefix - yasm doesn't accept string operators on explicit segments
    lodsd
    inc eax
scan_loop:
    dec eax
    xchg eax, esi
    lodsd
    inc eax
    jnz scan_loop
;%reloc 2
    mov dword [esi], runme
    pop esi
Export:
    retn

runme:
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

aDllName db 'seh_dll.dll', 0

aExport db 'Export', 0

EXPORT_SIZE equ $ - Exports_Directory

;%relocs
%include '..\standard_ftr.asm'
