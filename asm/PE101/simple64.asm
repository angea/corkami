; a simple PE32+ (a normal 64b PE with many removed elements)

; Ange Albertini, BSD LICENCE 2009-2012

IMAGEBASE equ 400000h
org IMAGEBASE
bits 64

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
    at IMAGE_FILE_HEADER.Machine,              dw IMAGE_FILE_MACHINE_AMD64
    at IMAGE_FILE_HEADER.NumberOfSections,     dw NUMBEROFSECTIONS
    at IMAGE_FILE_HEADER.SizeOfOptionalHeader, dw SIZEOFOPTIONALHEADER
    at IMAGE_FILE_HEADER.Characteristics,      dw IMAGE_FILE_EXECUTABLE_IMAGE | IMAGE_FILE_32BIT_MACHINE
iend
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; optional header
OptionalHeader:
istruc IMAGE_OPTIONAL_HEADER64
    at IMAGE_OPTIONAL_HEADER64.Magic,                 dw IMAGE_NT_OPTIONAL_HDR64_MAGIC
    at IMAGE_OPTIONAL_HEADER64.AddressOfEntryPoint,   dd EntryPoint - IMAGEBASE
    at IMAGE_OPTIONAL_HEADER64.ImageBase,             dq IMAGEBASE
    at IMAGE_OPTIONAL_HEADER64.SectionAlignment,      dd SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER64.FileAlignment,         dd FILEALIGN
    at IMAGE_OPTIONAL_HEADER64.MajorSubsystemVersion, dw 4
    at IMAGE_OPTIONAL_HEADER64.SizeOfImage,           dd 4 * SECTIONALIGN ; 3 sections + header
    at IMAGE_OPTIONAL_HEADER64.SizeOfHeaders,         dd SIZEOFHEADERS
    at IMAGE_OPTIONAL_HEADER64.Subsystem,             dw IMAGE_SUBSYSTEM_WINDOWS_GUI
    at IMAGE_OPTIONAL_HEADER64.NumberOfRvaAndSizes,   dd 16
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
    sub rsp, 5 * 8
    mov ecx, 0
    mov edx, Title_ + DATADELTA
    mov r8d, Caption + DATADELTA
    mov r9d, 0
    call [__imp__MessageBoxA]

    mov ecx, 0
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
    dq hnExitProcess - IMAGEBASE
    dq 0
user32_hintnames:
    dq hnMessageBoxA - IMAGEBASE
    dq 0

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
Title_ db "a simple 64b PE executable", 0
Caption db "Hello world!", 0

DATADELTA equ 3 * SECTIONALIGN + IMAGEBASE - DataSection ; workaround

align FILEALIGN, db 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

