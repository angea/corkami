; complete Hello World PE example, as if compiled via MASM, including RichHeader, dos stubs, alignments...

%include '..\consts.asm'
%define iround(n, r) (((n + (r - 1)) / r) * r)

org IMAGEBASE

SECTIONALIGN EQU 200h 
FILEALIGN EQU SECTIONALIGN ; MakePE limitation

DOS_HEADER:
    .e_magic       dw 'MZ'
    .e_cblp        dw 090h
    .e_cp          dw 3
    .e_crlc        dw 0
    .e_cparhdr     dw (dos_stub - DOS_HEADER) >> 4 ; defines MZ stub entry point
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
    .e_oemid       dw 0
    .e_oeminfo     dw 0
    .e_res2        times 10 dw 0
        align 03ch, db 0    ; in case we change things in DOS_HEADER
    .e_lfanew      dd NT_SIGNATURE - IMAGEBASE ; CRITICAL

align 010h, db 0
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
;    db 'Win32 EXE!',7,0dh,0ah,'$'

align 16, db 0
RichHeader:
RichKey EQU 092033d19h
dd "DanS" ^ RichKey     , 0 ^ RichKey, 0 ^ RichKey       , 0 ^ RichKey
dd 0131f8eh ^ RichKey   , 7 ^ RichKey, 01220fch ^ RichKey, 1 ^ RichKey
dd "Rich", 0 ^ RichKey  , 0, 0
align 16, db 0

NT_SIGNATURE:
    db 'PE',0,0

FILE_HEADER:
    .Machine                dw IMAGE_FILE_MACHINE_I386
    .NumberOfSections       dw NUMBEROFSECTIONS
    .TimeDateStamp          dd 04b51f504h       ; 2010/1/16 5:19pm
    .PointerToSymbolTable   dd 0
    .NumberOfSymbols        dd 0
    .SizeOfOptionalHeader   dw SIZEOFOPTIONALHEADER
    .Characteristics        dw IMAGE_FILE_RELOCS_STRIPPED | IMAGE_FILE_EXECUTABLE_IMAGE| IMAGE_FILE_LINE_NUMS_STRIPPED | IMAGE_FILE_LOCAL_SYMS_STRIPPED | IMAGE_FILE_32BIT_MACHINE

OPTIONAL_HEADER:
    .Magic                          dw IMAGE_NT_OPTIONAL_HDR32_MAGIC
    .MajorLinkerVersion             db 05h
    .MinorLinkerVersion             db 0ch
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
    .Subsystem                      dw IMAGE_SUBSYSTEM_WINDOWS_GUI
    .DllCharacteristics             dw 0
    .SizeOfStackReserve             dd 100000H
    .SizeOfStackCommit              dd 1000H
    .SizeOfHeapReserve              dd 100000H
    .SizeOfHeapCommit               dd 1000H
    .LoaderFlags                    dd 0
    .NumberOfRvaAndSizes            dd NUMBEROFRVAANDSIZES

DATA_DIRECTORY:
    .DIRECTORY_ENTRY_EXPORT         dd 0,0
    .DIRECTORY_ENTRY_IMPORT         dd IMPORT_DESCRIPTOR - IMAGEBASE, DIRECTORY_ENTRY_IMPORT_SIZE
    .DIRECTORY_ENTRY_RESOURCE       dd 0,0
    .DIRECTORY_ENTRY_EXCEPTION      dd 0,0
    .DIRECTORY_ENTRY_SECURITY       dd 0,0
    .DIRECTORY_ENTRY_BASERELOC      dd 0,0
    .DIRECTORY_ENTRY_DEBUG          dd 0,0
    .DIRECTORY_ENTRY_COPYRIGHT      dd 0,0
    .DIRECTORY_ENTRY_GLOBALPTR      dd 0,0
    .DIRECTORY_ENTRY_TLS            dd 0,0
    .DIRECTORY_ENTRY_LOAD_CONFIG    dd 0,0
    .DIRECTORY_ENTRY_BOUND_IMPORT   dd 0,0
    .DIRECTORY_ENTRY_IAT            dd ImportAddressTable - IMAGEBASE, IAT_size
    .DIRECTORY_ENTRY_DELAY_IMPORT   dd 0,0
    .DIRECTORY_ENTRY_COM_DESCRIPTOR dd 0,0
    .DIRECTORY_ENTRY_RESERVED       dd 0,0
NUMBEROFRVAANDSIZES EQU ($ - DATA_DIRECTORY) / 8
SIZEOFOPTIONALHEADER EQU $ - OPTIONAL_HEADER

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
    .Characteristics        dd IMAGE_SCN_CNT_CODE | IMAGE_SCN_CNT_INITIALIZED_DATA | IMAGE_SCN_CNT_UNINITIALIZED_DATA | IMAGE_SCN_MEM_EXECUTE | IMAGE_SCN_MEM_READ


SECTION_1:
    .Name                   db '.rdata'
        times 8 - ($ - .Name) db (0)
    .VirtualSize            dd Section1Size
    .VirtualAddress         dd Section1Start - IMAGEBASE
    .SizeOfRawData          dd iround(Section1Size, FILEALIGN)
    .PointerToRawData       dd Section1Start - IMAGEBASE
    .PointerToRelocations   dd 0
    .PointerToLinenumbers   dd 0
    .NumberOfRelocations    dw 0
    .NumberOfLinenumbers    dw 0
    .Characteristics        dd IMAGE_SCN_CNT_INITIALIZED_DATA | IMAGE_SCN_MEM_READ

SECTION_2:
    .Name                   db '.data'
        times 8 - ($ - .Name) db (0)
    .VirtualSize            dd Section2Size
    .VirtualAddress         dd Section2Start - IMAGEBASE
    .SizeOfRawData          dd iround(Section2Size, FILEALIGN)
    .PointerToRawData       dd Section2Start - IMAGEBASE
    .PointerToRelocations   dd 0
    .PointerToLinenumbers   dd 0
    .NumberOfRelocations    dw 0
    .NumberOfLinenumbers    dw 0
    .Characteristics        dd IMAGE_SCN_CNT_INITIALIZED_DATA | IMAGE_SCN_MEM_READ | IMAGE_SCN_MEM_WRITE

NUMBEROFSECTIONS EQU ($ - SECTION_HEADER) / 0x28

ALIGN FILEALIGN, db 0
SIZEOFHEADERS EQU $ - IMAGEBASE

Section0Start:

bits 32
base_of_code:

EntryPoint
    push MB_ICONINFORMATION ; UINT uType
    push tada               ; LPCTSTR lpCaption
    push helloworld         ; LPCTSTR lpText
    push 0                  ; HWND hWnd
    call MessageBoxA
    push 0                  ; UINT uExitCode
    Call ExitProcess

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess

Section0Size EQU $ - Section0Start

align FILEALIGN,db 0
SIZEOFCODE equ $ - base_of_code

Section1Start:
base_of_data:
;%IMPORTS

Section1Size EQU $ - Section1Start

align FILEALIGN,db 0

Section2Start:
tada db "Tada!", 0
helloworld db "Hello World!", 0
Section2Size EQU $ - Section2Start

ALIGN FILEALIGN,db 0
SIZEOFINITIALIZEDDATA equ $ - base_of_data
uninit_data:
SIZEOFUNINITIALIZEDDATA equ $ - uninit_data

SIZEOFIMAGE EQU $ - IMAGEBASE
