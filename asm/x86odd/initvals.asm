; file testing registers initial values

; Ange Albertini, BSD LICENCE 2011

%include 'consts.inc'

IMAGEBASE equ 400000h
org IMAGEBASE
bits 32

TLSSIZE equ 34982734h
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
    at IMAGE_OPTIONAL_HEADER32.AddressOfEntryPoint,       dd EntryPoint - IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.ImageBase,                 dd IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.SectionAlignment,          dd SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER32.FileAlignment,             dd FILEALIGN
    at IMAGE_OPTIONAL_HEADER32.MajorSubsystemVersion,     dw 4
    at IMAGE_OPTIONAL_HEADER32.SizeOfImage,               dd 2 * SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER32.SizeOfHeaders,             dd SIZEOFHEADERS
    at IMAGE_OPTIONAL_HEADER32.Subsystem,                 dw IMAGE_SUBSYSTEM_WINDOWS_CUI
    at IMAGE_OPTIONAL_HEADER32.NumberOfRvaAndSizes,       dd 16
iend

istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA,   dd Import_Descriptor - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.TLSVA,       dd Image_Tls_Directory32 - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.TLSSize,       dd TLSSIZE
iend

SIZEOFOPTIONALHEADER equ $ - OptionalHeader
SectionHeader:
istruc IMAGE_SECTION_HEADER
    at IMAGE_SECTION_HEADER.VirtualSize,      dd 1 * SECTIONALIGN
    at IMAGE_SECTION_HEADER.VirtualAddress,   dd 1 * SECTIONALIGN
    at IMAGE_SECTION_HEADER.SizeOfRawData,    dd 3 * FILEALIGN
    at IMAGE_SECTION_HEADER.PointerToRawData, dd 1 * FILEALIGN
    at IMAGE_SECTION_HEADER.Characteristics,  dd IMAGE_SCN_MEM_EXECUTE | IMAGE_SCN_MEM_WRITE
iend
NUMBEROFSECTIONS equ ($ - SectionHeader) / IMAGE_SECTION_HEADER_size
SIZEOFHEADERS equ $ - IMAGEBASE

%macro _p 1
    push %1
    call [__imp__printf]
    add esp, 1 * 4
%endmacro

section progbits vstart=IMAGEBASE + SECTIONALIGN align=FILEALIGN

nop
EntryPoint:
    xchg esp, [fake_esp]
    pushf
    pusha
    xchg esp, [fake_esp]

    _p EPstarted
_
    mov eax, [flags]
    cmp eax, 246h
    jz good_EP_flags
_
    _p bad_flags
good_EP_flags:
_
    mov eax, [eax_]
    cmp eax, 0 ; good XP value
    jz good_EP_eax
_
    cmp eax, 70000000h ; good >=Vista value
    ja good_EP_eax
_
    _p bad_eax

good_EP_eax:

    mov ecx, [ecx_]
    cmp ecx, 0 ; good >= Vista value
    jz good_EP_ecx
    mov eax, esp
    sub eax, ecx
    cmp eax, 20h ; good XP value
    jbe good_EP_ecx
_
    _p bad_ecx
good_EP_ecx:

    mov edx, [edx_]
    cmp edx, EntryPoint ; good >= Vista value
    jz good_EP_edx
    cmp edx, 70000000h ; good XP value
    ja good_EP_edx
_
    _p bad_edx
good_EP_edx:

;    mov esi, [esi_]
;    cmp esi, 10h ; standard range, 0 most of the time , not reliable under XP ?
;    jbe good_EP_esi
;_
;    _p bad_esi
;good_EP_esi:

;    mov edi, [edi_]
;    cmp edi, 10h ; standard range, 0 most of the time ?
;    jbe good_EP_edi
;_
;    _p bad_edi
;good_EP_edi:

    _p finished

    push 0
    call [__imp__ExitProcess]
_c

EPstarted db '  # started EntryPoint', 0ah, 0
finished  db '  # finished', 0ah, 0
_d

