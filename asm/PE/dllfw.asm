; forwarding DLL with minimal export table, and relocations

; Ange Albertini, BSD LICENCE 2009-2011

%include 'consts.inc'
%define iround(n, r) (((n + (r - 1)) / r) * r)

IMAGEBASE equ 1000000h
org IMAGEBASE
bits 32

SECTIONALIGN equ 1000h
FILEALIGN equ 200h

istruc IMAGE_DOS_HEADER
    at IMAGE_DOS_HEADER.e_magic, db 'MZ'
    at IMAGE_DOS_HEADER.e_lfanew, dd NT_Signature - IMAGEBASE
iend

NT_Signature:
istruc IMAGE_NT_HEADERS
    at IMAGE_NT_HEADERS.Signature, db 'PE', 0, 0
iend
istruc IMAGE_FILE_HEADER
    at IMAGE_FILE_HEADER.Machine,               dw IMAGE_FILE_MACHINE_I386
    at IMAGE_FILE_HEADER.NumberOfSections,      dw NUMBEROFSECTIONS
    at IMAGE_FILE_HEADER.SizeOfOptionalHeader,  dw SIZEOFOPTIONALHEADER
    at IMAGE_FILE_HEADER.Characteristics,       dw IMAGE_FILE_EXECUTABLE_IMAGE | IMAGE_FILE_32BIT_MACHINE | IMAGE_FILE_DLL
iend

OptionalHeader:
istruc IMAGE_OPTIONAL_HEADER32
    at IMAGE_OPTIONAL_HEADER32.Magic,                     dw IMAGE_NT_OPTIONAL_HDR32_MAGIC
    at IMAGE_OPTIONAL_HEADER32.AddressOfEntryPoint,       dd VDELTA + EntryPoint - IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.ImageBase,                 dd IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.SectionAlignment,          dd SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER32.FileAlignment,             dd FILEALIGN
    at IMAGE_OPTIONAL_HEADER32.MajorSubsystemVersion,     dw 4
    at IMAGE_OPTIONAL_HEADER32.SizeOfImage,               dd VDELTA + SIZEOFIMAGE
    at IMAGE_OPTIONAL_HEADER32.SizeOfHeaders,             dd SIZEOFHEADERS
    at IMAGE_OPTIONAL_HEADER32.Subsystem,                 dw IMAGE_SUBSYSTEM_WINDOWS_CUI
    at IMAGE_OPTIONAL_HEADER32.NumberOfRvaAndSizes,       dd 16
iend

DataDirectory:
istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ExportsVA,  dd VDELTA + Exports_Directory - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.ExportsSize,  dd EXPORTS_SIZE    ; exports size is *REQUIRED* in this case
iend

SIZEOFOPTIONALHEADER equ $ - OptionalHeader
SectionHeader:
istruc IMAGE_SECTION_HEADER
    at IMAGE_SECTION_HEADER.VirtualSize,      dd Section0Size
    at IMAGE_SECTION_HEADER.VirtualAddress,   dd VDELTA + Section0Start - IMAGEBASE
    at IMAGE_SECTION_HEADER.SizeOfRawData,    dd iround(Section0Size, FILEALIGN)
    at IMAGE_SECTION_HEADER.PointerToRawData, dd Section0Start - IMAGEBASE
    at IMAGE_SECTION_HEADER.Characteristics,  dd IMAGE_SCN_MEM_EXECUTE + IMAGE_SCN_MEM_WRITE
iend
NUMBEROFSECTIONS equ ($ - SectionHeader) / IMAGE_SECTION_HEADER_size

ALIGN FILEALIGN, db 0

SIZEOFHEADERS equ $ - IMAGEBASE

Section0Start:
VDELTA equ SECTIONALIGN - ($ - IMAGEBASE) ; VIRTUAL DELTA between this sections offset and virtual addresses

EntryPoint:
    push 1
    pop eax
    retn 3 * 4
_c

Exports_Directory:
  Characteristics       dd 0
  TimeDateStamp         dd 0
  MajorVersion          dw 0
  MinorVersion          dw 0
  Name                  dd 0
  Base                  dd 0
  NumberOfFunctions     dd NUMBER_OF_FUNCTIONS
  NumberOfNames         dd NUMBER_OF_NAMES
  AddressOfFunctions    dd VDELTA + address_of_functions - IMAGEBASE
  AddressOfNames        dd VDELTA + address_of_names - IMAGEBASE
  AddressOfNameOrdinals dd VDELTA + address_of_name_ordinals - IMAGEBASE
_d

address_of_functions:
    dd VDELTA + amsvcrt_printf - IMAGEBASE
NUMBER_OF_FUNCTIONS equ ($ - address_of_functions) / 4
_d

address_of_names:
    dd VDELTA + a__exp__Export - IMAGEBASE
NUMBER_OF_NAMES equ ($ - address_of_names) / 4
_d

amsvcrt_printf db "msvcrt.printf", 0 ; forwarding string can only be within the official export directory bounds
_d

address_of_name_ordinals:
    dw 0
_d

a__exp__Export db 'ExitProcess', 0
_d

EXPORTS_SIZE equ $ - Exports_Directory

align FILEALIGN, db 0
SIZEOFIMAGE equ $ - IMAGEBASE
Section0Size equ $ - Section0Start