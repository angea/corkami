; a simple 64-bit "Hello World!" ELF

; Ange Albertini, BSD Licence 2013

BITS 64

%include 'consts.inc'

ELFBASE equ 010000000h

org ELFBASE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ELF Header

segment_start:

ehdr:
istruc Elf64_Ehdr
    at Elf64_Ehdr.e_ident
        EI_MAG     db 07Fh, "ELF"
        EI_CLASS   db ELFCLASS64
        EI_DATA    db ELFDATA2LSB
        EI_VERSION db EV_CURRENT
    at Elf64_Ehdr.e_type,      dw ET_EXEC
    at Elf64_Ehdr.e_machine,   dw EM_AMD64
    at Elf64_Ehdr.e_version,   dd EV_CURRENT
    at Elf64_Ehdr.e_entry,     dq entry
    at Elf64_Ehdr.e_phoff,     dq phdr - ehdr
    at Elf64_Ehdr.e_shoff,     dq shdr - ehdr
    at Elf64_Ehdr.e_ehsize,    dw Elf64_Ehdr_size
    at Elf64_Ehdr.e_phentsize, dw Elf64_Phdr_size
    at Elf64_Ehdr.e_phnum,     dw PHNUM
    at Elf64_Ehdr.e_shentsize, dw Elf64_Shdr_size
    at Elf64_Ehdr.e_shnum,     dw SHNUM
    at Elf64_Ehdr.e_shstrndx,  dw SHSTRNDX
iend
align 16, db 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Program header table

phdr:
istruc Elf64_Phdr
    at Elf64_Phdr.p_type,   dd PT_LOAD
    at Elf64_Phdr.p_flags,  dd PF_R + PF_X
    at Elf64_Phdr.p_offset, dd segment_start - ehdr
    at Elf64_Phdr.p_vaddr,  dq ELFBASE
    at Elf64_Phdr.p_paddr,  dq ELFBASE
    at Elf64_Phdr.p_filesz, dq SEGMENT_SIZE
    at Elf64_Phdr.p_memsz,  dq SEGMENT_SIZE
iend
PHNUM equ ($ - phdr) / Elf64_Phdr_size

align 16, db 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; .text section (code)

text:
entry:
    mov rsi, msg
    mov rdx, MSG_LEN
    mov rdi, STDOUT

    mov rax, sys_write
    syscall


    mov rdi, 1 ; return code

    mov rax, sys_exit
    syscall

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
istruc Elf64_Shdr
    at Elf64_Shdr.sh_name,      dd anullstr - names
    at Elf64_Shdr.sh_type,      dd SHT_NULL
iend

istruc Elf64_Shdr
    at Elf64_Shdr.sh_name,      dd atext - names
    at Elf64_Shdr.sh_type,      dd SHT_PROGBITS
    at Elf64_Shdr.sh_flags,     dq SHF_ALLOC + SHF_EXECINSTR
    at Elf64_Shdr.sh_addr,      dq text
    at Elf64_Shdr.sh_offset,    dq text - ehdr
    at Elf64_Shdr.sh_size,      dq TEXT_SIZE
iend

istruc Elf64_Shdr
    at Elf64_Shdr.sh_name,      dd arodata - names
    at Elf64_Shdr.sh_type,      dd SHT_PROGBITS
    at Elf64_Shdr.sh_flags,     dq SHF_ALLOC
    at Elf64_Shdr.sh_addr,      dq rodata
    at Elf64_Shdr.sh_offset,    dq rodata - ehdr
    at Elf64_Shdr.sh_size,      dq RODATA_SIZE
iend

SHSTRNDX equ ($ - shdr) / Elf64_Shdr_size
istruc Elf64_Shdr
    at Elf64_Shdr.sh_name,      dd ashstrtab - names
    at Elf64_Shdr.sh_type,      dd SHT_STRTAB
    at Elf64_Shdr.sh_offset,    dq names - ehdr
    at Elf64_Shdr.sh_size,      dq NAMES_SIZE
iend

SHNUM equ ($ - shdr) / Elf64_Shdr_size

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
