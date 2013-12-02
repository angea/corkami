; an ELF with dummy section names

; Ange Albertini, BSD Licence 2013

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
    at Elf32_Ehdr.e_machine,   dw EM_386
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

text:
entry:
    mov ecx, msg
    mov edx, MSG_LEN
    mov ebx, STDOUT_FILENO

    mov eax, SC_WRITE
    int 80h


    mov ebx, 1 ; return code

    mov eax, SC_EXIT
    int 80h

TEXT_SIZE equ $ - text

align 16, db 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; .rodata section (read-only data)

rodata:

msg:
    db " * an ELF with dummy section names", 0ah
    MSG_LEN equ $ - msg

RODATA_SIZE equ $ - rodata

align 16, db 0

SEGMENT_SIZE equ $ - segment_start

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; .shtstrtab section (section names)

names:
anullstr  db ".plt", 0
ashstrtab db ".init", 0
atext     db ".got.plt", 0
arodata   db ".got", 0
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
