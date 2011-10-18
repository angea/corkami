; a 'normal' PE (fishy, I know)

; Ange Albertini, BSD LICENCE 2009-2011

%include 'consts.inc'

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
iend

SIZEOFOPTIONALHEADER equ $ - OptionalHeader
SectionHeader:
istruc IMAGE_SECTION_HEADER
    at IMAGE_SECTION_HEADER.VirtualSize,      dd 1 * SECTIONALIGN
    at IMAGE_SECTION_HEADER.VirtualAddress,   dd 1 * SECTIONALIGN
    at IMAGE_SECTION_HEADER.SizeOfRawData,    dd PS
    at IMAGE_SECTION_HEADER.PointerToRawData, dd 1 * FILEALIGN
    at IMAGE_SECTION_HEADER.Characteristics,  dd IMAGE_SCN_MEM_EXECUTE | IMAGE_SCN_MEM_WRITE
iend
NUMBEROFSECTIONS equ ($ - SectionHeader) / IMAGE_SECTION_HEADER_size
SIZEOFHEADERS equ $ - IMAGEBASE

section progbits vstart=IMAGEBASE + SECTIONALIGN align=FILEALIGN

%macro start64b 0
    jmp 33h: $ + 7
    bits 64
%endmacro

%macro backto32b 0
    push qword [cs_]
    push $ + 7
    retf
    bits 32
%endmacro

%macro print 1
    push %1
    call [__imp__printf]
    add esp, 1 * 4
%endmacro

%macro print64 1
    backto32b
    print %1
    start64b
%endmacro

%macro test64 0
    jz %%ok
    print64 _fail
    jmp %%end
%%ok:
    print64 dword [ok]
%%end:
%endmacro

%macro test32 0
    jz %%ok
    print _fail
    jmp %%end
%%ok:
    print dword [ok]
%%end:
%endmacro

EntryPoint:
    print executionstarted
_
    print _32bmode
_
    print testingbswap16
    mov dword [ok], _3216
    mov eax, 12345678h
    db 66h
    bswap eax
    cmp eax, 12340000h
    test32
_
    print testingbswap32
    mov dword [ok], _3232
    mov eax, 12345678h
    bswap eax
    cmp eax, 78563412h
    test32
_
    push gs
    pop eax
    cmp ax, 2bh
    jnz no64b
_
    push cs
    pop dword [cs_]
_
    print _started64b
_
start64b
    print64 testingbswap16
    mov dword [ok], _6416
    mov rax, 0123456789abcdefh
    db 66h
    bswap eax
    mov rbx, 0123456789ab0000h
    cmp rax, rbx
    test64
_
    print64 testingbswap32
    mov dword [ok], _6432
    mov rax, 0123456789abcdefh
    bswap eax
    mov rbx, 00000000efcdab89h
    cmp rax, rbx
    test64
_
    print64 testingbswap64
    mov dword [ok], _6464
    mov rax, 0123456789abcdefh
    bswap rax
    mov rbx, 0efcdab8967452301h
    cmp rax, rbx
    test64
_

backto32b

no64b:
    push 42
    call [__imp__ExitProcess]
_c
bits 32

executionstarted db " * testing bswap", 0ah, 0
_32bmode db "  # 32b mode", 0ah, 0
testingbswap16 db "   # 16b reg: ", 0
testingbswap32 db "   # 32b reg: ", 0

_3216 db "`bswap 1234<5678> => 1234<0000>`", 0ah, 0
_3232 db "`bswap <12345678> => <78563412>`", 0ah, 0

_started64b db "  # 64b detected, starting 64b mode", 0ah, 0
testingbswap64 db "   # 64b reg: ", 0
_6416 db "`bswap 0123456789ab<cdef> => 0123456789ab<0000>`", 0ah, 0
_6432 db "`bswap 01234567<89abcdef> => 00000000<efcdab89>`", 0ah, 0
_6464 db "`bswap <0123456789abcdef> => <efcdab8967452301>`", 0ah, 0

ok dd _ok
_fail db "FAIL", 0ah, 0
_ok db "OK", 0ah, 0
_d

cs_ dd 0
_d

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

PS equ $ - EntryPoint
align FILEALIGN, db 0
