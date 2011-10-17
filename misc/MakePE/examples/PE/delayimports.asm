; PE with delay imports experiments

%include '../../consts.asm'
DOS_HEADER__e_lfanew equ 03ch

IMAGEBASE equ 400000h
FILEALIGN equ 4h
SECTIONALIGN equ FILEALIGN  ; different alignements are not supported by MakePE
org IMAGEBASE

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
    at IMAGE_FILE_HEADER.NumberOfSections,      dw NUMBEROFSECTIONS
    at IMAGE_FILE_HEADER.SizeOfOptionalHeader,  dw SIZEOFOPTIONALHEADER
    at IMAGE_FILE_HEADER.Characteristics,       dw CHARACTERISTICS
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
    at IMAGE_OPTIONAL_HEADER32.SizeOfHeaders            , dd SIZEOFHEADERS  ; can be 0 in some circumstances
    at IMAGE_OPTIONAL_HEADER32.Subsystem                , dw IMAGE_SUBSYSTEM_WINDOWS_GUI
    at IMAGE_OPTIONAL_HEADER32.NumberOfRvaAndSizes      , dd NUMBEROFRVAANDSIZES
iend

DataDirectory:
istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA,   dd IMPORT_DESCRIPTOR - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.DelayImportsVA, dd delay_imports - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.DelayImportsSize, dd DELAY_IMPORTS_SIZE
iend

NUMBEROFRVAANDSIZES equ ($ - DataDirectory) / IMAGE_DATA_DIRECTORY_size

SIZEOFOPTIONALHEADER equ $ - OptionalHeader

SectionHeader:
istruc IMAGE_SECTION_HEADER
    at IMAGE_SECTION_HEADER.VirtualAddress, dd Section0Start - IMAGEBASE
    at IMAGE_SECTION_HEADER.SizeOfRawData, dd SECTION0SIZE
    at IMAGE_SECTION_HEADER.PointerToRawData, dd Section0Start - IMAGEBASE
    at IMAGE_SECTION_HEADER.Characteristics, dd IMAGE_SCN_MEM_EXECUTE | IMAGE_SCN_MEM_WRITE
; necessary under Win7 (with DEP?)
iend
NUMBEROFSECTIONS equ ($ - SectionHeader) / IMAGE_SECTION_HEADER_size

align FILEALIGN, db 0
align 1000h, db 0 ; necessary only for Win7
SIZEOFHEADERS equ $ - IMAGEBASE

bits 32
base_of_code:
Section0Start:
EntryPoint:
    push MB_ICONINFORMATION ; UINT uType
    push tada               ; LPCTSTR lpCaption
    push helloworld         ; LPCTSTR lpText
    push 0                  ; HWND hWnd
    call [__imp__MessageBoxA]
    push 0                  ; UINT uExitCode
    call ExitProcess

align 10h, db 090h

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
    mov ebx, LOADLIBRARYA
    call GetProcAddress_Hash
    mov [ddLoadLibrary], ebx

    mov eax, [hKernel32]
    mov ebx, GETPROCADDRESS
    call GetProcAddress_Hash
    mov [GetProcAddress], ebx

    push szuser32
    call [ddLoadLibrary]
;    mov [hUser32], eax

    push eax
    call [GetProcAddress]
    jmp eax
align 10h, db 090h

szuser32  Db 'user32.dll',0
hKernel32 dd 0
hUser32 dd 0
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
    mov edx, [ebp + DOS_HEADER__e_lfanew] ; e_lfanew = RVA of NT_SIGNATURE
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

SIZEOFCODE equ $ - base_of_code


align FILEALIGN,db 0

base_of_data:

tada db "Tada!", 0
helloworld db "Hello World!", 0
align 10h, db 0

user32IAT:
__imp__MessageBoxA:
    DD __delay__MessageBoxA
    DD 0

user32INT:
    DD hnMessageBoxA - IMAGEBASE
    DD 0

hnMessageBoxA:
    dw 0
    db 'MessageBoxA',0

__delay__MessageBoxA:
    mov eax, hnMessageBoxA + 2
    jmp DelayImportLoad

delay_imports:
istruc _IMAGE_DELAY_IMPORT_DESCRIPTOR
    at _IMAGE_DELAY_IMPORT_DESCRIPTOR.grAttrs,      dd 1        ; if 0, VAs, if 1, RVAs
;    at _IMAGE_DELAY_IMPORT_DESCRIPTOR.rvaDLLName,   dd szuser32 - IMAGEBASE
;    at _IMAGE_DELAY_IMPORT_DESCRIPTOR.rvaHmod,      dd diHandle - IMAGEBASE
    at _IMAGE_DELAY_IMPORT_DESCRIPTOR.rvaIAT,       dd user32IAT - IMAGEBASE
    at _IMAGE_DELAY_IMPORT_DESCRIPTOR.rvaINT,       dd user32INT - IMAGEBASE
    at _IMAGE_DELAY_IMPORT_DESCRIPTOR.dwTimeStamp,  dd 0 ; TimeStamp of a DLL bound the old way
iend
istruc _IMAGE_DELAY_IMPORT_DESCRIPTOR
iend

;diHandle dd 0   ; not used here


DELAY_IMPORTS_SIZE equ $ - delay_imports

MessageBoxA:
    jmp [__imp__MessageBoxA]

;%IMPORT kernel32.dll!ExitProcess
;%IMPORTS

SIZEOFINITIALIZEDDATA equ $ - base_of_data

uninit_data:
SIZEOFUNINITIALIZEDDATA equ $ - uninit_data

SECTION0SIZE EQU $ - Section0Start

SIZEOFIMAGE EQU $ - IMAGEBASE

; Ange Albertini, BSD Licence 2010-2011