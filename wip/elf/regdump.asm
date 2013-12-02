; a ELF32 registers dumper

; Ange Albertini 2013 BSD Licence

BITS 32
ELFBASE equ 08048000h

%include 'consts.inc'

; position independant

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
    at Elf32_Ehdr.e_entry,     dd main - ehdr + ELFBASE
    at Elf32_Ehdr.e_phoff,     dd phdr - ehdr
    at Elf32_Ehdr.e_ehsize,    dw EHDRSIZE
    at Elf32_Ehdr.e_phentsize, dw PHDRSIZE
    at Elf32_Ehdr.e_phnum,     dw 1
iend
EHDRSIZE equ $ - ehdr

phdr:
istruc Elf32_Phdr
    at Elf32_Phdr.p_type,   dd PT_LOAD
    at Elf32_Phdr.p_vaddr,  dd ELFBASE
    at Elf32_Phdr.p_paddr,  dd ELFBASE
    at Elf32_Phdr.p_filesz, dd FILESIZE
    at Elf32_Phdr.p_memsz,  dd FILESIZE
    at Elf32_Phdr.p_flags,  dd PF_R + PF_W
    at Elf32_Phdr.p_align,  dd 1000h
iend 
PHDRSIZE equ $ - phdr

%macro printstr 2
    pusha
    mov edx, %2
    mov ecx, %1
    mov ebx, STDOUT
    mov eax, SC_WRITE
    int 80h
    popa
%endmacro

main:
    pusha
    pushf
    printstr header + ELFBASE - ehdr, HEADER_LEN

    printstr general + ELFBASE - ehdr, GENERAL_LEN

    call printpipes
    pop eax
    call print16

    mov cx, 8
printregloop:
    call printpipes
    pop eax
    call print32
    loop printregloop

    call printpipes
    call printreturn
    call printreturn

    printstr selectors + ELFBASE - ehdr, SEGMENTS_LEN

    call printpipes
    push cs
    pop ax
    call print16

    call printpipes
    push ds
    pop ax
    call print16

    call printpipes
    push es
    pop ax
    call print16

    call printpipes
    push fs
    pop ax
    call print16

    call printpipes
    push ss
    pop ax
    call print16

    call printpipes
    push gs
    pop ax
    call print16

    call printpipes
    call printreturn
    call printreturn

    printstr sysregs + ELFBASE - ehdr, SYSREGS_LEN

    call printpipes
    smsw eax
    call print32
    call printpipes

    sldt eax
    call print32
    call printpipes

    sgdt [_sgdt  + ELFBASE - ehdr]

    movzx eax, word [_sgdt + 4 + ELFBASE - ehdr]
    call print16
    mov eax, dword [_sgdt + ELFBASE - ehdr]
    call print32
    call printpipes

    sidt [_sidt + ELFBASE - ehdr]

    movzx eax, word [_sidt + 4 + ELFBASE - ehdr]
    call print16
    mov eax, dword [_sidt + ELFBASE - ehdr]
    call print32
    call printpipes


    str eax
    call print32
    call printpipes
    call printreturn

    xor eax, eax
    inc eax
    mov bl, 38
    int 80h

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

printhexnibble:
    pusha
    mov edx, 1
    mov ecx, hex + ELFBASE - ehdr
    and al, 0fh
    add cl, al
    mov ebx, STDOUT
    mov eax, SC_WRITE
    int 80h
    popa
    retn

print8:
    ror al, 4
    call printhexnibble
    ror al, 4
    call printhexnibble
    retn

print16:
    push ax
    ror ax, 8
    call print8
    ror ax, 8
    call print8
    pop ax
    retn

print32:
    push eax
    ror eax, 16
    call print16
    ror eax, 16
    call print16
    pop eax
    retn

printpipes:
    printstr pipes + ELFBASE - ehdr, PIPES_LEN
    retn

printreturn:
    printstr return + ELFBASE - ehdr, RETURN_LEN
    retn

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

align 10h, db 0
hex db "0123456789abcdef"

header:
    db "Register dumper ELF 0.1b - Ange Albertini - BSD Licence 2013", 0ah, 0ah
    HEADER_LEN equ $ - header

general:
    db " * general registers", 0ah
    db "|| Flags || EDI || ESI || EBP || ESP || EBX || EDX || ECX || EAX ||", 0ah
    GENERAL_LEN equ $ - general

selectors:
    db " * selectors", 0ah
    db "|| CS || DS || ES || FS || SS || GS ||", 0ah
    SEGMENTS_LEN equ $ - selectors

pipes db " || "
    PIPES_LEN equ $ - pipes

return db 0ah
    RETURN_LEN equ $ - return

sysregs db " * system registers", 0ah, "|| CR0 || LDT || GDT || IDT || Task Register ||", 0ah
    SYSREGS_LEN equ $ - sysregs

_sidt dq -1
_sgdt dq -1
_sldt dq -1

FILESIZE equ $ - ehdr
