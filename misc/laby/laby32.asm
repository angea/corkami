; A PE->TGA labyrinth generator
; TODO: fix large dimensions
; thanks to Gynvael for his TGA suggestion

; Ange Albertini, BSD LICENCE 2013

%include 'PE.inc'

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
    at IMAGE_OPTIONAL_HEADER32.SizeOfImage,               dd 9 * SECTIONALIGN
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
    at IMAGE_SECTION_HEADER.VirtualSize,      dd 8 * SECTIONALIGN
    at IMAGE_SECTION_HEADER.VirtualAddress,   dd 1 * SECTIONALIGN
    at IMAGE_SECTION_HEADER.SizeOfRawData,    dd 1 * FILEALIGN
    at IMAGE_SECTION_HEADER.PointerToRawData, dd 1 * FILEALIGN
    at IMAGE_SECTION_HEADER.Characteristics,  dd IMAGE_SCN_MEM_EXECUTE | IMAGE_SCN_MEM_WRITE
iend
NUMBEROFSECTIONS equ ($ - SectionHeader) / IMAGE_SECTION_HEADER_size
SIZEOFHEADERS equ $ - IMAGEBASE

section progbits vstart=IMAGEBASE + SECTIONALIGN align=FILEALIGN

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


EntryPoint:

W equ 64

SCREENWIDTH equ 2 * W + 1

COLOR_BLACK equ 0
COLOR_WHITE equ 0ffh

start:
    ; seeding the random
    rdtsc
    push eax
    call [__imp__srand]
    pop eax

; drawing the 4 external walls

    ; top
    mov edi, buffer
    mov al, COLOR_WHITE
    mov edx, 2 * W + 1
    mov ecx, edx
    rep stosb

    ; bottom
    mov edi, buffer + (2 * W + 1) * (2 * W)
    mov ecx, edx
    rep stosb

    ; left & right
    mov edi, buffer
    mov ecx, edx

wall_loop:
    stosb
    add edi, 2 * W - 1
    stosb
    add edi, SCREENWIDTH - (2 * W + 1)
    loop wall_loop

; drawing start and end points
    mov edi, buffer + 1 + 2 * SCREENWIDTH
    stosb

    ; the first 'main' point
    stosb

    ; end point
    mov edi, buffer + 2 * W - 1 + (2 * W - 2) * SCREENWIDTH
    stosb

; main algo loop
pick_a_point:

    ; we pick a pixel on even coordinates

    mov esi, buffer
    call random
    add esi, eax      ; X

    call random
    mov edx, SCREENWIDTH
    mul edx
    add esi, eax      ; Y

    ; esi now points to the start pixel in video
    cmp byte [esi], COLOR_WHITE
    jnz pick_a_point

    ; now we pick a random direction to scan
    call random
    mov edx, SCREENWIDTH ; default, vertical scan
    test al, 4h
    jnz V
    mov edx, 1 ; horizontal
V:

    ; positive or negative progression ?
    test al, 8h
    jnz P
    neg edx ; negative
P:

    ; edx now contains the increment for the target pixel to check
    add esi, edx
    add esi, edx

    cmp byte [esi], COLOR_BLACK
    jnz pick_a_point

    ; draw the 2 pixels line between both dots
    mov byte [esi], COLOR_WHITE
    sub esi, edx
    mov byte [esi], COLOR_WHITE

    dec dword [counter]
    jnz pick_a_point

    push 0
    push 0
    push 1
    push 0
    push 1
    push 0C0000000h
    push IMAGEBASE
    call [__imp__CreateFileA]

    push 0
    push EntryPoint
    push buffer - header + (2 * W + 1) * (2 * W + 1)
    push header
    push eax
    call [__imp__WriteFile]

    retn

random:
    call [__imp__rand]
    mov eax, ecx
    mov edx, W - 1
    mul edx
    mov eax, edx

    shl eax, 1
    add eax, 2

    retn

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Import_Descriptor:
_import_descriptor kernel32.dll
_import_descriptor msvcrt.dll
istruc IMAGE_IMPORT_DESCRIPTOR
iend

kernel32.dll_hintnames:
    dd hnCreateFileA - IMAGEBASE
    dd hnWriteFile - IMAGEBASE
    dd 0
msvcrt.dll_hintnames:
    dd hnsrand - IMAGEBASE
    dd hnrand - IMAGEBASE
    dd 0

hnsrand:
    dw 0
    db 'srand', 0
hnCreateFileA:
    dw 0
    db 'CreateFileA', 0
hnWriteFile:
    dw 0
    db 'WriteFile', 0
hnrand:
    dw 0
    db 'rand', 0

kernel32.dll_iat:
__imp__CreateFileA:
    dd hnCreateFileA- IMAGEBASE
__imp__WriteFile:
    dd hnWriteFile - IMAGEBASE
    dd 0

msvcrt.dll_iat:
__imp__srand:
    dd hnsrand - IMAGEBASE
__imp__rand:
    dd hnrand - IMAGEBASE
    dd 0

kernel32.dll db 'kernel32.dll', 0
msvcrt.dll db 'msvcrt.dll', 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
counter dd (W - 1) * (W - 1) - 1

; TGA picture header
header:
    db 0 ; image ID field
    db 1 ; color map type
    db 1 ; image type
    dw 0 ; palette offset
    dw 1 ; color count
    db 24 ; color map size
    dw 0, 0 ; coordinates index
    dw 2 * W + 1 ; coordinates sizes
    dw 2 * W + 1
    db 8,0,-1,-1,-1 ; palette
buffer:

align FILEALIGN, db 0
