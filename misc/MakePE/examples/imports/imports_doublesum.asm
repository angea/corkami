; text-less imports, files and api are hashes-based.
; the right file is located by scanning the %SYSTEM% directory and matching each dll filename with a checksum

%include '..\..\standard_hdr.asm'

EntryPoint:
    push MB_ICONINFORMATION ; UINT uType
    push tada               ; LPCTSTR lpCaption
    push helloworld         ; LPCTSTR lpText
    push 0                  ; HWND hWnd
    call MessageBoxA

    push 0                  ; UINT uExitCode
    call ExitProcess

tada db "Tada!", 0
helloworld db "Hello World!", 0

KERNEL32_DLL equ 05930C06Ah
USER32_DLL equ 0D280212Ch

_EXITPROCESS equ 031678333h
_MESSAGEBOXA equ 021CB7926h

MessageBoxA:
    push USER32_DLL
    push _MESSAGEBOXA
    jmp ImportAndCall

ExitProcess:
    push KERNEL32_DLL
    push _EXITPROCESS
    jmp ImportAndCall

_LOADLIBRARYA equ 06FFFE488h
_GETMODULEHANDLEA equ 0226F513Fh
_GETSYSTEMDIRECTORYA equ 011DB9E25h
_FINDFIRSTFILEA equ 0DF6DC586h
_FINDNEXTFILEA equ 03A290BE0h

MAX_PATH equ 260

ImportAndCall:
    pusha

    ; were we already called ?
    cmp dword [hKernel32], 0
    jnz already_ran
    ; we need kernel32 address and get the system directory + dll mask

    ; Locate Kernel32.dll imagebase
    mov eax,[fs:030h]   ; _TIB.PebPtr
    mov eax,[eax + 0ch] ; _PEB.Ldr
    mov eax,[eax + 0ch] ; _PEB_LDR_DATA.InLoadOrderModuleList.Flink
    mov eax,[eax]       ; _LDR_MODULE.InLoadOrderModuleList.Flink ; CHECKME
    mov eax,[eax]       ; _LDR_MODULE.InLoadOrderModuleList.Flink
    mov eax,[eax + 18h] ; _LDR_MODULE.BaseAddress

    mov [hKernel32], eax

nop
    push MAX_PATH
    push Buffer
        mov eax, [hKernel32]
        mov ebx, _GETSYSTEMDIRECTORYA
        call GetProcAddress_Hash
    call ebx

    mov edi, Buffer
    add edi, eax
    mov esi, Mask
    mov cl, 7
    rep movsb

nop
already_ran:
    mov eax, dword [esp + 20h + 4]
    mov [filesum], eax

    push WIN32_FIND_DATA
    push Buffer
        mov eax, [hKernel32]
        mov ebx, _FINDFIRSTFILEA
        call GetProcAddress_Hash
    call ebx
    mov [hFind], eax
nop
filecheck:
    mov esi, WIN32_FIND_DATA.cFileName
    mov edx, 0
nop
case_loop:
    xor eax, eax
    lodsb

    ; lowercase checksum
    mov bl, al
    or al, 20h

    rol edx, 7
    add edx, eax

    test bl, bl
    jnz case_loop

    cmp edx, [filesum]
    jz found


    push WIN32_FIND_DATA
    push dword [hFind]
        mov eax, [hKernel32]
        mov ebx, _FINDNEXTFILEA
        call GetProcAddress_Hash
    call ebx
    jmp filecheck
nop
found:

    push WIN32_FIND_DATA.cFileName
        mov eax, [hKernel32]
        mov ebx, _GETMODULEHANDLEA
        call GetProcAddress_Hash
    call ebx
    test eax, eax
    jnz dll_loaded
nop
    push WIN32_FIND_DATA.cFileName
        mov eax, [hKernel32]
        mov ebx, _LOADLIBRARYA
        call GetProcAddress_Hash
    call ebx
nop
dll_loaded:
    mov ebx, [esp + 20h]    ; +20h because of the PUSHA
    call GetProcAddress_Hash
    mov [dApi], ebx
    popa

    add esp, 2 * 4
    pop dword [dReturn]
    call [dApi]
    jmp [dReturn]


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

hKernel32 dd 0
dApi dd 0
dReturn dd 0

Mask db "\*.dll", 0
hFind dd 0

Buffer times MAX_PATH db 0

WIN32_FIND_DATA:
  .dwFileAttributes      dd 0
  .ftCreationTime        dd 0,0
  .ftLastAccessTime      dd 0,0
  .ftLastWriteTime       dd 0,0
  .nFileSizeHigh         dd 0
  .nFileSizeLow          dd 0
  .dwReserved0           dd 0
  .dwReserved1           dd 0
  .cFileName             times MAX_PATH db 0
  .cAlternate            times 14 db 0

DOS_HEADER__e_lfanew equ 03ch

NT_SIGNATURE__IMAGE_DIRECTORY_ENTRY_EXPORT__RVA equ 78h

Exports__NumberOfNames      EQU 018h
Exports__AddressOfFunctions EQU 01ch
Exports__AddressOfNames     EQU 020h
Exports__AddressOfNamesOrdinal EQU 024h


checksum dd 0
filesum dd 0
ImageBase dd 0
ExportDirectory dd 0

IMPORT_DESCRIPTOR equ IMAGEBASE
DIRECTORY_ENTRY_IMPORT_SIZE equ 0

%include '..\..\standard_ftr.asm'

;Ange Albertini, Creative Commons BY, 2010