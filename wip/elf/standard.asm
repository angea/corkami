; initial version based on from Brian Raiter's http://www.muppetlabs.com/~breadbox/software/tiny/teensy.html

BITS 32
ELFBASE equ 08048000h

; position independant

ehdr: ; Elf32_Ehdr
  db 7fh, "ELF", 1, 1, 1, 0  ; e_ident
    times 8 db 0
  dw 2                       ; e_type
  dw 3                       ; e_machine
  dd 1                       ; e_version
  dd main - ehdr + ELFBASE   ; e_entry
  dd phdr - ehdr             ; e_phoff
  dd 0                       ; e_shoff
  dd 0                       ; e_flags
  dw EHDRSIZE                ; e_ehsize
  dw PHDRSIZE                ; e_phentsize
  dw 1                       ; e_phnum
  dw 0                       ; e_shentsize
  dw 0                       ; e_shnum
  dw 0                       ; e_shstrndx
    EHDRSIZE equ $ - ehdr

phdr: ; Elf32_Phdr
  dd 1        ; p_type
  dd 0        ; p_offset
  dd ELFBASE  ; p_vaddr
  dd ELFBASE  ; p_paddr
  dd FILESIZE ; p_filesz
  dd FILESIZE ; p_memsz
  dd 5        ; p_flags
  dd 1000h    ; p_align
    PHDRSIZE equ $ - phdr

main:
  mov edx, MSGLEN
  mov ecx, msg + ELFBASE - ehdr
  mov ebx, 1
  mov eax, 4
  int 80h

  xor eax, eax
  inc eax
  mov bl, 38
  int 80h

msg db " * a standard ELF", 0ah, 0
  MSGLEN equ $ - msg

FILESIZE equ $ - ehdr
