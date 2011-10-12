; PE with delay imports (broken ATM)

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

DataDirectory:
istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA,   dd Import_Descriptor - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.DelayImportsVA, dd delay_imports - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.DelayImportsSize, dd DELAY_IMPORTS_SIZE
iend

SIZEOFOPTIONALHEADER equ $ - OptionalHeader
SectionHeader:
istruc IMAGE_SECTION_HEADER
    at IMAGE_SECTION_HEADER.VirtualSize,      dd 1 * SECTIONALIGN
    at IMAGE_SECTION_HEADER.VirtualAddress,   dd 1 * SECTIONALIGN
    at IMAGE_SECTION_HEADER.SizeOfRawData,    dd 1 * FILEALIGN
    at IMAGE_SECTION_HEADER.PointerToRawData, dd 1 * FILEALIGN
    at IMAGE_SECTION_HEADER.Characteristics,  dd IMAGE_SCN_MEM_EXECUTE | IMAGE_SCN_MEM_WRITE
iend
NUMBEROFSECTIONS equ ($ - SectionHeader) / IMAGE_SECTION_HEADER_size

SIZEOFHEADERS equ $ - IMAGEBASE
Section0Start:
VDELTA equ 0e00h ; SECTIONALIGN - ($ - IMAGEBASE) ; VIRTUAL DELTA between this sections offset and virtual addresses

EntryPoint:
    push Msg
    call printf;[__imp__printf]
    add esp, 1 * 4
_
    push 0
    call [__imp__ExitProcess]
_c

Msg db " * a normal PE", 0ah, 0
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
_d

kernel32.dll_iat:
__imp__ExitProcess:
    dd hnExitProcess - IMAGEBASE
    dd 0

msvcrt.dll_iat:
;__imp__printf:
;    dd hnprintf - IMAGEBASE
;    dd 0
_d

kernel32.dll db 'kernel32.dll', 0
msvcrt.dll db 'msvcrt.dll', 0
_d

;***************************************************************************************************

align 10h, db 090h

__delay__printf:
    mov eax, hnprintf + 2
    jmp DelayImportLoad

align 10h, db 090h

DelayImportLoad:
    push eax
    mov eax,[fs:030h]   ; _TIB.PebPtr
    mov eax,[eax + 0ch] ; _PEB.Ldr
    mov eax,[eax + 0ch] ; _PEB_LDR_DATA.InLoadOrderModuleList.Flink
    mov eax,[eax]       ; _LDR_MODULE.InLoadOrderModuleList.Flink
    mov eax,[eax]       ; _LDR_MODULE.InLoadOrderModuleList.Flink
    mov eax,[eax + 18h] ; _LDR_MODULE.BaseAddress

    mov [hKernel32], eax

    mov eax, [hKernel32]
    mov ebx, LOADLIBRARYA ; VDELTA +
    call GetProcAddress_Hash
    mov [ddLoadLibrary], ebx

    mov eax, [hKernel32]
    mov ebx, GETPROCADDRESS ;
    call GetProcAddress_Hash
    mov [GetProcAddress], ebx

    push szmsvcrt
    call [ddLoadLibrary]
;    mov [hmsvcrt], eax

    push eax
    call [GetProcAddress]
    jmp eax
align 10h, db 090h

szmsvcrt  Db 'msvcrt.dll',0
hKernel32 dd 0
hmsvcrt dd 0
ddLoadLibrary dd 0
GetProcAddress dd 0

align 10h, db 090h

LOADLIBRARYA equ 06FFFE488h
GETPROCADDRESS equ 03F8AAA7Eh

NT_SIGNATURE__IMAGE_DIRECTORY_ENTRY_EXPORT__RVA equ 78h

Exports__NumberOfNames      EQU 018h
Exports__AddressOfFunctions EQU 01ch
Exports__AddressOfNames     EQU 020h
Exports__AddressOfNamesOrdinal EQU 024h