align FILEALIGN, db 90h
TLS:
    xchg esp, [fake_esp]
    pushf
    pusha
    xchg esp, [fake_esp]
_
    mov dword [Callbacks], 0
    _p msg
    _p tls_started
_
    mov eax, [flags]
    cmp eax, 246h
    jz good_tls_flags
_
    _p bad_flags
good_tls_flags:
_

    mov eax, [eax_]
    cmp eax, 0 ; good >=Vista value
    jz good_tls_eax
_
    cmp eax, TLS ; good XP value
    jz good_tls_eax
_
    _p bad_eax

good_tls_eax:
    mov ecx, [ecx_]
    cmp ecx, 11h ; good >=Vista value
    jz good_tls_ecx
    cmp ecx, TLSSIZE ; good XP value
    jz good_tls_ecx
_
    _p bad_ecx
good_tls_ecx:
_
    mov ebx, [ebx_]
    cmp ebx, TLS    ; good >=Vista Value
    jz good_tls_ebx
    cmp ebx, 0    ; good XP value
    jz good_tls_ebx
_
    _p bad_ebx
good_tls_ebx:
_
    mov edx, [edx_]
    cmp edx, Image_Tls_Directory32 - IMAGEBASE  ; good XP value
    jz good_tls_edx
    cmp edx, 76000000h    ; good >=Vista Value, in ntdll
    jae good_tls_edx
_
    _p bad_edx
good_tls_edx:
    mov dword [fake_esp], fake_stack

    retn

msg db ' * initial registers value tester:', 0ah, 0
tls_started db '  # started TLS', 0ah, 0
bad_flags db '   * bad flags', 0ah, 0
bad_eax   db '   * bad EAX value', 0ah, 0
bad_ebx   db '   * bad EBX value', 0ah, 0
bad_ecx   db '   * bad ECX value', 0ah, 0
bad_edx   db '   * bad EDX value', 0ah, 0
bad_esi   db '   * bad ESI value', 0ah, 0
bad_edi   db '   * bad EDI value', 0ah, 0

Image_Tls_Directory32:
    StartAddressOfRawData dd 0
    EndAddressOfRawData   dd 0
    AddressOfIndex        dd Characteristics
    AddressOfCallBacks    dd Callbacks
    SizeOfZeroFill        dd 0
    Characteristics       dd 0

Callbacks dd TLS, 0

align FILEALIGN, db 0
Import_Descriptor:
;kernel32.dll_DESCRIPTOR:
    dd kernel32.dll_hintnames - IMAGEBASE
    dd 0, 0
    dd kernel32.dll - IMAGEBASE
    dd kernel32.dll_iat - IMAGEBASE
;msvcrt.dll_DESCRIPTOR:
    dd msvcrt.dll_hintnames - IMAGEBASE
    dd 0, 0
    dd msvcrt.dll - IMAGEBASE
    dd msvcrt.dll_iat - IMAGEBASE
;terminator
    dd 0, 0, 0, 0, 0
_d

kernel32.dll_hintnames:
    dd hnExitProcess - IMAGEBASE
    dd 0
msvcrt.dll_hintnames:
    dd hnprintf - IMAGEBASE
    dd 0
_d

hnExitProcess:
    dw 0
    db 'ExitProcess', 0
hnprintf:
    dw 0
    db 'printf', 0
_d

kernel32.dll_iat:
__imp__ExitProcess:
    dd hnExitProcess - IMAGEBASE
    dd 0

msvcrt.dll_iat:
__imp__printf:
    dd hnprintf - IMAGEBASE
    dd 0

_d

kernel32.dll db 'kernel32.dll', 0
msvcrt.dll db 'msvcrt.dll', 0
_d

edi_ dd 0
esi_ dd 0
ebp_ dd 0
esp_ dd 0
ebx_ dd 0
edx_ dd 0
ecx_ dd 0
eax_ dd 0
flags dd 0
fake_stack dd 0
fake_esp dd fake_stack
_d

align FILEALIGN, db 0
