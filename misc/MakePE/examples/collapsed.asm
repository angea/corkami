; this is a our Hello World where all legitimate structures have been inserted in the holes
; of unused data of the PE format, similar to the flexible header example
; some space is still left unused, filled with stupid strings

%include '..\consts.asm'
%define iround(n, r) (((n + (r - 1)) / r) * r)

org IMAGEBASE

SECTIONALIGN EQU 1 ; doesn't work yet with bigger alignment than filealignment 1000h
FILEALIGN EQU 1

DOS_HEADER:
EntryPoint:
e_magic       dw 'MZ'   ; will decode as dec ebp, pop edx
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
bits 32
    push MB_ICONINFORMATION ; UINT uType
    push tada               ; LPCTSTR lpCaption
    push helloworld         ; LPCTSTR lpText
    push 0                  ; HWND hWnd
    call MessageBoxA
    push 0                  ; UINT uExitCode
    Call ExitProcess
tada db "Tada!", 0
helloworld db "Hello World!", 0

align 2, db 0
user32.dll_THUNK:
__imp__MessageBoxA:
.AddressOfData
    DD iMessageBoxA - IMAGEBASE
    DD 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    times 29 * 2 + 2 - ($ - e_magic) db (0) ; 58 bytes gap
.e_lfanew      dd NT_SIGNATURE - IMAGEBASE ; CRITICAL


align 04h, db 0

NT_SIGNATURE:
    db 'PE',0,0

FILE_HEADER:
.Machine                dw IMAGE_FILE_MACHINE_I386
NumberOfSections       dw NUMBEROFSECTIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
align 2, db 0
user32.dll  DB 'user32.dll',0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    times 3 * 4 + 2 - ($ - NumberOfSections) db (0) ; 12 bytes gap
.SizeOfOptionalHeader   dw SIZEOFOPTIONALHEADER
.Characteristics        dw IMAGE_FILE_RELOCS_STRIPPED | IMAGE_FILE_EXECUTABLE_IMAGE| IMAGE_FILE_LINE_NUMS_STRIPPED | IMAGE_FILE_LOCAL_SYMS_STRIPPED | IMAGE_FILE_32BIT_MACHINE

OPTIONAL_HEADER:
.Magic                          dw IMAGE_NT_OPTIONAL_HDR32_MAGIC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
align 2, db 0
kernel32.dll  DB 'kernel32.dll',0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    times 3 * 4 + 2 + 2 - ($ - OPTIONAL_HEADER) db (0) ; 14 bytes gap
.AddressOfEntryPoint            dd EntryPoint - IMAGEBASE
    times 2 * 4 + 4 - ($ - .AddressOfEntryPoint) db (0); 8 bytes gap
.ImageBase                      dd IMAGEBASE
.SectionAlignment               dd SECTIONALIGN
.FileAlignment                  dd FILEALIGN
    times 2 * 4 + 4 - ($ - .FileAlignment) db (0) ; 8 bytes gap
_MajorSubsystemVersion          dw 4
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MessageBoxA:
    jmp [__imp__MessageBoxA]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    times 2 + 4 + 2 - ($ - _MajorSubsystemVersion) db (0) ; 6 bytes gap
.SizeOfImage                    dd SIZEOFIMAGE
.SizeOfHeaders                  dd SIZEOFHEADERS
    times 4 + 4 - ($ - .SizeOfHeaders) db (0) ; 4 bytes gap
_Subsystem                      dw IMAGE_SUBSYSTEM_WINDOWS_GUI
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ExitProcess:
    jmp [__imp__ExitProcess]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    times 2 + 4 + 2 - ($ - _Subsystem) db (0) ; 6 bytes gap
.SizeOfStackCommit              dd 0; can't be any value
.SizeOfHeapReserve              dd 0; can't be any value
.SizeOfHeapCommit               dd 0; can't be any value
    times 4 + 4 - ($ - .SizeOfHeapCommit) db (0) ; 4 bytes gap
