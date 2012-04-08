; a simple PE (a normal PE with many removed elements)

; Ange Albertini, BSD LICENCE 2009-2012

IMAGEBASE equ 400000h
org IMAGEBASE
bits 32

SECTIONALIGN equ 1000h
FILEALIGN equ 200h

%include 'consts.inc'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MZ header (start of the file)
istruc IMAGE_DOS_HEADER
    at IMAGE_DOS_HEADER.e_magic, db 'MZ'
    at IMAGE_DOS_HEADER.e_lfanew, dd NT_Signature - IMAGEBASE
iend

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PE header

NT_Signature:
istruc IMAGE_NT_HEADERS
    at IMAGE_NT_HEADERS.Signature, db 'PE', 0, 0
iend
istruc IMAGE_FILE_HEADER
    at IMAGE_FILE_HEADER.Machine,              dw IMAGE_FILE_MACHINE_I386
    at IMAGE_FILE_HEADER.NumberOfSections,     dw NUMBEROFSECTIONS
    at IMAGE_FILE_HEADER.SizeOfOptionalHeader, dw SIZEOFOPTIONALHEADER
    at IMAGE_FILE_HEADER.Characteristics,      dw IMAGE_FILE_EXECUTABLE_IMAGE | IMAGE_FILE_32BIT_MACHINE
iend
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; optional header
OptionalHeader:
istruc IMAGE_OPTIONAL_HEADER32
    at IMAGE_OPTIONAL_HEADER32.Magic,                 dw IMAGE_NT_OPTIONAL_HDR32_MAGIC
    at IMAGE_OPTIONAL_HEADER32.AddressOfEntryPoint,   dd EntryPoint - IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.ImageBase,             dd IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.SectionAlignment,      dd SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER32.FileAlignment,         dd FILEALIGN
    at IMAGE_OPTIONAL_HEADER32.MajorSubsystemVersion, dw 4
    at IMAGE_OPTIONAL_HEADER32.SizeOfImage,           dd 4 * SECTIONALIGN ; 3 sections + header
    at IMAGE_OPTIONAL_HEADER32.SizeOfHeaders,         dd SIZEOFHEADERS
    at IMAGE_OPTIONAL_HEADER32.Subsystem,             dw IMAGE_SUBSYSTEM_WINDOWS_GUI
    at IMAGE_OPTIONAL_HEADER32.NumberOfRvaAndSizes,   dd 16
iend

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; data directories
istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA, dd Import_Descriptor - IMAGEBASE
iend

SIZEOFOPTIONALHEADER equ $ - OptionalHeader

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; section table
SectionHeader:
;code section
istruc IMAGE_SECTION_HEADER
    at IMAGE_SECTION_HEADER.Name,             db '.text'
    at IMAGE_SECTION_HEADER.VirtualSize,      dd 1 * SECTIONALIGN
    at IMAGE_SECTION_HEADER.VirtualAddress,   dd 1 * SECTIONALIGN
    at IMAGE_SECTION_HEADER.SizeOfRawData,    dd 1 * FILEALIGN
    at IMAGE_SECTION_HEADER.PointerToRawData, dd 1 * FILEALIGN
    at IMAGE_SECTION_HEADER.Characteristics,  dd IMAGE_SCN_CNT_CODE | IMAGE_SCN_MEM_EXECUTE | IMAGE_SCN_MEM_READ
iend
; imports section
istruc IMAGE_SECTION_HEADER
    at IMAGE_SECTION_HEADER.Name,             db '.rdata'
    at IMAGE_SECTION_HEADER.VirtualSize,      dd 1 * SECTIONALIGN
    at IMAGE_SECTION_HEADER.VirtualAddress,   dd 2 * SECTIONALIGN
    at IMAGE_SECTION_HEADER.SizeOfRawData,    dd 1 * FILEALIGN
    at IMAGE_SECTION_HEADER.PointerToRawData, dd 2 * FILEALIGN
    at IMAGE_SECTION_HEADER.Characteristics,  dd IMAGE_SCN_CNT_INITIALIZED_DATA | IMAGE_SCN_MEM_READ
iend
; data section
istruc IMAGE_SECTION_HEADER
    at IMAGE_SECTION_HEADER.Name,             db '.data'
    at IMAGE_SECTION_HEADER.VirtualSize,      dd 1 * SECTIONALIGN
    at IMAGE_SECTION_HEADER.VirtualAddress,   dd 3 * SECTIONALIGN
    at IMAGE_SECTION_HEADER.SizeOfRawData,    dd 1 * FILEALIGN
    at IMAGE_SECTION_HEADER.PointerToRawData, dd 3 * FILEALIGN
    at IMAGE_SECTION_HEADER.Characteristics,  dd IMAGE_SCN_CNT_INITIALIZED_DATA | IMAGE_SCN_MEM_READ | IMAGE_SCN_MEM_WRITE
iend
NUMBEROFSECTIONS equ ($ - SectionHeader) / IMAGE_SECTION_HEADER_size

align FILEALIGN, db 0
SIZEOFHEADERS equ $ - IMAGEBASE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; code

section progbits vstart=IMAGEBASE + SECTIONALIGN align=FILEALIGN

EntryPoint:
    push 0
    push Title + DATADELTA
    push Caption + DATADELTA
    push 0
    call [__imp__MessageBoxA]

    push 0
    call [__imp__ExitProcess]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section nobits vstart=IMAGEBASE + 2 * SECTIONALIGN align=FILEALIGN
; imports
Import_Descriptor:
istruc IMAGE_IMPORT_DESCRIPTOR ; kernel32 descriptor
    at IMAGE_IMPORT_DESCRIPTOR.OriginalFirstThunk,  dd kernel32_hintnames - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.Name1,               dd kernel32 - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.FirstThunk,          dd kernel32_iat - IMAGEBASE
iend
istruc IMAGE_IMPORT_DESCRIPTOR ; user32 descriptor
    at IMAGE_IMPORT_DESCRIPTOR.OriginalFirstThunk,  dd user32_hintnames - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.Name1,               dd user32 - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.FirstThunk,          dd user32_iat - IMAGEBASE
iend
istruc IMAGE_IMPORT_DESCRIPTOR ; descriptor terminator, all empty
iend

kernel32_hintnames:
    dd hnExitProcess - IMAGEBASE
    dd 0
user32_hintnames:
    dd hnMessageBoxA - IMAGEBASE
    dd 0

hnExitProcess:
    .Hint dw 0
    .Name1 db 'ExitProcess', 0
hnMessageBoxA:
    .Hint dw 0
    .Name1 db 'MessageBoxA', 0

kernel32_iat:
__imp__ExitProcess:
    dd hnExitProcess - IMAGEBASE
    dd 0

user32_iat:
__imp__MessageBoxA:
    dd hnMessageBoxA - IMAGEBASE
    dd 0

kernel32 db 'kernel32.dll', 0
user32 db 'user32.dll', 0

align FILEALIGN, db 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; data
DataSection:
Title db "a simple PE executable", 0
Caption db "Hello world!", 0

DATADELTA equ 3 * SECTIONALIGN + IMAGEBASE - DataSection ; workaround

align FILEALIGN, db 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

