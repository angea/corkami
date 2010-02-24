; section-less PE file

%include '..\..\consts.asm'

org IMAGEBASE

SECTIONALIGN EQU 4 ; <= 800h for a section-less file.
FILEALIGN EQU SECTIONALIGN ; MakePE limitation

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
;    at IMAGE_FILE_HEADER.NumberOfSections,      dw NUMBEROFSECTIONS     ; we don't need you today
;    at IMAGE_FILE_HEADER.SizeOfOptionalHeader,  dw SIZEOFOPTIONALHEADER ; you neither
    at IMAGE_FILE_HEADER.Characteristics,       dw IMAGE_FILE_RELOCS_STRIPPED | IMAGE_FILE_EXECUTABLE_IMAGE | \
        IMAGE_FILE_LINE_NUMS_STRIPPED | IMAGE_FILE_LOCAL_SYMS_STRIPPED | IMAGE_FILE_32BIT_MACHINE
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
    at IMAGE_OPTIONAL_HEADER32.SizeOfHeaders            , dd SIZEOFHEADERS
    at IMAGE_OPTIONAL_HEADER32.Subsystem                , dw IMAGE_SUBSYSTEM_WINDOWS_GUI
    at IMAGE_OPTIONAL_HEADER32.NumberOfRvaAndSizes      , dd NUMBEROFRVAANDSIZES
iend

DataDirectory:
istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA, dd IMPORT_DESCRIPTOR - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.IATVA,     dd ImportsAddressTable - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.IATSize,   dd IMPORTSADDRESSTABLESIZE
iend

NUMBEROFRVAANDSIZES equ ($ - DataDirectory) / IMAGE_DATA_DIRECTORY_size
SIZEOFOPTIONALHEADER equ $ - OptionalHeader
SIZEOFHEADERS EQU $ - IMAGEBASE

bits 32
EntryPoint:
    push MB_ICONINFORMATION ; UINT uType
    push tada               ; LPCTSTR lpCaption
    push helloworld         ; LPCTSTR lpText
    push 0                  ; HWND hWnd
    call MessageBoxA
    push 0                  ; UINT uExitCode
    call ExitProcess
;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess

tada db "Tada!", 0
helloworld db "Hello World!", 0

ImportsAddressTable:
;%IMPORTS
IMPORTSADDRESSTABLESIZE equ $ - ImportsAddressTable

SIZEOFIMAGE equ $ - IMAGEBASE

;Ange Albertini, Creative Commons BY, 2010