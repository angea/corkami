BITS 32

%define DEBUG

%ifdef ELF

%macro _header 0

%include 'elf.inc'

ELFBASE equ 08000000h

org ELFBASE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ELF Header

ehdr:
istruc Elf32_Ehdr
    at Elf32_Ehdr.e_ident
        EI_MAG     db 07Fh, "ELF"
        EI_CLASS   db ELFCLASS32
        EI_DATA    db ELFDATA2LSB
        EI_VERSION db EV_CURRENT
    at Elf32_Ehdr.e_type,      db ET_EXEC
    at Elf32_Ehdr.e_machine,   db EM_386
    at Elf32_Ehdr.e_version,   db EV_CURRENT
    at Elf32_Ehdr.e_entry,     dd main
    at Elf32_Ehdr.e_phoff,     dd phdr - ehdr
    at Elf32_Ehdr.e_shoff,     dd shdr - ehdr
    at Elf32_Ehdr.e_ehsize,    dw Elf32_Ehdr_size
    at Elf32_Ehdr.e_phentsize, dw Elf32_Phdr_size
    at Elf32_Ehdr.e_phnum,     dw PHNUM
    at Elf32_Ehdr.e_shentsize, dw Elf32_Shdr_size
    at Elf32_Ehdr.e_shnum,     dw SHNUM
    at Elf32_Ehdr.e_shstrndx,  dw SHSTRNDX
iend

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Program header table

phdr:
istruc Elf32_Phdr
    at Elf32_Phdr.p_type,   dd PT_LOAD
    at Elf32_Phdr.p_vaddr,  dd ELFBASE
    at Elf32_Phdr.p_paddr,  dd ELFBASE
    at Elf32_Phdr.p_filesz, dd main - ehdr + MAIN_SIZE
    at Elf32_Phdr.p_memsz,  dd main - ehdr + MAIN_SIZE
    at Elf32_Phdr.p_flags,  dd PF_R + PF_X
iend
PHNUM equ ($ - phdr) / Elf32_Phdr_size

align 16, db 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; .text section (code)

main:

%endmacro

%macro _print 1
    mov ecx, %1
    mov edx, %1_LEN

    mov ebx, STDOUT
    mov eax, SC_WRITE
    int 80h
%endmacro


%macro _exit 1
    mov ebx, %1 ; return code

    mov eax, SC_EXIT
    int 80h
%endmacro

%macro _footer 0

MAIN_SIZE equ $ - main

align 16, db 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; .shtstrtab section (section names)

names:
    db 0
ashstrtab:
    db ".shstrtab", 0
atext:
    db ".text", 0
NAMES_SIZE equ $ - names

align 16, db 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Section header table (optional)

shdr:

; section 0, always null
istruc Elf32_Shdr
    at Elf32_Shdr.sh_type,      dw SHT_NULL
iend

istruc Elf32_Shdr
    at Elf32_Shdr.sh_name,      db atext - names
    at Elf32_Shdr.sh_type,      dw SHT_PROGBITS
    at Elf32_Shdr.sh_flags,     dd SHF_ALLOC + SHF_EXECINSTR
    at Elf32_Shdr.sh_addr,      dd main
    at Elf32_Shdr.sh_offset,    dd main - ehdr
    at Elf32_Shdr.sh_size,      dd MAIN_SIZE
iend

SHSTRNDX equ ($ - shdr) / Elf32_Shdr_size
istruc Elf32_Shdr
    at Elf32_Shdr.sh_name,      db ashstrtab - names
    at Elf32_Shdr.sh_type,      dw SHT_STRTAB
    at Elf32_Shdr.sh_offset,    dd names - ehdr
    at Elf32_Shdr.sh_size,      dd NAMES_SIZE
iend

SHNUM equ ($ - shdr) / Elf32_Shdr_size

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
%endmacro

%endif ; ELF ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

%ifdef PE

%macro _header 0

%include 'pe.inc'

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
    at IMAGE_SECTION_HEADER.SizeOfRawData,    dd 1 * SECTIONALIGN
    at IMAGE_SECTION_HEADER.PointerToRawData, dd 1 * FILEALIGN
    at IMAGE_SECTION_HEADER.Characteristics,  dd IMAGE_SCN_MEM_EXECUTE | IMAGE_SCN_MEM_WRITE
