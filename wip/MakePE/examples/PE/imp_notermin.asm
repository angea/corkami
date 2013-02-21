; small PoC where the import descriptor terminator is outside the file
; compile with Yasm

;Ange Albertini, BSD Licence 2011

%include '..\..\consts.asm'

org IMAGEBASE

SECTIONALIGN EQU 4 ; <= 800h for a section-less file.
FILEALIGN EQU SECTIONALIGN ; MakePE limitation

istruc IMAGE_DOS_HEADER
    at IMAGE_DOS_HEADER.e_magic, db 'MZ'
    at IMAGE_DOS_HEADER.e_lfanew, dd nt_header - IMAGEBASE
iend

nt_header:
istruc IMAGE_NT_HEADERS
    at IMAGE_NT_HEADERS.Signature, db 'PE',0,0
iend
istruc IMAGE_FILE_HEADER
    at IMAGE_FILE_HEADER.Machine,               dw IMAGE_FILE_MACHINE_I386
;    at IMAGE_FILE_HEADER.NumberOfSections,      dw NUMBEROFSECTIONS     ; we don't need you today
;    at IMAGE_FILE_HEADER.SizeOfOptionalHeader,  dw SIZEOFOPTIONALHEADER ; you neither
    at IMAGE_FILE_HEADER.Characteristics,       dw IMAGE_FILE_RELOCS_STRIPPED | IMAGE_FILE_EXECUTABLE_IMAGE | \
        IMAGE_FILE_LINE_NUMS_STRIPPED | IMAGE_FILE_LOCAL_SYMS_STRIPPED | IMAGE_FILE_32BIT_MACHINE
iend

OptionalHeader:
istruc IMAGE_OPTIONAL_HEADER32
    at IMAGE_OPTIONAL_HEADER32.Magic                    , dw IMAGE_NT_OPTIONAL_HDR32_MAGIC
    at IMAGE_OPTIONAL_HEADER32.AddressOfEntryPoint      , dd EntryPoint - IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.ImageBase                , dd IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.SectionAlignment         , dd SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER32.FileAlignment            , dd FILEALIGN
    at IMAGE_OPTIONAL_HEADER32.MajorSubsystemVersion    , dw 4
    at IMAGE_OPTIONAL_HEADER32.SizeOfImage              , dd SIZEOFIMAGE
    at IMAGE_OPTIONAL_HEADER32.SizeOfHeaders            , dd SIZEOFHEADERS
    at IMAGE_OPTIONAL_HEADER32.Subsystem                , dw IMAGE_SUBSYSTEM_WINDOWS_GUI
    at IMAGE_OPTIONAL_HEADER32.NumberOfRvaAndSizes      , dd NUMBEROFRVAANDSIZES
iend

DataDirectory:
istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA, dd IMPORT_DESCRIPTOR - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.IATVA,     dd ImportsAddressTable - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.IATSize,   dd IMPORTSADDRESSTABLESIZE
iend

NUMBEROFRVAANDSIZES equ ($ - DataDirectory) / IMAGE_DATA_DIRECTORY_size
SIZEOFOPTIONALHEADER equ $ - OptionalHeader
SIZEOFHEADERS EQU $ - IMAGEBASE

bits 32
EntryPoint:
    push MB_ICONINFORMATION ; UINT uType
    push tada               ; LPCTSTR lpCaption
    push helloworld         ; LPCTSTR lpText
    push 0                  ; HWND hWnd
    call MessageBoxA
    push 0                  ; UINT uExitCode
    call ExitProcess
MessageBoxA:
    jmp [__imp__MessageBoxA]
ExitProcess:
    jmp [__imp__ExitProcess]

tada db "Tada!", 0
helloworld db "Hello World!", 0

ImportsAddressTable:
ImportAddressTable:
;align 2, db 0
kernel32.dll_iat:

__imp__ExitProcess:
    DD hnExitProcess - IMAGEBASE         ; ForwarderString / Function / Ordinal / AddressOfData
    DD 0

;align 2, db 0
user32.dll_iat:

__imp__MessageBoxA:
    DD hnMessageBoxA - IMAGEBASE         ; ForwarderString / Function / Ordinal / AddressOfData
    DD 0

IAT_size equ $ - ImportAddressTable

HintNames:
;align 2, db 0
kernel32.dll_hintnames:

    DD hnExitProcess - IMAGEBASE         ; ForwarderString / Function / Ordinal / AddressOfData
    DD 0

;align 2, db 0
user32.dll_hintnames:

    DD hnMessageBoxA - IMAGEBASE         ; ForwarderString / Function / Ordinal / AddressOfData
    DD 0

;align 2, db 0
hnExitProcess:
    dw 0            ; Hint
    db 'ExitProcess',0  ; Name

;align 2, db 0
hnMessageBoxA:
    dw 0            ; Hint
    db 'MessageBoxA',0  ; Name

;align 2, db 0
kernel32.dll  DB 'kernel32.dll',0

;align 2, db 0
user32.dll  DB 'user32.dll',0

DIRECTORY_ENTRY_IMPORT_SIZE EQU $ - IMPORT_DESCRIPTOR

IMPORT_DESCRIPTOR: ; replace with imports:
kernel32.dll_DESCRIPTOR:
    dd kernel32.dll_hintnames - IMAGEBASE    ; OriginalFirstThunk/Characteristics, IMAGE_IMPORT_BY_NAME array
    dd 0                                ; TimeDateStamp
    dd 0                                ; ForwarderChain
    dd kernel32.dll - IMAGEBASE              ; Name
    dd kernel32.dll_iat - IMAGEBASE          ; FirstThunk


user32.dll_DESCRIPTOR:
    dd user32.dll_hintnames - IMAGEBASE    ; OriginalFirstThunk/Characteristics, IMAGE_IMPORT_BY_NAME array
    dd 0                                ; TimeDateStamp
    dd 0                                ; ForwarderChain
    dd user32.dll - IMAGEBASE              ; Name
    dd user32.dll_iat - IMAGEBASE          ; FirstThunk



IMPORTSADDRESSTABLESIZE equ $ - ImportsAddressTable

SIZEOFIMAGE equ $ - IMAGEBASE


SUBSYSTEM EQU IMAGE_SUBSYSTEM_WINDOWS_GUI
IMAGEBASE EQU 400000H
CHARACTERISTICS EQU IMAGE_FILE_RELOCS_STRIPPED | IMAGE_FILE_EXECUTABLE_IMAGE | IMAGE_FILE_LINE_NUMS_STRIPPED | IMAGE_FILE_LOCAL_SYMS_STRIPPED | IMAGE_FILE_32BIT_MACHINE
Exports_Directory EQU IMAGEBASE
Directory_Entry_Basereloc EQU IMAGEBASE
DIRECTORY_ENTRY_EXPORT_SIZE EQU 0
DIRECTORY_ENTRY_RESOURCE_SIZE EQU 0
DIRECTORY_ENTRY_IAT_SIZE EQU 0
DIRECTORY_ENTRY_TLS_SIZE EQU 0
DIRECTORY_ENTRY_BASERELOC_SIZE EQU 0
Image_Tls_Directory32 EQU IMAGEBASE
Image_Delay_Import_Directory32 EQU IMAGEBASE
Directory_Entry_Resource EQU IMAGEBASE