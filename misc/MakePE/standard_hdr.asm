;standard header, with dos header and stub, big alignment, complete directory

%include 'consts.asm'
%define iround(n, r) (((n + (r - 1)) / r) * r)

org IMAGEBASE

SECTIONALIGN EQU 200h ; doesn't work yet with bigger alignment than filealignment 1000h
FILEALIGN EQU 200h

DOS_HEADER:
.e_magic       dw 'MZ'
.e_cblp        dw 090h
.e_cp          dw 3
.e_crlc        dw 0
.e_cparhdr     dw DOS_PARAGRAPH ; defines MZ stub entry point
.e_minalloc    dw 0
.e_maxalloc    dw 0ffffh
.e_ss          dw 0
.e_sp          dw 0b8h
.e_csum        dw 0
.e_ip          dw 0
.e_cs          dw 0
.e_lfarlc      dw 040h
.e_ovno        dw 0
.e_res         dw 0,0,0,0
e_oemid        dw 0
e_oeminfo      dw 0
e_res2         times 10 dw 0
.e_lfanew      dd NT_SIGNATURE - IMAGEBASE ; CRITICAL

align 010h, db 0
DOS_PARAGRAPH EQU ($ - IMAGEBASE) >> 4
dos_stub:
bits 16
    push    cs
    pop     ds
    mov     dx, dos_msg - dos_stub
    mov     ah, 9
    int     21h
    mov     ax, 4c01h
    int     21h
dos_msg
    db 'This program cannot be run in DOS mode.', 0dh, 0dh, 0ah, '$'
;    db 'Win32 EXE!',7,0dh,0ah,'$'  ; other standard string

align 010h, db 0

NT_SIGNATURE:
    db 'PE',0,0

FILE_HEADER:
.Machine                dw IMAGE_FILE_MACHINE_I386
.NumberOfSections       dw NUMBEROFSECTIONS
.TimeDateStamp          dd 0
.PointerToSymbolTable   dd 0
.NumberOfSymbols        dd 0
.SizeOfOptionalHeader   dw SIZEOFOPTIONALHEADER
.Characteristics        dw CHARACTERISTICS

OPTIONAL_HEADER:
.Magic                          dw IMAGE_NT_OPTIONAL_HDR32_MAGIC
.MajorLinkerVersion             db 0
.MinorLinkerVersion             db 0
.SizeOfCode                     dd SIZEOFCODE
.SizeOfInitializedData          dd SIZEOFINITIALIZEDDATA
.SizeOfUninitializedData        dd SIZEOFUNINITIALIZEDDATA
.AddressOfEntryPoint            dd EntryPoint - IMAGEBASE
.BaseOfCode                     dd base_of_code - IMAGEBASE
.BaseOfData                     dd base_of_data - IMAGEBASE
.ImageBase                      dd IMAGEBASE
.SectionAlignment               dd SECTIONALIGN
.FileAlignment                  dd FILEALIGN
.MajorOperatingSystemVersion    dw 04h
.MinorOperatingSystemVersion    dw 0
.MajorImageVersion              dw 0
.MinorImageVersion              dw 0
.MajorSubsystemVersion          dw 4
.MinorSubsystemVersion          dw 0
.Win32VersionValue              dd 0
.SizeOfImage                    dd SIZEOFIMAGE
.SizeOfHeaders                  dd SIZEOFHEADERS
.CheckSum                       dd 0
.Subsystem                      dw SUBSYSTEM
.DllCharacteristics             dw 0
.SizeOfStackReserve             dd 100000H
.SizeOfStackCommit              dd 1000H
.SizeOfHeapReserve              dd 100000H
.SizeOfHeapCommit               dd 1000H
.LoaderFlags                    dd 0
.NumberOfRvaAndSizes            dd NUMBEROFRVAANDSIZES

DATA_DIRECTORY:
.DIRECTORY_ENTRY_EXPORT         dd Exports_Directory - IMAGEBASE, DIRECTORY_ENTRY_EXPORT_SIZE
.DIRECTORY_ENTRY_IMPORT         dd IMPORT_DESCRIPTOR - IMAGEBASE, DIRECTORY_ENTRY_IMPORT_SIZE
.DIRECTORY_ENTRY_RESOURCE       dd Directory_Entry_Resource - IMAGEBASE, DIRECTORY_ENTRY_RESOURCE_SIZE
.DIRECTORY_ENTRY_EXCEPTION      dd 0,0
.DIRECTORY_ENTRY_SECURITY       dd 0,0
.DIRECTORY_ENTRY_BASERELOC      dd Directory_Entry_Basereloc - IMAGEBASE, DIRECTORY_ENTRY_BASERELOC_SIZE
.DIRECTORY_ENTRY_DEBUG          dd 0,0
.DIRECTORY_ENTRY_COPYRIGHT      dd 0,0
.DIRECTORY_ENTRY_GLOBALPTR      dd 0,0
.DIRECTORY_ENTRY_TLS            dd Image_Tls_Directory32 - IMAGEBASE, DIRECTORY_ENTRY_TLS_SIZE
.DIRECTORY_ENTRY_LOAD_CONFIG    dd 0,0
.DIRECTORY_ENTRY_BOUND_IMPORT   dd 0,0
.DIRECTORY_ENTRY_IAT            dd 0, DIRECTORY_ENTRY_IAT_SIZE
.DIRECTORY_ENTRY_DELAY_IMPORT   dd Image_Delay_Import_Directory32 - IMAGEBASE,0
.DIRECTORY_ENTRY_COM_DESCRIPTOR dd 0,0
.DIRECTORY_ENTRY_RESERVED       dd 0,0
NUMBEROFRVAANDSIZES EQU ($ - DATA_DIRECTORY) / 8
SIZEOFOPTIONALHEADER EQU $ - OPTIONAL_HEADER

; DIRECTORY_ENTRY_DEBUG Size should be small, like 0x1000 or less
; Independantly of NumberOfRvaAndSizes. thus, Dword at DATA_DIRECTORY + 34h

SECTION_HEADER:
SECTION_0:
    .Name                   db '.text'
        times 8 - ($ - .Name) db (0)
    .VirtualSize            dd Section0Size
    .VirtualAddress         dd Section0Start - IMAGEBASE
    .SizeOfRawData          dd iround(Section0Size, FILEALIGN)
    .PointerToRawData       dd Section0Start - IMAGEBASE
    .PointerToRelocations   dd 0
    .PointerToLinenumbers   dd 0
    .NumberOfRelocations    dw 0
    .NumberOfLinenumbers    dw 0
    .Characteristics        dd IMAGE_SCN_CNT_CODE | IMAGE_SCN_CNT_INITIALIZED_DATA | IMAGE_SCN_CNT_UNINITIALIZED_DATA | IMAGE_SCN_MEM_EXECUTE | IMAGE_SCN_MEM_READ | IMAGE_SCN_MEM_WRITE

NUMBEROFSECTIONS EQU ($ - SECTION_HEADER) / 0x28

ALIGN FILEALIGN, db 0
SIZEOFHEADERS EQU $ - IMAGEBASE

Section0Start:

base_of_code:
bits 32
