; DLL with minimal export table, and relocations

%include '..\..\consts.inc'
IMAGE_FILE_DLL equ 02000h
%define iround(n, r) (((n + (r - 1)) / r) * r)

IMAGEBASE equ 400000h
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
    at IMAGE_FILE_HEADER.Characteristics,       dw IMAGE_FILE_EXECUTABLE_IMAGE | IMAGE_FILE_LINE_NUMS_STRIPPED | IMAGE_FILE_LOCAL_SYMS_STRIPPED | IMAGE_FILE_32BIT_MACHINE | IMAGE_FILE_DLL
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
    at IMAGE_DATA_DIRECTORY_16.ImportsVA,  dd VDELTA + import_descriptor - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.FixupsVA,   dd VDELTA + Directory_Entry_Basereloc - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.FixupsSize, dd DIRECTORY_ENTRY_BASERELOC_SIZE
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
reloc01:
    push VDELTA + loaded_dll
reloc12:
    call [VDELTA + __imp__printf]
    add esp, 1 * 4
    retn 3 * 4
_c
__exp__Export:
reloc21:
    push VDELTA + export_
reloc32:
    call [VDELTA + __imp__printf]
    add esp, 1 * 4
    retn
_c

loaded_dll db "DLL loaded successfully", 0ah, 0
export_ db "export executed successfully", 0ah, 0

msvcrt.dll_iat:
__imp__printf:
    DD VDELTA + hnprintf - IMAGEBASE
    DD 0

import_descriptor:
;msvcrt.dll_DESCRIPTOR:
    dd VDELTA + msvcrt.dll_hintnames - IMAGEBASE
    dd 0
    dd 0
    dd VDELTA + msvcrt.dll - IMAGEBASE
    dd VDELTA + msvcrt.dll_iat - IMAGEBASE

    times 5 dd 0

msvcrt.dll_hintnames:
    DD VDELTA + hnprintf - IMAGEBASE
    DD 0

hnprintf:
    dw 0
    db 'printf', 0

msvcrt.dll db 'msvcrt.dll', 0

Exports_Directory:
  Characteristics       dd 0
  TimeDateStamp         dd 0
  MajorVersion          dw 0
  MinorVersion          dw 0
  Name                  dd 0;VDELTA + aDllName - IMAGEBASE
  Base                  dd 0
  NumberOfFunctions     dd NUMBER_OF_FUNCTIONS
  NumberOfNames         dd NUMBER_OF_NAMES
  AddressOfFunctions    dd VDELTA + address_of_functions - IMAGEBASE
  AddressOfNames        dd VDELTA + address_of_names - IMAGEBASE
  AddressOfNameOrdinals dd VDELTA + address_of_name_ordinals - IMAGEBASE

;aDllName db 'the dll name is completely ignored', 0

;align 2, db 0
dllU db 'd', 0, 'l', 0, 'l', 0, '.', 0, 'd', 0, 'l', 0, 'l', 0, 0, 0

address_of_functions:
    dd VDELTA + __exp__Export - IMAGEBASE
NUMBER_OF_FUNCTIONS equ ($ - address_of_functions) / 4
address_of_names:
    dd VDELTA + a__exp__Export - IMAGEBASE
NUMBER_OF_NAMES equ ($ - address_of_names) / 4
address_of_name_ordinals:
    dw 0

a__exp__Export:
times 010000h db 0ffh
    db 0

EXPORT_SIZE equ $ - Exports_Directory

Directory_Entry_Basereloc:
block_start0:
    .VirtualAddress dd VDELTA + reloc01 - IMAGEBASE
    .SizeOfBlock dd BASE_RELOC_SIZE_OF_BLOCK0
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc01 + 1 - reloc01)
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc12 + 2 - reloc01)
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc21 + 1 - reloc01)
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc32 + 2 - reloc01)
BASE_RELOC_SIZE_OF_BLOCK0 equ $ - block_start0

DIRECTORY_ENTRY_BASERELOC_SIZE  equ $ - Directory_Entry_Basereloc
align FILEALIGN, db 0
SIZEOFIMAGE equ $ - IMAGEBASE
Section0Size equ $ - Section0Start