; a simple ARM "Hello World!" ELF

; Ange Albertini, BSD Licence 2013

BITS 32

%include 'consts.inc'

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
    at Elf32_Ehdr.e_machine,   db EM_ARM
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
    at Elf32_Phdr.p_align,  dd 1000h
iend
PHNUM equ ($ - phdr) / Elf32_Phdr_size

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; .text section (code)

main:

%macro mov_r 2
    dd (0E3A0h << 16) | (%1 * 1000h) | %2
%endmacro

%macro adr 3
    dd (0E280h << 16) | (%2 * 10000h) | (%1 * 1000h) | %3
%endmacro

%macro swi 1
    dd (0EFh << 24) | %1
%endmacro

_r0 equ 0
_r1 equ 1
_r2 equ 2
_pc equ 0fh

    mov_r _r0, 0
    adr   _r1, _pc, msg - $ - 8
    mov_r _r2, MSG_LEN
    swi   0900004h
    mov_r _r0, 6
    swi   0900001h

MAIN_SIZE equ $ - main

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; .shtstrtab section (section names)

names:
    db 0
ashstrtab:
    db ".shstrtab", 0
atext:
    db ".text", 0
arodata:
    db ".rodata", 0
NAMES_SIZE equ $ - names

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; .rodata section (read-only data)
rodata:

align 2, db 0

msg:
    db "Hello World!", 0ah
    MSG_LEN equ $ - msg

RODATA_SIZE equ $ - rodata

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
    at Elf32_Shdr.sh_addralign, dd 1
iend

SHSTRNDX equ ($ - shdr) / Elf32_Shdr_size
istruc Elf32_Shdr
    at Elf32_Shdr.sh_name,      db ashstrtab - names
    at Elf32_Shdr.sh_type,      dw SHT_STRTAB
    at Elf32_Shdr.sh_offset,    dd names - ehdr
    at Elf32_Shdr.sh_size,      dd NAMES_SIZE
    at Elf32_Shdr.sh_addralign, dd 1
iend

istruc Elf32_Shdr
    at Elf32_Shdr.sh_name,      db arodata - names
    at Elf32_Shdr.sh_type,      dw SHT_PROGBITS
    at Elf32_Shdr.sh_flags,     dd SHF_ALLOC
    at Elf32_Shdr.sh_addr,      dd rodata
    at Elf32_Shdr.sh_offset,    dd rodata - ehdr
    at Elf32_Shdr.sh_size,      dd RODATA_SIZE
    at Elf32_Shdr.sh_addralign, dd 1
iend

SHNUM equ ($ - shdr) / Elf32_Shdr_size

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
