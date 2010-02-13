; DLL mimicking basic ntoskrnl functionalities for execution of drivers in user mode

%include '..\standard_hdr.asm'

EntryPoint:
    retn 3 * 4

DbgPrint:
    mov ebx, [esp+4]        ; DbgPrint doesn't clear arguments from the stack
    push MB_ICONINFORMATION ; UINT uType
;%reloc 1
    push Driver             ; LPCTSTR lpCaption
;%reloc 1
    push ebx                ; LPCTSTR lpText
    push 0                  ; HWND hWnd
    call MessageBoxA
    retn

Driver db "User mode Ntoskrnl", 0

;%reloc 2
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
    dd DbgPrint - IMAGEBASE

address_of_names:
    dd aDbgPrint - IMAGEBASE

address_of_name_ordinals:
    dw 0

aDllName db 'ntoskrnl.exe', 0

aDbgPrint db 'DbgPrint', 0

EXPORT_SIZE equ $ - Exports_Directory

;%relocs

%include '..\standard_ftr.asm'

;Ange Albertini, Creative Commons BY, 2010