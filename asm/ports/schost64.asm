;simple 64b shellcode host

; PE structures ************************************************************************************

%include '..\consts.inc'

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
    at IMAGE_FILE_HEADER.Machine,               dw IMAGE_FILE_MACHINE_AMD64
    at IMAGE_FILE_HEADER.NumberOfSections,      dw NUMBEROFSECTIONS
    at IMAGE_FILE_HEADER.SizeOfOptionalHeader,  dw SIZEOFOPTIONALHEADER
    at IMAGE_FILE_HEADER.Characteristics,       dw CHARACTERISTICS
iend

OptionalHeader:
istruc IMAGE_OPTIONAL_HEADER64
    at IMAGE_OPTIONAL_HEADER64.Magic                    , dw IMAGE_NT_OPTIONAL_HDR64_MAGIC
    at IMAGE_OPTIONAL_HEADER64.AddressOfEntryPoint      , dd EntryPoint - IMAGEBASE
    at IMAGE_OPTIONAL_HEADER64.ImageBase                , dd IMAGEBASE
    at IMAGE_OPTIONAL_HEADER64.SectionAlignment         , dd SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER64.FileAlignment            , dd FILEALIGN
    at IMAGE_OPTIONAL_HEADER64.MajorSubsystemVersion    , dw 4
    at IMAGE_OPTIONAL_HEADER64.SizeOfImage              , dd SIZEOFIMAGE
    at IMAGE_OPTIONAL_HEADER64.SizeOfHeaders            , dd SIZEOFHEADERS  ; can be 0 in some circumstances
    at IMAGE_OPTIONAL_HEADER64.Subsystem                , dw IMAGE_SUBSYSTEM_WINDOWS_GUI
    at IMAGE_OPTIONAL_HEADER64.NumberOfRvaAndSizes      , dd NUMBEROFRVAANDSIZES
iend

DataDirectory:
istruc IMAGE_DATA_DIRECTORY_16
iend

NUMBEROFRVAANDSIZES equ ($ - DataDirectory) / IMAGE_DATA_DIRECTORY_size

SIZEOFOPTIONALHEADER equ $ - OptionalHeader

SectionHeader:
istruc IMAGE_SECTION_HEADER
;    at IMAGE_SECTION_HEADER.VirtualSize, dd SECTION0SIZE
    at IMAGE_SECTION_HEADER.VirtualAddress, dd Section0Start - IMAGEBASE
    at IMAGE_SECTION_HEADER.SizeOfRawData, dd SECTION0SIZE
    at IMAGE_SECTION_HEADER.PointerToRawData, dd Section0Start - IMAGEBASE
    at IMAGE_SECTION_HEADER.Characteristics, dd IMAGE_SCN_MEM_EXECUTE ; necessary under Win7 (with DEP?)
iend
NUMBEROFSECTIONS equ ($ - SectionHeader) / IMAGE_SECTION_HEADER_size

align FILEALIGN, db 0
align 1000h, db 0           ; necessary under Win7 x64
SIZEOFHEADERS equ $ - IMAGEBASE

Section0Start:
EntryPoint:

incbin 'mcdermott64.bin'

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE

;Ange Albertini, Creative Commons BY, 2009-2010
