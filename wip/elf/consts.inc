ELFCLASS32 equ 1
ELFCLASS64 equ 2

ELFDATA2LSB equ 1

EV_CURRENT equ 1

EI_NIDENT equ 16

ET_EXEC equ 2

EM_386 equ 3
EM_ARM equ 28h
EM_AMD64 equ 3eh

struc Elf32_Ehdr
    .e_ident     resb EI_NIDENT
    .e_type      resw 1
    .e_machine   resw 1
    .e_version   resd 1
    .e_entry     resd 1
    .e_phoff     resd 1
    .e_shoff     resd 1
    .e_flags     resd 1
    .e_ehsize    resw 1
    .e_phentsize resw 1
    .e_phnum     resw 1
    .e_shentsize resw 1
    .e_shnum     resw 1
    .e_shstrndx  resw 1
endstruc

struc Elf64_Ehdr
    .e_ident     resb EI_NIDENT
    .e_type      resw 1
    .e_machine   resw 1
    .e_version   resd 1
    .e_entry     resq 1
    .e_phoff     resq 1
    .e_shoff     resq 1
    .e_flags     resd 1
    .e_ehsize    resw 1
    .e_phentsize resw 1
    .e_phnum     resw 1
    .e_shentsize resw 1
    .e_shnum     resw 1
    .e_shstrndx  resw 1
endstruc

PT_LOAD equ 1

PF_X equ 1
PF_W equ 2
PF_R equ 4

struc Elf32_Phdr
    .p_type   resd 1
    .p_offset resd 1
    .p_vaddr  resd 1
    .p_paddr  resd 1
    .p_filesz resd 1
    .p_memsz  resd 1
    .p_flags  resd 1
    .p_align  resd 1
endstruc

struc Elf64_Phdr
    .p_type   resd 1
    .p_flags  resd 1
    .p_offset resq 1
    .p_vaddr  resq 1
    .p_paddr  resq 1
    .p_filesz resq 1
    .p_memsz  resq 1
    .p_align  resq 1
endstruc

SHT_NULL equ 0
SHT_PROGBITS equ 1
SHT_STRTAB equ 3

SHF_ALLOC equ 2
SHF_EXECINSTR equ 4

struc Elf32_Shdr
    .sh_name      resd 1
    .sh_type      resd 1
    .sh_flags     resd 1
    .sh_addr      resd 1
    .sh_offset    resd 1
    .sh_size      resd 1
    .sh_link      resd 1
    .sh_info      resd 1
    .sh_addralign resd 1
    .sh_entsize   resd 1
endstruc

struc Elf64_Shdr
    .sh_name      resd 1
    .sh_type      resd 1
    .sh_flags     resq 1
    .sh_addr      resq 1
    .sh_offset    resq 1
    .sh_size      resq 1
    .sh_link      resd 1
    .sh_info      resd 1
    .sh_addralign resq 1
    .sh_entsize   resq 1
endstruc

SC_EXIT equ 1
SC_WRITE equ 4

sys_write equ 1
sys_exit equ 60

STDOUT equ 1
