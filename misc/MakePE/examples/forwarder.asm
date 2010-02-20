; DLL with minimal export table, and relocations

%include '..\standard_hdr.asm'

CHARACTERISTICS equ IMAGE_FILE_EXECUTABLE_IMAGE | IMAGE_FILE_32BIT_MACHINE | IMAGE_FILE_DLL

IMPORT_DESCRIPTOR equ IMAGEBASE
DIRECTORY_ENTRY_IMPORT_SIZE equ 0

EntryPoint:
    retn

Exports_Directory:
  Characteristics       dd 0
  TimeDateStamp         dd 0
  MajorVersion          dw 0
  MinorVersion          dw 0
  Name                  dd export_name - IMAGEBASE
  Base                  dd 0
  NumberOfFunctions     dd number_of_functions
  NumberOfNames         dd number_of_names
  AddressOfFunctions    dd address_of_functions - IMAGEBASE
  AddressOfNames        dd address_of_names - IMAGEBASE
  AddressOfNameOrdinals dd address_of_name_ordinals - IMAGEBASE

address_of_functions:
    dd akernel32_exitprocess - IMAGEBASE
    dd auser32_messageboxa - IMAGEBASE
number_of_functions equ ($ - address_of_functions) / 4

address_of_names:
    dd aDeleteFileA - IMAGEBASE
    dd aInitiateSystemShutdownA - IMAGEBASE
number_of_names equ ($ - address_of_names) / 4

address_of_name_ordinals:
    dw 0
    dw 1

export_name db 'forwarder.dll', 0

auser32_messageboxa db 'user32.MessageBoxA', 0
akernel32_exitprocess db 'kernel32.ExitProcess', 0

aDeleteFileA db 'DeleteFileA', 0
aInitiateSystemShutdownA db 'InitiateSystemShutdownA', 0

DIRECTORY_ENTRY_EXPORT_SIZE equ $ - Exports_Directory

%include '..\standard_ftr.asm'

;Ange Albertini, Creative Commons BY, 2010