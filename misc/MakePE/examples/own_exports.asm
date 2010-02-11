; EXE with exports, calling itself.

;%DEFINE Exports_Directory

%include '..\standard_hdr.asm'

EntryPoint:
    call MyExport
    push 0                  ; UINT uExitCode
    call ExitProcess

__exp__MyExport:
    push MB_ICONINFORMATION ; UINT uType
    push tada               ; LPCTSTR lpCaption
    push helloworld         ; LPCTSTR lpText
    push 0                  ; HWND hWnd
    call MessageBoxA
    retn

tada db "Tada!", 0
helloworld db "Hello World!", 0

;%IMPORT own_exports.exe!MyExport
;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess
;%IMPORTS

Exports_Directory:
  Characteristics       dd 0
  TimeDateStamp         dd 0
  MajorVersion          dw 0
  MinorVersion          dw 0
  Name                  dd export_name - IMAGEBASE
  Base                  dd 0
  NumberOfFunctions     dd 1
  NumberOfNames         dd 1
  AddressOfFunctions    dd address_of_functions - IMAGEBASE
  AddressOfNames        dd address_of_names - IMAGEBASE
  AddressOfNameOrdinals dd address_of_name_ordinals - IMAGEBASE

address_of_functions:
    dd __exp__MyExport - IMAGEBASE

address_of_names:
    dd a__exp__MyExport_ - IMAGEBASE

address_of_name_ordinals:
    dw 0

export_name db 'own_exports.exe', 0

a__exp__MyExport_ db 'MyExport', 0 ; duplicates because of automated imports generation

EXPORT_SIZE equ $ - Exports_Directory

%include '..\standard_ftr.asm'
