; a PE that contains a PDF and a ZIP containing the same PDF
; the file fully works as a PDF document, a PE executable, and a ZIP archive, without any modification
; (the PDF is acrobat reader-only compatible)
; with python on the top of the file
; and html+javascript at the bottom of the file

; ie, file formats starting beyond offset 0 are a bad idea

;Ange Albertini, BSD Licence, 2012

%include 'consts.inc'

IMAGEBASE equ 400000h
org IMAGEBASE

db 'MZ'
; python ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
db '=1;print("Hello World! [python]")'
db 26 ; EOF

times 3Ch - 36 db 0 ; so that ZIP's LASTMOD overlaps PE's e_lfanew
dd NT_Signature - IMAGEBASE
; ZIP start ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


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
incbin 'pdf.pdf'

bits 32
EntryPoint:
    push msg
    call [__imp__printf]
    add esp, 1 * 4
    retn

msg  db 'Hello World! [PE]', 0

Import_Descriptor:
;msvcrt.dll_DESCRIPTOR
    dd msvcrt.dll_hintnames - IMAGEBASE
    dd 0, 0
    dd msvcrt.dll - IMAGEBASE
    dd msvcrt.dll_iat - IMAGEBASE
;terminator
    dd 0, 0, 0, 0, 0

hnprintf:
    dw 0
    db 'printf', 0


ImportsAddressTable:
msvcrt.dll_iat:
__imp__printf:
    dd hnprintf - IMAGEBASE
    dd 0
_d

msvcrt.dll_hintnames:
    dd hnprintf - IMAGEBASE
    dd 0
_d

IMPORTSADDRESSTABLESIZE equ $ - ImportsAddressTable

msvcrt.dll  db 'msvcrt.dll',0
_d

SIZEOFIMAGE equ $ - IMAGEBASE

; html starts here ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
db "<html><body><style>body { visibility:hidden;} .n { visibility: visible; position: absolute; padding: 0 1ex 0 1ex; margin: 0; top: 0; left: 0; } h1 { margin-top: 0.4ex; margin-bottom: 0.8ex; }</style><div class=n><script type='text/javascript'>alert('Hello World! [JavaScript]');</script><!--"

%include 'zip.asm'

; trick to prevent python to handle the file as a zip
; dd 0 ; will screw up the java loading