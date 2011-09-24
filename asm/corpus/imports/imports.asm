; dll imports loader

;TODO:
; forwarding
; auto-forwarding
; multiple names with different hints
; export names: 
;  split in one exports with null name, one export with 010000h long name, exportname starting like known API
; try to mimick kernel32 ?

; load by ascii, unicode, extensionless, mixedcase


; Ange Albertini, BSD LICENCE 2009-2011

%include '..\..\consts.inc'
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
    at IMAGE_FILE_HEADER.Characteristics,       dw IMAGE_FILE_EXECUTABLE_IMAGE | IMAGE_FILE_32BIT_MACHINE
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
    at IMAGE_DATA_DIRECTORY_16.ImportsVA,   dd VDELTA + Import_Descriptor - IMAGEBASE
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
    push VDELTA + helloworld
    call printf
    add esp, 1 * 4

    push VDELTA + loading
    call printf
    add esp, 1 * 4
    push VDELTA + dll.dll
    call LoadLibraryA
    push eax
    call FreeLibrary

    push VDELTA + loadingunicode
    call printf
    add esp, 1 * 4
    push VDELTA + dllU
    call LoadLibraryW
    push eax
    call FreeLibrary

    push VDELTA + loadingnoextension
    call printf
    add esp, 1 * 4
    push VDELTA + dll
    call LoadLibraryA
    push eax
    call FreeLibrary

    call [VDELTA + __imp__dllexport]
    push 0
    call ExitProcess
_c

LoadLibraryA:
    jmp [VDELTA + __imp__LoadLibraryA]
_c
LoadLibraryW:
    jmp [VDELTA + __imp__LoadLibraryW]
_c
FreeLibrary:
    jmp [VDELTA + __imp__FreeLibrary]
_c
ExitProcess:
    jmp [VDELTA + __imp__ExitProcess]
_c

printf:
    jmp [VDELTA + __imp__printf]
_c

helloworld db "Imports loader", 0ah, 0
loading db 'loading dll:', 0
loadingnoextension db 'loading DLL without extension:', 0
loadingunicode db 'loading dll via unicode:', 0
_d

Import_Descriptor:
kernel32.dll_DESCRIPTOR:
    dd VDELTA + kernel32.dll_hintnames - IMAGEBASE
    dd 0, 0
    dd VDELTA + kernel32.dll - IMAGEBASE
    dd VDELTA + kernel32.dll_iat - IMAGEBASE
msvcrt.dll_DESCRIPTOR:
    dd VDELTA + msvcrt.dll_hintnames - IMAGEBASE
    dd 0, 0
    dd VDELTA + msvcrt.dll - IMAGEBASE
    dd VDELTA + msvcrt.dll_iat - IMAGEBASE
dll.dll_DESCRIPTOR:
    dd VDELTA + dll.dll_hintnames - IMAGEBASE
    dd 0, 0
    dd VDELTA + dll.dll - IMAGEBASE
    dd VDELTA + dll.dll_iat - IMAGEBASE
;terminator
    dd 0, 0, 0, 0, 0
_d

kernel32.dll_hintnames:
    DD VDELTA + hnExitProcess - IMAGEBASE
    DD VDELTA + hnLoadLibraryA - IMAGEBASE
    DD VDELTA + hnLoadLibraryW - IMAGEBASE
    DD VDELTA + hnFreeLibrary - IMAGEBASE
    DD 0
msvcrt.dll_hintnames:
    dd VDELTA + hnprintf - IMAGEBASE
    dd 0
dll.dll_hintnames:
    dd VDELTA + hndllexport - IMAGEBASE
    dd 0
_d

hnExitProcess:
    dw 0
    db 'ExitProcess', 0
hnLoadLibraryA:
    dw 0
    db 'LoadLibraryA', 0
hnLoadLibraryW:
    dw 0
    db 'LoadLibraryW', 0
hnFreeLibrary:
    dw 0
    db 'FreeLibrary', 0

hnprintf:
    dw 0
    db 'printf', 0
    
hndllexport:
    dw 0
    times 010000h db 0ffh
        db 0
_d

kernel32.dll_iat:
__imp__ExitProcess:
    dd VDELTA + hnExitProcess - IMAGEBASE
__imp__LoadLibraryA:
    dd VDELTA + hnLoadLibraryA - IMAGEBASE
__imp__LoadLibraryW:
    dd VDELTA + hnLoadLibraryW - IMAGEBASE
__imp__FreeLibrary:
    dd VDELTA + hnFreeLibrary - IMAGEBASE
    dd 0

msvcrt.dll_iat:
__imp__printf:
    dd VDELTA + hnprintf - IMAGEBASE
    dd 0
dll.dll_iat:
__imp__dllexport:
    dd VDELTA + hndllexport - IMAGEBASE
    dd 0
_d

kernel32.dll db 'kernel32.dll', 0
msvcrt.dll db 'msvcrt.dll', 0
;db 'Export', 0

align 2, db 0
dllU db 'd', 0, 'l', 0, 'l', 0, '.', 0, 'd', 0, 'l', 0, 'l', 0, 0, 0
dll.dll db 'dll.dll', 0
dll db 'dll', 0
_d

align FILEALIGN, db 0

Section0Size EQU $ - Section0Start

SIZEOFIMAGE EQU $ - IMAGEBASE
