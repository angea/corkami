; delay imports experiments
; TODO: correct delay imports structure
; TODO: check if Attribute really matters for VA/RVA

%include '../../consts.asm'

IMAGEBASE equ 33330000h
FILEALIGN equ 4h
SECTIONALIGN equ FILEALIGN  ; different alignements are not supported by MakePE
org IMAGEBASE

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
    at IMAGE_FILE_HEADER.NumberOfSections,      dw NUMBEROFSECTIONS
    at IMAGE_FILE_HEADER.SizeOfOptionalHeader,  dw SIZEOFOPTIONALHEADER
    at IMAGE_FILE_HEADER.Characteristics,       dw CHARACTERISTICS
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
    at IMAGE_OPTIONAL_HEADER32.SizeOfHeaders            , dd SIZEOFHEADERS  ; can be 0 in some circumstances
    at IMAGE_OPTIONAL_HEADER32.Subsystem                , dw IMAGE_SUBSYSTEM_WINDOWS_GUI
    at IMAGE_OPTIONAL_HEADER32.NumberOfRvaAndSizes      , dd NUMBEROFRVAANDSIZES
iend

DataDirectory:
istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA,   dd IMPORT_DESCRIPTOR - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.DelayImportsVA, dd delay_imports - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.DelayImportsSize, dd DELAY_IMPORTS_SIZE
iend

NUMBEROFRVAANDSIZES equ ($ - DataDirectory) / IMAGE_DATA_DIRECTORY_size

SIZEOFOPTIONALHEADER equ $ - OptionalHeader

SectionHeader:
istruc IMAGE_SECTION_HEADER
;    at IMAGE_SECTION_HEADER.VirtualSize, dd SECTION0SIZE
    at IMAGE_SECTION_HEADER.VirtualAddress, dd Section0Start - IMAGEBASE
    at IMAGE_SECTION_HEADER.SizeOfRawData, dd SECTION0SIZE
    at IMAGE_SECTION_HEADER.PointerToRawData, dd Section0Start - IMAGEBASE
iend
NUMBEROFSECTIONS equ ($ - SectionHeader) / IMAGE_SECTION_HEADER_size

align FILEALIGN, db 0
SIZEOFHEADERS equ $ - IMAGEBASE

bits 32
base_of_code:
Section0Start:
EntryPoint:
    push MB_ICONINFORMATION ; UINT uType
    push tada               ; LPCTSTR lpCaption
    push helloworld         ; LPCTSTR lpText
    push 0                  ; HWND hWnd
    call dword [imp__MessageBoxA]
    push 0                  ; UINT uExitCode
    call dword [imp__ExitProcess]

    retn

SIZEOFCODE equ $ - base_of_code
align FILEALIGN,db 0

base_of_data:


tada db "Tada!", 0
helloworld db "Hello World!", 0
delay_imports:
    .Attributes dd 2
    .Name dd diName - IMAGEBASE
    .ModuleHandle dd diHandle - IMAGEBASE
    .iat dd dIAT - IMAGEBASE
    .int dd dINT - IMAGEBASE
    .bdiat dd BDIAT - IMAGEBASE
    .udiat dd 0 ; udiat - IMAGEBASE
    .TimeStamp dd 0
times 8 dd 0
DELAY_IMPORTS_SIZE equ $ - delay_imports


diName dd 0
diHandle dd 0

LOADLIBRARYA equ 06FFFE488h

EXITPROCESS equ 031678333h
MESSAGEBOXA equ 021CB7926h

dIAT:
imp__MessageBoxA:
    dd _MessageBoxA
imp__ExitProcess:
    dd _ExitProcess
    dd 0
align 3333h

dINT:
    dd nMessageBoxA
    dd nExitProcess
    dd 0

nMessageBoxA:
    dw 0
    db 'MessageBoxA', 0

nExitProcess:
    dw 0
    db 'ExitProcess', 0

_MessageBoxA:
    push MessageBoxA
    retn

_ExitProcess:
    push ExitProcess
    retn

BDIAT:
    dd 0

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess
;%IMPORTS

SIZEOFINITIALIZEDDATA equ $ - base_of_data

uninit_data:
SIZEOFUNINITIALIZEDDATA equ $ - uninit_data

SECTION0SIZE EQU $ - Section0Start

SIZEOFIMAGE EQU $ - IMAGEBASE