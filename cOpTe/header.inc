;Ange Albertini, BSD Licence, 2009-2011

%include 'consts.inc'

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
    at IMAGE_OPTIONAL_HEADER32.Subsystem                , dw SUBSYSTEM
    at IMAGE_OPTIONAL_HEADER32.NumberOfRvaAndSizes      , dd NUMBEROFRVAANDSIZES
iend

DataDirectory:
istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ExportsVA,   dd Exports_Directory - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.ImportsVA,   dd IMPORT_DESCRIPTOR - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.ResourceVA,  dd Directory_Entry_Resource - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.FixupsVA,    dd Directory_Entry_Basereloc - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.FixupsSize,  dd DIRECTORY_ENTRY_BASERELOC_SIZE
    at IMAGE_DATA_DIRECTORY_16.TLSVA,       dd Image_Tls_Directory32 - IMAGEBASE
iend

NUMBEROFRVAANDSIZES equ ($ - DataDirectory) / IMAGE_DATA_DIRECTORY_size

SIZEOFOPTIONALHEADER equ $ - OptionalHeader

SectionHeader:
istruc IMAGE_SECTION_HEADER
;    at IMAGE_SECTION_HEADER.VirtualSize, dd SECTION0SIZE
    at IMAGE_SECTION_HEADER.VirtualAddress, dd Section0Start - IMAGEBASE
    at IMAGE_SECTION_HEADER.SizeOfRawData, dd SECTION0SIZE
    at IMAGE_SECTION_HEADER.PointerToRawData, dd Section0Start - IMAGEBASE
    at IMAGE_SECTION_HEADER.Characteristics, dd IMAGE_SCN_MEM_EXECUTE + IMAGE_SCN_MEM_WRITE; necessary under Win7 (with DEP?)
iend
NUMBEROFSECTIONS equ ($ - SectionHeader) / IMAGE_SECTION_HEADER_size

align FILEALIGN, db 0
align 1000h, db 0           ; necessary under Win7 x64
SIZEOFHEADERS equ $ - IMAGEBASE

bits 32
Section0Start:
