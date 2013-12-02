; initial version based on from Brian Raiter's http://www.muppetlabs.com/~breadbox/software/tiny/teensy.html

BITS 32
ELFBASE equ 10000h

; position independant

ehdr: ; Elf32_Ehdr
    db 7fh, "ELF"             ; e_ident
    dd 1                                  ; p_type
    dd 0                                  ; p_offset
    dd ehdr + ELFBASE                     ; p_vaddr
    dw 2                      ; e_type    ; p_addr
    dw 3                      ; e_machine
    dd main - ehdr + ELFBASE  ; e_version ; p_filesz
    dd main - ehdr + ELFBASE  ; e_entry   ; p_memsz
    dd 4                      ; e_phoff   ; p_flags
main:
    mov bl, 42
    xor eax, eax
    inc eax
    int 80h

    db 0
    dw 34h                    ; e_ehsize
    dw 20h                    ; e_phentsize
    db 1                      ; e_phnum
                              ; e_shentsize
                              ; e_shnum
                              ; e_shstrndx
FILESIZE equ $ - ehdr