iend
NUMBEROFSECTIONS equ ($ - SectionHeader) / IMAGE_SECTION_HEADER_size
SIZEOFHEADERS equ $ - IMAGEBASE

section progbits vstart=IMAGEBASE + SECTIONALIGN align=FILEALIGN
EntryPoint:

%endmacro


%macro _print 1
    push %1
    call [__imp__printf]
    add esp, 1*4
%endmacro


%macro _exit 1
    push %1 ; return code
    call [__imp__ExitProcess]
%endmacro

%macro _footer 0
Import_Descriptor:
istruc IMAGE_IMPORT_DESCRIPTOR
    at IMAGE_IMPORT_DESCRIPTOR.Name1,      dd kernel32.dll - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.FirstThunk, dd kernel32.dll_iat - IMAGEBASE
iend
istruc IMAGE_IMPORT_DESCRIPTOR
    at IMAGE_IMPORT_DESCRIPTOR.Name1,      dd msvcrt.dll - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.FirstThunk, dd msvcrt.dll_iat - IMAGEBASE
iend
istruc IMAGE_IMPORT_DESCRIPTOR ;terminator
iend

kernel32.dll_hintnames:
    dd hnExitProcess - IMAGEBASE
    dd 0
msvcrt.dll_hintnames:
    dd hnprintf - IMAGEBASE
    dd 0

hnExitProcess  db 0,0, 'ExitProcess', 0
hnprintf       db 0,0, 'printf', 0


kernel32.dll_iat:
__imp__ExitProcess:
    dd hnExitProcess - IMAGEBASE
    dd 0

msvcrt.dll_iat:
__imp__printf:
    dd hnprintf - IMAGEBASE
    dd 0

kernel32.dll db 'kernel32.dll', 0
msvcrt.dll db 'msvcrt.dll', 0


align SECTIONALIGN, db 0

%endmacro
%endif ; PE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

%ifdef MACHO

%macro _header 0
%include 'macho.inc'
istruc mach_header
    at mach_header.magic,       dd MH_MAGIC
    at mach_header.cputype,     dd CPU_TYPE_I386
    at mach_header.cpusubtype,  dd CPU_SUBTYPE_I386_ALL
    at mach_header.filetype,    dd MH_EXECUTE
    at mach_header.ncmds,       dd 2 ; 1 segment command + 1 thread command
    at mach_header.sizeofcmds,  dd SC_SIZE + TC_SIZE
    at mach_header.flags,       dd MH_NOUNDEFS
iend

sc:
istruc segment_command
    at segment_command.cmd,      dd LC_SEGMENT
    at segment_command.cmdsize,  dd SC_SIZE
    at segment_command.segname,  db "__TEXT"
    at segment_command.vmsize,   dd 1000h
    at segment_command.filesize, dd 64
    at segment_command.maxprot,  db _r + _w + _x
    at segment_command.initprot, dd _r + _x
iend
    SC_SIZE equ $ - sc

tc:
istruc thread_command
    at thread_command.cmd,      dd LC_UNIXTHREAD
    at thread_command.cmdsize,  dd TC_SIZE
    at thread_command.flavor,   dd x86_THREAD_STATE_32
    at thread_command.count,    dd STATE_SIZE >> 2
iend

state:
istruc i386_thread_state
    at i386_thread_state.eip, dd EntryPoint
iend
    STATE_SIZE equ $ - state

    TC_SIZE equ $ - tc

EntryPoint:
%endmacro

%macro _print 1
    push %1_LEN
    push %1
    push STDOUT
    mov al, SC_WRITE
    sub esp, 1 * 4
    int 80h
    add esp, 4 * 4
%endmacro

%macro _exit 1
    push %1
    mov al, SC_EXIT
    sub esp, 4
    int 80h
%endmacro

%macro _footer 0
%endmacro

%endif ; MACH-O ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

%macro _c 0
    int3
    align 16, int3
%endmacro

%macro _d 0
    db 0
    align 16, db 0
%endmacro

%macro _dprint 1
%ifdef DEBUG
    pusha
    _print %1
    popa
%endif
%endmacro

%macro _string 2+
%1:
    db %2
    %1_LEN equ $ - %1
    db 0
%endmacro

%macro _dstring 2+
%ifdef DEBUG
    _string %1, %2
%endif
%endmacro

%macro _ 0
    nop
%endmacro