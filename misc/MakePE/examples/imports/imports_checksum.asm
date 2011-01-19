; import-less file, with imports loading by checksum
; some versions of windows might refuse an import-less file to load

%include '..\..\standard_hdr.asm'

%include 'entrypoint.inc'

;generated with api_hash.py

LOADLIBRARYA equ 06FFFE488h

EXITPROCESS equ 031678333h
MESSAGEBOXA equ 021CB7926h

LoadImports:

; Locate Kernel32.dll imagebase
    mov eax,[fs:030h]   ; _TIB.PebPtr
    mov eax,[eax + 0ch] ; _PEB.Ldr
    mov eax,[eax + 0ch] ; _PEB_LDR_DATA.InLoadOrderModuleList.Flink
    mov eax,[eax]       ; _LDR_MODULE.InLoadOrderModuleList.Flink
    mov eax,[eax]       ; _LDR_MODULE.InLoadOrderModuleList.Flink
    mov eax,[eax + 18h] ; _LDR_MODULE.BaseAddress

;   brutal way, not as much compatible
;   mov eax, [esp + 4]
;   and eax, 0fff00000h

    mov [hKernel32], eax

    mov eax, [hKernel32]
    mov ebx, LOADLIBRARYA
    call GetProcAddress_Hash
    mov [ddLoadLibrary], ebx

    mov eax, [hKernel32]
    mov ebx, EXITPROCESS
    call GetProcAddress_Hash
    mov [ddExitProcess], ebx

    push szuser32
    call [ddLoadLibrary]
    mov [hUser32], eax

    ; mov eax, [hUser32]
    mov ebx, MESSAGEBOXA
    call GetProcAddress_Hash
    mov [ddMessageBoxA], ebx

    retn
nop
MessageBoxA:
    jmp [ddMessageBoxA]
ExitProcess:
    jmp [ddExitProcess]

nop
szuser32 db "user32.dll", 0

ddMessageBoxA dd 0
ddExitProcess dd 0
hKernel32 dd 0
hUser32 dd 0

ddLoadLibrary dd 0

DOS_HEADER__e_lfanew equ 03ch

NT_SIGNATURE__IMAGE_DIRECTORY_ENTRY_EXPORT__RVA equ 78h

Exports__NumberOfNames      EQU 018h
Exports__AddressOfFunctions EQU 01ch
Exports__AddressOfNames     EQU 020h
Exports__AddressOfNamesOrdinal EQU 024h


GetProcAddress_Hash:
    mov [ImageBase], eax
    mov [checksum], ebx
    mov ebp, [ImageBase]
    ; ebp = PE start / ImageBase
    mov edx, [ebp + DOS_HEADER__e_lfanew] ; e_lfanew = RVA of NT_SIGNATURE
    add edx, [ImageBase]    ; RVA to VA
        ; => eax = NT_SIGNATURE VA

    mov edx, [edx + NT_SIGNATURE__IMAGE_DIRECTORY_ENTRY_EXPORT__RVA]  ; IMAGE_DIRECTORY_ENTRY_EXPORT (.RVA) - NT_SIGNATURE
    add edx, [ImageBase]    ; RVA to VA
        ; => edx = IMAGE_DIRECTORY_ENTRY_EXPORT VA
    mov [ExportDirectory], edx

    mov ecx, [edx + Exports__NumberOfNames] ; NumberOfNames

    mov ebx, [edx + Exports__AddressOfNames] ; AddressOfNames
    add ebx, [ImageBase]    ; RVA to VA

next_name:
    test ecx, ecx
    jz no_more_exports
    dec ecx

    mov esi, [ebx + ecx * 4]
    add esi, [ImageBase] ; RVA to VA


    mov edi, 0

checksum_loop:
    xor eax, eax
    lodsb

    rol edi, 7
    add edi, eax

    test al, al
    jnz checksum_loop

    cmp edi, [checksum]
    jnz next_name

    mov ebx, [edx + Exports__AddressOfNamesOrdinal] ; AddressOfNamesOrdinal RVA
    add ebx, [ImageBase]

    mov cx, [ebx + ecx * 2]

    mov ebx, [edx + Exports__AddressOfFunctions] ; AddressOfFunctions RVA
    add ebx, [ImageBase]
    mov ebx, [ebx + ecx * 4] ; Functions RVA
    add ebx, [ImageBase]

    jmp _end
no_more_exports:
    xor ebx, ebx
_end:
    retn

checksum dd 0
ImageBase dd 0
char db 0
ExportDirectory dd 0

IMPORT_DESCRIPTOR equ IMAGEBASE
DIRECTORY_ENTRY_IMPORT_SIZE equ 0

%include '..\..\standard_ftr.asm'

;Ange Albertini, Creative Commons BY, 2010