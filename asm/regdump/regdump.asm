; small registers dumper
; todo:
; * fix DLL loading under XP
; * driver
; * smarter smsw/sldt/mov32

; Ange Albertini, BSD licence 2011

%include '..\consts.inc'

IMAGEBASE equ 03ec0000h

FILEALIGN equ 4h
SECTIONALIGN equ FILEALIGN  ; different alignements are not supported by MakePE
org IMAGEBASE

TLSSIZE equ 0%RAND16h

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
    at IMAGE_OPTIONAL_HEADER32.SizeOfHeaders            , dd SIZEOFHEADERS
    at IMAGE_OPTIONAL_HEADER32.Subsystem                , dw SUBSYSTEM
    at IMAGE_OPTIONAL_HEADER32.NumberOfRvaAndSizes      , dd NUMBEROFRVAANDSIZES
iend

DataDirectory:
istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ExportsVA,   dd Exports_Directory - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.ImportsVA,   dd IMPORT_DESCRIPTOR - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.ResourceVA,  dd Directory_Entry_Resource - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.FixupsVA,    dd Directory_Entry_Basereloc - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.FixupsSize,  dd DIRECTORY_ENTRY_BASERELOC_SIZE
    at IMAGE_DATA_DIRECTORY_16.TLSVA,       dd Image_Tls_Directory32 - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.TLSSize,       dd TLSSIZE
iend

NUMBEROFRVAANDSIZES equ ($ - DataDirectory) / IMAGE_DATA_DIRECTORY_size

SIZEOFOPTIONALHEADER equ $ - OptionalHeader

SectionHeader:
istruc IMAGE_SECTION_HEADER
    at IMAGE_SECTION_HEADER.VirtualSize, dd SECTION0SIZE
    at IMAGE_SECTION_HEADER.VirtualAddress, dd Section0Start - IMAGEBASE
    at IMAGE_SECTION_HEADER.SizeOfRawData, dd SECTION0SIZE
    at IMAGE_SECTION_HEADER.PointerToRawData, dd Section0Start - IMAGEBASE
    at IMAGE_SECTION_HEADER.Characteristics, dd IMAGE_SCN_MEM_EXECUTE + IMAGE_SCN_MEM_WRITE; necessary under Win7 (with DEP?)
iend
NUMBEROFSECTIONS equ ($ - SectionHeader) / IMAGE_SECTION_HEADER_size

align FILEALIGN, db 0
align 1000h, db 0           ; necessary under Win7 x64
SIZEOFHEADERS equ $ - IMAGEBASE

bits 32
Section0Start:

%macro printline 1
    push %1
    call printf
    add esp, 4
%endmacro

EntryPoint:
    pushf
    pusha
    mov byte [tls], 0c3h
    printline %string:"|| !EntryPoint || ", 0
    popa
    popf
    call genregs

    push %string:"regdumplib.dll",0
;%IMPORTCALL kernel32.dll!LoadLibraryA

    push 0
;%IMPORTCALL kernel32.dll!ExitProcess
_c

;%IMPORT msvcrt.dll!printf
_c



tls:
    pusha
    pushf
    printline %string:"Register dumper 0.3 - Ange Albertini - BSD Licence 2011", 0ah, 0
    call exechars

    call printversion
    call selectors
    call systemregs

    printline %string:" * general registers", 0ah, 0
    printline %string:"|| *execution point* || || Flags || || EDI || ESI || EBP || ESP || EBX || EDX || ECX || EAX ||", 0ah, "||||||||||||||||||||||||||", 0ah, 0
    printline %string:"|| TLS || ", 0
    popf
    popa
    call genregs

    retn
_c

printversion:
    printline %string:" * OS Version", 0ah, "|| Version || Platform || !ServicePack || Suite || Product ||", 0ah, 0

    push OSVerEx
;%IMPORTCALL kernel32!GetVersionExA

    movzx eax, byte [OSVerEx.wProductType]
    push eax

    movzx eax, word [OSVerEx.wSuiteMask]
    push eax

    movzx eax, word [OSVerEx.wServicePackMinor]
    push eax

    movzx eax, word [OSVerEx.wServicePackMajor]
    push eax

    push dword [OSVerEx.dwPlatformId]
    push dword [OSVerEx.dwBuildNumber]

    push dword [OSVerEx.dwMinorVersion]
    push dword [OSVerEx.dwMajorVersion]

    push %string:"|| %i.%i.%i || %i || %i.%i || %04X || %i ||", 0ah, 0ah, 0
    call printf
    add esp, 9 * 4
    retn
_c

exechars:
    push IMAGEBASE
    push TLSSIZE
    push Image_Tls_Directory32 - IMAGEBASE
    push tls
    push %string:"(Executable info: TLS callback RVA %08X, TLS DD RVA:%X Size: %X, !ImageBase: %08X)", 0ah, 0
    call printf
    add esp, 5 * 4
    retn
_c

selectors:
    push gs
    mov word [esp + 2], 0
    push ss
    mov word [esp + 2], 0
    push fs
    mov word [esp + 2], 0
    push es
    mov word [esp + 2], 0
    push ds
    mov word [esp + 2], 0
    push cs
    mov word [esp + 2], 0
    push %string:" * selectors", 0ah,"|| CS || DS || ES || FS || SS || GS ||", 0ah,"|| %X || %X || %X || %X || %X || %X ||", 0ah, 0ah, 0
    call printf
    add esp, 7 * 4
    retn
_c


systemregs:
    printline %string:" * system registers", 0ah,"|| CR0 || LDT || GDT || IDT || Task Register ||", 0ah, 0

;cr0_check
    smsw eax
    push eax

    push eax
    push %string:"|| %08X", 0
    call printf
    add esp, 2 * 4

    fnop
    smsw eax
    cmp [esp], eax
    jz same_cr0

    mov [esp], eax
    push %string:" (after FPU:%08X)", 0
    call printf
    add esp, 2 * 4
    jmp cr0_end

same_cr0:
    pop eax
    jmp cr0_end

cr0_end:
_
    sidt [_sidt]
    sgdt [_sgdt]

    str eax
    push eax

    push dword [_sidt]
    movzx eax, word [_sidt + 4]
    push eax

    push dword [_sgdt]
    movzx eax, word [_sgdt + 4]
    push eax

    sldt eax
    push eax

    push %string:"|| %08X || %04X%08X || %04X%08X || %08X ||", 0ah, 0ah, 0
    call printf
    add esp, 7 * 4
    retn
_c

genregs:
    pusha
    pushf
    push %string:"|| %04X || || %08X || %08X || %08X || %08X || %08X || %08X || %08X || %08X ||", 0ah, 0
    call printf
    add esp, 10*4
    retn
_c

Image_Tls_Directory32:
    StartAddressOfRawData dd Characteristics
    EndAddressOfRawData   dd Characteristics
    AddressOfIndex        dd Characteristics
    AddressOfCallBacks    dd SizeOfZeroFill
    SizeOfZeroFill        dd tls
    Characteristics       dd 0

_sidt dq -1
_sgdt dq -1
_sldt dq -1


OSVerEx:
  .dwOSVersionInfoSize dd OSVerExSize
  .dwMajorVersion dd 0
  .dwMinorVersion dd 0
  .dwBuildNumber dd 0
  .dwPlatformId dd 0
  .szCSDVersion times 128 db 0
  .wServicePackMajor dw 0
  .wServicePackMinor dw 0
  .wSuiteMask dw 0
  .wProductType db 0
  .wReserved db 0
OSVerExSize equ $ - OSVerEx
_d

;; dumping upper bits that are undefined and potentially different on pentium

;print_upperbits:
;    shr eax, 16
;    movzx eax, ax
;    push eax
;    push %string:"%04X ", 0
;    call printf
;    add esp, 2 * 4
;    retn


;    printline %string:0dh, 0ah, "upper bits (10 times):", 0ah, 0
;    printline %string:"Mov r32, sel", 0ah,"   ", 0
;
;    mov ecx, 10
;movselloop:
;    push ecx
;    mov eax, ds
;
;    call print_upperbits
;    pop ecx
;    loop movselloop
;
;    push %string:0dh, 0ah, "sldt", 0ah,"   ", 0
;    call printf
;    add esp, 4
;
;    mov ecx, 10
;sldtloop:
;    push ecx
;    sldt eax
;    call print_upperbits
;    pop ecx
;    loop sldtloop
;
;    push %string:0dh, 0ah, "smsw", 0ah,"   ", 0
;    call printf
;    add esp, 4
;
;    mov ecx, 10
;smswloop:
;    push ecx
;    smsw eax
;    call print_upperbits
;    pop ecx
;    loop smswloop
;
;    push %string:0dh, 0ah, 0
;    call printf
;    add esp, 4
;

;%IMPORTS
;%strings

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE
SUBSYSTEM equ 3
