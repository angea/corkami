;small crash trap generator
;creates a random space with no info about its origins

;Ange Albertini, BSD licence, 2011

%include '..\..\onesec.hdr'

randw:
    push edx
    rdtsc
    push eax
    rdtsc
    pop edx
    rol edx, 8
    xor eax, edx
    pop edx
    retn
_c

randd:
    push ecx
    call randw
    movzx ecx, ax
    bswap ecx
    call randw
    mov cx, ax
    mov eax, ecx
    pop ecx
    retn
_c

letsgocrazy:
    push PAGE_READWRITE     ; DWORD flProtect
    push MEM_COMMIT         ; DWORD flAllocationType
    push 1000h    ; SIZE_T dwSize
    push 0                  ; LPVOID lpAddress
    call VirtualAlloc

    mov [hBuffer], eax
    mov [target], eax
    mov ecx, 1000h / 2
    mov edi, eax
_randloop:
    call randw
    stosw
    loop _randloop

    call randw
    and eax, 2047
    add eax, 20h
    mov [delta], eax

    call randw
    and eax, 4095
    add [target], eax

    pushf
    pusha
    mov esp, [hBuffer]
    add esp, [delta]
    sub esp, 20h
    popa
    jmp rethere
_c

EntryPoint:
    call letsgocrazy
rethere:
    jmp [target]
_c

;%IMPORT kernel32.dll!VirtualAlloc
_c

;%IMPORTS
_c

hBuffer dd 0
delta dd 0
target dd 0

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE

