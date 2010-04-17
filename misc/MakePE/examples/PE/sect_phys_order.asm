; PE PoC
; sections'header order is not the same as physical order.

%include '..\..\consts.asm'
%define iround(n, r) (((n + (r - 1)) / r) * r)

org IMAGEBASE
_IMAGEBASE equ IMAGEBASE - 1000h
SECTIONALIGN EQU 1000h
FILEALIGN EQU 200h

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
    .DIRECTORY_ENTRY_IMPORT         dd IMPORT_DESCRIPTOR - _IMAGEBASE, DIRECTORY_ENTRY_IMPORT_SIZE
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
    .DIRECTORY_ENTRY_IAT            dd ImportAddressTable - _IMAGEBASE, IAT_size
    .DIRECTORY_ENTRY_DELAY_IMPORT   dd 0,0
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
    .VirtualSize            dd SECTION0VS; iround(SECTION0SIZE, SECTIONALIGN)
    .VirtualAddress         dd Section0Start - IMAGEBASE
    .SizeOfRawData          dd SECTION0SIZE
    .PointerToRawData       dd SECTION0OFFSET
    .PointerToRelocations   dd 0
    .PointerToLinenumbers   dd 0
    .NumberOfRelocations    dw 0
    .NumberOfLinenumbers    dw 0
    .Characteristics        dd IMAGE_SCN_CNT_CODE | IMAGE_SCN_MEM_EXECUTE | IMAGE_SCN_MEM_READ


SECTION_2:
    .Name                   db '.data'
        times 8 - ($ - .Name) db (0)
    .VirtualSize            dd SECTION2VS ; iround(SECTION2SIZE, SECTIONALIGN)
    .VirtualAddress         dd Section1Start - IMAGEBASE                ; changed to keep virtual order correct
    .SizeOfRawData          dd SECTION2SIZE
    .PointerToRawData       dd SECTION2OFFSET
    .PointerToRelocations   dd 0
    .PointerToLinenumbers   dd 0
    .NumberOfRelocations    dw 0
    .NumberOfLinenumbers    dw 0
    .Characteristics        dd IMAGE_SCN_CNT_INITIALIZED_DATA | IMAGE_SCN_MEM_READ | IMAGE_SCN_MEM_WRITE

SECTION_1:
    .Name                   db '.rdata'
        times 8 - ($ - .Name) db (0)
    .VirtualSize            dd SECTION1VS ; iround(SECTION1SIZE, SECTIONALIGN)
    .VirtualAddress         dd Section2Start - IMAGEBASE                ; same
    .SizeOfRawData          dd SECTION1SIZE
    .PointerToRawData       dd SECTION1OFFSET
    .PointerToRelocations   dd 0
    .PointerToLinenumbers   dd 0
    .NumberOfRelocations    dw 0
    .NumberOfLinenumbers    dw 0
    .Characteristics        dd IMAGE_SCN_CNT_INITIALIZED_DATA | IMAGE_SCN_MEM_READ


NUMBEROFSECTIONS EQU ($ - SECTION_HEADER) / 0x28


ALIGN FILEALIGN, db 0
SIZEOFHEADERS EQU $ - IMAGEBASE

SECTION0OFFSET EQU $ - IMAGEBASE

SECTION code valign = SECTIONALIGN
Section0Start:

bits 32
base_of_code:

EntryPoint:
    push MB_ICONINFORMATION ; UINT uType
    push tada - 1000h       ; LPCTSTR lpCaption
    push helloworld - 1000h ; LPCTSTR lpText
    push 0                  ; HWND hWnd
    call MessageBoxA
    push 0                  ; UINT uExitCode
    Call ExitProcess

MessageBoxA:
    jmp [__imp__MessageBoxA + 1000h]
ExitProcess:
    jmp [__imp__ExitProcess + 1000h]
SECTION0VS equ $ - Section0Start
align FILEALIGN,db 0
SECTION0SIZE EQU $ - Section0Start
SIZEOFCODE equ $ - base_of_code

SECTION1OFFSET equ $ - Section0Start + SECTION0OFFSET
SECTION idata valign = SECTIONALIGN
Section1Start:
base_of_data:

ImportAddressTable:
;align 2, db 0
kernel32.dll_iat:

__imp__ExitProcess:
    DD hnExitProcess - _IMAGEBASE         ; ForwarderString / Function / Ordinal / AddressOfData
    DD 0

;align 2, db 0
user32.dll_iat:

__imp__MessageBoxA:
    DD hnMessageBoxA - _IMAGEBASE         ; ForwarderString / Function / Ordinal / AddressOfData
    DD 0

IAT_size equ $ - ImportAddressTable
IMPORT_DESCRIPTOR: ; replace with imports:
kernel32.dll_DESCRIPTOR:
    dd kernel32.dll_hintnames - _IMAGEBASE    ; OriginalFirstThunk/Characteristics, IMAGE_IMPORT_BY_NAME array
    dd 0                                ; TimeDateStamp
    dd 0                                ; ForwarderChain
    dd kernel32.dll - _IMAGEBASE              ; Name
    dd kernel32.dll_iat - _IMAGEBASE          ; FirstThunk


user32.dll_DESCRIPTOR:
    dd user32.dll_hintnames - _IMAGEBASE    ; OriginalFirstThunk/Characteristics, IMAGE_IMPORT_BY_NAME array
    dd 0                                ; TimeDateStamp
    dd 0                                ; ForwarderChain
    dd user32.dll - _IMAGEBASE              ; Name
    dd user32.dll_iat - _IMAGEBASE          ; FirstThunk


    times 5 dd 0

HintNames:
;align 2, db 0
kernel32.dll_hintnames:

    DD hnExitProcess - _IMAGEBASE         ; ForwarderString / Function / Ordinal / AddressOfData

    DD 0

;align 2, db 0
user32.dll_hintnames:

    DD hnMessageBoxA - _IMAGEBASE         ; ForwarderString / Function / Ordinal / AddressOfData

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


SECTION1VS equ $ - Section1Start

align FILEALIGN,db 0

SECTION1SIZE EQU $ - Section1Start
SECTION2OFFSET equ $ - Section1Start + SECTION1OFFSET
SECTION data valign = SECTIONALIGN

Section2Start:
tada db "Tada!", 0
helloworld db "Hello World!", 0
SECTION2VS equ $ - Section2Start

ALIGN FILEALIGN,db 0
SECTION2SIZE EQU $ - Section2Start
;SIZEOFINITIALIZEDDATA equ $ - base_of_data ; too complex
SIZEOFINITIALIZEDDATA equ SECTION2SIZE + SECTION1SIZE
uninit_data:
SIZEOFUNINITIALIZEDDATA equ $ - uninit_data

SIZEOFIMAGE EQU $ - IMAGEBASE


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

; should be must simpler,
; but sadly it goes beyond makepe limitations, 
; so it breaks its usual simplicity

;Ange Albertini, Creative Commons BY, 2010