GetProcAddress_Hash:
    mov [ImageBase], eax
    mov [checksum], ebx
    mov ebp, [ImageBase]
    ; ebp = PE start / ImageBase
    mov edx, [ebp + 0x3c] ; e_lfanew = RVA of NT_SIGNATURE
    add edx, [ImageBase]    ; RVA to VA
        ; => eax = NT_SIGNATURE VA

    mov edx, [edx + NT_SIGNATURE__IMAGE_DIRECTORY_ENTRY_EXPORT__RVA]  ; IMAGE_DIRECTORY_ENTRY_EXPORT (.RVA) - NT_SIGNATURE
    add edx, [ImageBase]    ; RVA to VA
        ; => edx = IMAGE_DIRECTORY_ENTRY_EXPORT VA
    mov [ExportDirectory], edx

    mov ecx, [edx + Exports__NumberOfNames] ; NumberOfNames

    mov ebx, [edx + Exports__AddressOfNames] ; AddressOfNames
    add ebx, [ImageBase]    ; RVA to VA

next_name:
    test ecx, ecx
    jz no_more_exports
    dec ecx

    mov esi, [ebx + ecx * 4]
    add esi, [ImageBase] ; RVA to VA

    mov edi, 0

checksum_loop:
    xor eax, eax
    lodsb

    rol edi, 7
    add edi, eax

    test al, al
    jnz checksum_loop

    cmp edi, [checksum]
    jnz next_name

    mov ebx, [edx + Exports__AddressOfNamesOrdinal] ; AddressOfNamesOrdinal RVA
    add ebx, [ImageBase]

    mov cx, [ebx + ecx * 2]

    mov ebx, [edx + Exports__AddressOfFunctions] ; AddressOfFunctions RVA
    add ebx, [ImageBase]
    mov ebx, [ebx + ecx * 4] ; Functions RVA
    add ebx, [ImageBase]

    jmp _end
no_more_exports:
    xor ebx, ebx
_end:
    retn
align 10h, db 0cch
checksum dd 0
ImageBase dd 0
char db 0
ExportDirectory dd 0

align FILEALIGN,db 0

base_of_data:

tada db "Tada!", 0
helloworld db "Hello World!", 0
align 10h, db 0

struc _IMAGE_DELAY_IMPORT_DESCRIPTOR
    .grAttrs       resd 1  ; attributes
    .rvaDLLName    resd 1  ; RVA to dll name
    .rvaHmod       resd 1  ; RVA of module handle
    .rvaIAT        resd 1  ; RVA of the IAT
    .rvaINT        resd 1  ; RVA of the INT
    .rvaBoundIAT   resd 1  ; RVA of the optional bound IAT
    .rvaUnloadIAT  resd 1  ; RVA of optional copy of original IAT
    .dwTimeStamp   resd 1  ; 0 if not bound
endstruc

delay_imports:
istruc _IMAGE_DELAY_IMPORT_DESCRIPTOR
    at _IMAGE_DELAY_IMPORT_DESCRIPTOR.grAttrs,      dd 1        ; if 0, VAs, if 1, RVAs
    at _IMAGE_DELAY_IMPORT_DESCRIPTOR.rvaDLLName,   dd szmsvcrt - IMAGEBASE
    at _IMAGE_DELAY_IMPORT_DESCRIPTOR.rvaHmod,      dd diHandle - IMAGEBASE
    at _IMAGE_DELAY_IMPORT_DESCRIPTOR.rvaIAT,       dd msvcrtIAT - IMAGEBASE
    at _IMAGE_DELAY_IMPORT_DESCRIPTOR.rvaINT,       dd msvcrtINT - IMAGEBASE
    at _IMAGE_DELAY_IMPORT_DESCRIPTOR.rvaBoundIAT,  dd msvcrtdbiat - IMAGEBASE
    at _IMAGE_DELAY_IMPORT_DESCRIPTOR.rvaUnloadIAT, dd msvcrtduiat - IMAGEBASE
    at _IMAGE_DELAY_IMPORT_DESCRIPTOR.dwTimeStamp,  dd 0 ; TimeStamp of a DLL bound the old way
iend
istruc _IMAGE_DELAY_IMPORT_DESCRIPTOR
iend

diHandle dd 0   ; not used here

msvcrtIAT:
__imp__printf:
    DD __delay__printf + VDELTA
    DD 0

msvcrtINT:
    DD hnprintf - IMAGEBASE
    DD 0

hnprintf:
    dw 0
    db 'printf',0

msvcrtdbiat:
    dd 0
    dd 0

msvcrtduiat:
    dd DelayImportLoad
    dd 0

DELAY_IMPORTS_SIZE equ $ - delay_imports

printf:
    jmp [__imp__printf]

;***************************************************************************************************
align FILEALIGN, db 0

Section0Size EQU $ - Section0Start

SIZEOFIMAGE EQU $ - IMAGEBASE
