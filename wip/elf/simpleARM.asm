; a simple ARM "Hello World!" ELF

; Ange Albertini, BSD Licence 2013

;%define ANDROID

BITS 32

%include 'consts.inc'

ELFBASE equ 08000000h

org ELFBASE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ELF Header

segment_start:

ehdr:
istruc Elf32_Ehdr
    at Elf32_Ehdr.e_ident
        EI_MAG     db 07Fh, "ELF"
        EI_CLASS   db ELFCLASS32
        EI_DATA    db ELFDATA2LSB
        EI_VERSION db EV_CURRENT
    at Elf32_Ehdr.e_type,      dw ET_EXEC
    at Elf32_Ehdr.e_machine,   dw EM_ARM
    at Elf32_Ehdr.e_version,   dd EV_CURRENT
    at Elf32_Ehdr.e_entry,     dd entry
    at Elf32_Ehdr.e_phoff,     dd phdr - ehdr
    at Elf32_Ehdr.e_shoff,     dd shdr - ehdr
    at Elf32_Ehdr.e_ehsize,    dw Elf32_Ehdr_size
    at Elf32_Ehdr.e_phentsize, dw Elf32_Phdr_size
    at Elf32_Ehdr.e_phnum,     dw PHNUM
    at Elf32_Ehdr.e_shentsize, dw Elf32_Shdr_size
    at Elf32_Ehdr.e_shnum,     dw SHNUM
    at Elf32_Ehdr.e_shstrndx,  dw SHSTRNDX
iend
align 16, db 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Program header table

phdr:
istruc Elf32_Phdr
    at Elf32_Phdr.p_type,   dd PT_LOAD
    at Elf32_Phdr.p_offset, dd segment_start - ehdr
    at Elf32_Phdr.p_vaddr,  dd ELFBASE
    at Elf32_Phdr.p_paddr,  dd ELFBASE
    at Elf32_Phdr.p_filesz, dd SEGMENT_SIZE
    at Elf32_Phdr.p_memsz,  dd SEGMENT_SIZE
    at Elf32_Phdr.p_flags,  dd PF_R + PF_X
iend
PHNUM equ ($ - phdr) / Elf32_Phdr_size

align 16, db 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; .text section (code)

%macro mov_r 2
    dd (0E3A0h << 16) | (%1 * 1000h) | %2
%endmacro

%macro adr 3
    dd (0E280h << 16) | (%2 * 10000h) | (%1 * 1000h) | %3
%endmacro

%macro swi 1
    dd (0EFh << 24) | %1
%endmacro

%macro syscall_ 1
%ifdef ANDROID
    mov_r _r7, %1
    swi   0
%else
 ; Raspberry Pi version
    swi   SYSCALLBASE + %1
%endif    
%endmacro

_r0 equ 0
_r1 equ 1
_r2 equ 2
_r7 equ 7
_pc equ 0fh

SYSCALLBASE equ 0900000h

text:
entry:
    mov_r _r0, STDOUT_FILENO
    adr   _r1, _pc, msg - $ - 8
    mov_r _r2, MSG_LEN
    syscall_ SC_WRITE

    mov_r _r0, 1 ; return code
    syscall_ SC_EXIT

TEXT_SIZE equ $ - text

align 16, db 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; .rodata section (read-only data)

rodata:

msg:
    db "Hello World!", 0ah
    MSG_LEN equ $ - msg

RODATA_SIZE equ $ - rodata

align 16, db 0

SEGMENT_SIZE equ $ - segment_start

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; .shtstrtab section (section names)

names:
anullstr  db 0
ashstrtab db ".shstrtab", 0
atext     db ".text", 0
arodata   db ".rodata", 0
NAMES_SIZE equ $ - names

align 16, db 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Section header table (optional)

shdr:

; section 0, always null
istruc Elf32_Shdr
    at Elf32_Shdr.sh_name,      dd anullstr - names
    at Elf32_Shdr.sh_type,      dd SHT_NULL
iend

istruc Elf32_Shdr
    at Elf32_Shdr.sh_name,      dd atext - names
    at Elf32_Shdr.sh_type,      dd SHT_PROGBITS
    at Elf32_Shdr.sh_flags,     dd SHF_ALLOC + SHF_EXECINSTR
    at Elf32_Shdr.sh_addr,      dd text
    at Elf32_Shdr.sh_offset,    dd text - ehdr
    at Elf32_Shdr.sh_size,      dd TEXT_SIZE
iend

istruc Elf32_Shdr
    at Elf32_Shdr.sh_name,      dd arodata - names
    at Elf32_Shdr.sh_type,      dd SHT_PROGBITS
    at Elf32_Shdr.sh_flags,     dd SHF_ALLOC
    at Elf32_Shdr.sh_addr,      dd rodata
    at Elf32_Shdr.sh_offset,    dd rodata - ehdr
    at Elf32_Shdr.sh_size,      dd RODATA_SIZE
iend

SHSTRNDX equ ($ - shdr) / Elf32_Shdr_size
istruc Elf32_Shdr
    at Elf32_Shdr.sh_name,      dd ashstrtab - names
    at Elf32_Shdr.sh_type,      dd SHT_STRTAB
    at Elf32_Shdr.sh_offset,    dd names - ehdr
    at Elf32_Shdr.sh_size,      dd NAMES_SIZE
iend

SHNUM equ ($ - shdr) / Elf32_Shdr_size

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
