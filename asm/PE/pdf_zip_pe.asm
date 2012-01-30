; a PE that contains a PDF and a ZIP containing the same PDF
; the file fully works as a PDF document, a PE executable, and a ZIP archive, without any modification
; (the PDF is acrobat reader-only compatible)

; ie, file formats starting beyond offset 0 are a bad idea

;Ange Albertini, BSD Licence, 2012

%include 'consts.inc'

IMAGEBASE equ 400000h
org IMAGEBASE

db 'MZ'

align 32h, db 0 ; so that ZIP's LASTMOD overlaps PE's e_lfanew

; ZIP start ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CRC32_ equ 0c50d7871h
LASTMOD equ NT_Signature - IMAGEBASE

%macro __filename 0
db 'pdf_zip_pe.pdf'
%endmacro

header:
    db 'PK', 3, 4

    dw 0ah ; version_needed
    general_flags dw 0
    dw 0 ; compression
    dd LASTMOD ; last_mod time, date
    dd CRC32_ ; crc32
    dd FILESIZE ; compressed size
    dd FILESIZE ; uncompressed size
    dw FILENAMELEN
    dw 0 ; extra_length
    filename:
        __filename
    FILENAMELEN equ $ - filename
    data:
; PDF ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        incbin 'pdf_zip_pe.pdf'
    FILESIZE equ $ - data

central_directory:
    db 'PK', 1, 2
    version_made_by dw 014h
    dw 0ah ; version_needed
    dw 0 ; flags
    dw 0 ; compression
    dd LASTMOD ; last_mod time/date
    dd CRC32_ ; crc32
    compressed_size dd FILESIZE
    uncompressed_size dd FILESIZE
    dw FILENAMELEN
    dw 0 ; extra_length
    dw 0 ; comment_length
    disk_number_start dw 0
    internal_attr dw 0
    external_attr dd 20h
    offset_header dd 0

    __filename

end_central_directory:
    db 'PK', 5, 6
    number_disk dw 0
    number_disk2 dw 0
    total_number_disk dw 1
    total_number_disk2 dw 1
    dd end_central_directory - central_directory;size
    dd central_directory - header ;offset
    dw 0 ; comment_length

; PE resumes here ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

NT_Signature:
istruc IMAGE_NT_HEADERS
    at IMAGE_NT_HEADERS.Signature, db 'PE',0,0
iend
istruc IMAGE_FILE_HEADER
    at IMAGE_FILE_HEADER.Machine,               dw IMAGE_FILE_MACHINE_I386
    at IMAGE_FILE_HEADER.Characteristics,       dw IMAGE_FILE_EXECUTABLE_IMAGE | IMAGE_FILE_32BIT_MACHINE
iend

istruc IMAGE_OPTIONAL_HEADER32
    at IMAGE_OPTIONAL_HEADER32.Magic,                     dw IMAGE_NT_OPTIONAL_HDR32_MAGIC
    at IMAGE_OPTIONAL_HEADER32.AddressOfEntryPoint,       dd EntryPoint - IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.ImageBase,                 dd IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.SectionAlignment,          dd 4      ; also sets e_lfanew
    at IMAGE_OPTIONAL_HEADER32.FileAlignment,             dd 4
    at IMAGE_OPTIONAL_HEADER32.MajorSubsystemVersion,     dw 4
    at IMAGE_OPTIONAL_HEADER32.SizeOfImage,               dd SIZEOFIMAGE
    at IMAGE_OPTIONAL_HEADER32.SizeOfHeaders,             dd SIZEOFIMAGE - 1 ; 2ch <= SIZEOFHEADERS < SIZEOFIMAGE
    at IMAGE_OPTIONAL_HEADER32.Subsystem,                 db IMAGE_SUBSYSTEM_WINDOWS_CUI
    at IMAGE_OPTIONAL_HEADER32.NumberOfRvaAndSizes,       dd 16
iend

istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA, dd Import_Descriptor - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.IATVA,     dd ImportsAddressTable - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.IATSize,   dd IMPORTSADDRESSTABLESIZE
iend

bits 32
EntryPoint:
    push 1
    push zipfile
    push thisfile
    call [__imp__CopyFile]
    push 0
    push 0
    push 0
    push zipfile
    push 0
    push 0
    call [__imp__ShellExecute]
    push 1
    push pdffile
    push thisfile
    call [__imp__CopyFile]
    push 0
    push 0
    push 0
    push pdffile
    push 0
    push 0
    call [__imp__ShellExecute]
    retn
thisfile db 'pdf_zip_pe.exe', 0
zipfile  db 'pdf_zip_pe.zip', 0
pdffile  db 'pdf_zip_pe.pdf', 0

Import_Descriptor:
;shell32.dll_DESCRIPTOR
    dd shell32.dll_hintnames - IMAGEBASE
    dd 0, 0
    dd shell32.dll - IMAGEBASE
    dd shell32.dll_iat - IMAGEBASE
;kernel32.dll_DESCRIPTOR
    dd kernel32.dll_hintnames - IMAGEBASE
    dd 0, 0
    dd kernel32.dll - IMAGEBASE
    dd kernel32.dll_iat - IMAGEBASE
;terminator
    dd 0, 0, 0, 0, 0

hnShellExecute:
    dw 0
    db 'ShellExecuteA', 0
hnCopyFile:
    dw 0
    db 'CopyFileA', 0
_d

ImportsAddressTable:
shell32.dll_iat:
__imp__ShellExecute:
    dd hnShellExecute - IMAGEBASE
    dd 0
kernel32.dll_iat:
__imp__CopyFile:
    dd hnCopyFile - IMAGEBASE
    dd 0
_d

shell32.dll_hintnames:
    dd hnShellExecute - IMAGEBASE
    dd 0
kernel32.dll_hintnames:
    dd hnCopyFile - IMAGEBASE
    dd 0
_d

IMPORTSADDRESSTABLESIZE equ $ - ImportsAddressTable

shell32.dll  db 'shell32.dll',0
kernel32.dll db 'kernel32.dll',0
_d

SIZEOFIMAGE equ $ - IMAGEBASE
