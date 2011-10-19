; a test for NOP and HINT NOP opcode

; Ange Albertini, BSD LICENCE 2011

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

EntryPoint:
    print executionstarted
_
    print _32bmode
_
    print testingnop
    mov eax, 12345678h
    nop
    cmp eax, 12345678h
_
    print testingxchgeax
    mov dword [ok], _32xchg
    mov eax, 12345678h
    db 87h, 0c0h
    cmp eax, 12345678h
    test32
_
    print testinghintnopdoc
    db 0fh, 19h, 0c0h
    print testinghintnopundoc
    db 0fh, 1fh, 0c0h
    print testinghintnopinvalidmem
    xor eax, eax
    dec eax
    db 0fh, 19h, 0
    _
    print testinghintnopexception
    push exception1
    push dword [fs:0]
    mov [fs:0], esp
    mov edi, IMAGEBASE + 2 * SECTIONALIGN - 2
    mov ax, 0190fh
    stosw
    jmp IMAGEBASE + 2 * SECTIONALIGN - 2

exception1:
    print exceptiontriggered
_
    stop_if_no_64b
_
    print _started64b
_
start64b
    print64 testingxchgeax
    mov dword [ok], _64xchg
    mov rax, 0123456789abcdefh
    db 87h, 0c0h
    mov rbx, 0000000089abcdefh
    cmp rax, rbx
    test64
_

backto32b

    push 0
    call [__imp__ExitProcess]
_c
bits 32

executionstarted db " * testing nop", 0ah, 0

_32bmode db "  # 32b mode", 0ah, 0
testingnop db "   # nop ", 0ah, 0
testingxchgeax db "   # `87c0 xchg eax, eax`: ", 0
_32xchg db "`<01234567> => <01234567>`", 0ah, 0

testinghintnopdoc db "   # documented hint nop: `0f19c0 nop eax`", 0ah, 0
testinghintnopinvalidmem db "   # hint nop on invalid address: `0f1900 nop [ffffffff]` => nothing", 0ah, 0
testinghintnopundoc db "   # undocumented hint nop: `0f1fc0 nop eax`", 0ah, 0
testinghintnopexception db "   # hint-nop triggered exception: ", 0
exceptiontriggered db "exception triggered", 0ah, 0

_started64b db "  # 64b detected, starting 64b mode", 0ah, 0
_64xchg db "`01234567<89abcdef> => 00000000<89abcdef>`", 0ah, 0

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