.NumberOfRvaAndSizes            dd NUMBEROFRVAANDSIZES

DATA_DIRECTORY:
    times 2 * 4 - ( $ - DATA_DIRECTORY) db (0)
DIRECTORY_ENTRY_IMPORT.RVA  dd IMPORT_DESCRIPTOR - IMAGEBASE
    dd 0
DIRECTORY_ENTRY_RESOURCE.RVA dd 0 ; can't be any value


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
align 2, db 0
iExitProcess:
    DW 0
    DB 'ExitProcess',0
align 2, db 0
iMessageBoxA:
    DW 0
    DB 'MessageBoxA',0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    times 6 * 4 * 2 + 4 - ($ - DATA_DIRECTORY) db (0)
DIRECTORY_ENTRY_DEBUG_Size dd 0 ; can't be any value

NUMBEROFRVAANDSIZES EQU ($ - DATA_DIRECTORY) / 8
SIZEOFOPTIONALHEADER EQU $ - OPTIONAL_HEADER

; DIRECTORY_ENTRY_DEBUG Size should be small, like 0x1000 or less
; Independantly of NumberOfRvaAndSizes. thus, Dword at DATA_DIRECTORY + 34h

SECTION_HEADER:
SECTION_0:
    SECTION_0_Name
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
align 2, db 0
kernel32.dll_THUNK:
__imp__ExitProcess:
.AddressOfData
    DD iExitProcess - IMAGEBASE
    DD 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            times 8 - ($ - SECTION_0_Name) db (0)
    .VirtualSize            dd Section0Size
    .VirtualAddress         dd Section0Start - IMAGEBASE
    .SizeOfRawData          dd iround(Section0Size, FILEALIGN)
    .PointerToRawData       dd Section0Start - IMAGEBASE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    db 'Eat at Joe', 027h, 's'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        times 2 * 2 + 4 * 2 + 4 - ($ - .PointerToRawData) db (0) ; 12 bytes gap
    .Characteristics        dd IMAGE_SCN_CNT_CODE | IMAGE_SCN_CNT_INITIALIZED_DATA | IMAGE_SCN_CNT_UNINITIALIZED_DATA | IMAGE_SCN_MEM_EXECUTE | IMAGE_SCN_MEM_READ | IMAGE_SCN_MEM_WRITE

NUMBEROFSECTIONS EQU ($ - SECTION_HEADER) / 0x28

ALIGN FILEALIGN, db 0
SIZEOFHEADERS EQU $ - IMAGEBASE

Section0Start:

base_of_code:
bits 32

IMPORT_DESCRIPTOR:
kernel32.dll_DESCRIPTOR:
.OriginalFirstThunk     DD kernel32.dll_THUNK - IMAGEBASE
.TimeDateStamp          DD 0
.ForwarderChain         DD 0FFFFFFFFh
.Name                   DD kernel32.dll - IMAGEBASE
.FirstThunk             DD kernel32.dll_THUNK - IMAGEBASE
user32.dll_DESCRIPTOR:
.OriginalFirstThunk     DD user32.dll_THUNK - IMAGEBASE
.TimeDateStamp          DD 0
.ForwarderChain         DD 0FFFFFFFFh
.Name                   DD user32.dll - IMAGEBASE
.FirstThunk             DD user32.dll_THUNK - IMAGEBASE
EMPTY_DESCRIPTOR:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
db 'plenty of space', 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            times 4 * 4 - ($ - EMPTY_DESCRIPTOR) db (0)
.FirstThunk             DD 0

DIRECTORY_ENTRY_IMPORT_SIZE EQU $ - IMPORT_DESCRIPTOR

SIZEOFCODE equ $ - base_of_code
align FILEALIGN,db 0

Section0Size EQU $ - Section0Start

SIZEOFIMAGE EQU $ - IMAGEBASE

; Ange Albertini, Creative Commons BY, 2009-2010