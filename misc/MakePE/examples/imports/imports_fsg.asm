;FSG (real packer, thus optimized) style of imports loading

%include '..\..\standard_hdr.asm'

%include 'entrypoint.inc'

MessageBoxA:
    jmp [iMessageBoxA]
ExitProcess:
    jmp [iExitProcess]

LoadImports:
    mov esi, import_table
next_dll:
    lodsd
    xchg eax,edi
    lodsd
    push eax            ; LPCTSTR lpFileName
    call LoadLibraryA
    xchg eax,ebp
next_entry:
    mov eax, [edi]
    inc eax
    js next_dll
    jnz next_api

    retn
next_api:
    push eax            ; LPCSTR lpProcName
    push ebp            ; HMODULE hModule  
    call GetProcAddress
    stosd
    jmp next_entry
nop
szMessageBoxA db 0,'MessageBoxA',0
aUser32_dll	db 'user32.dll',0
szExitProcess	db 0,'ExitProcess',0

NO_DLLS EQU 080000000h
NO_APIS EQU NO_DLLS - 1

nop
import_table:
    dd user32_apis
    dd aUser32_dll
    dd kernel32_apis
    dd kernel32.dll

kernel32_apis:
iExitProcess dd szExitProcess
    dd NO_APIS + NO_DLLS

user32_apis:
iMessageBoxA dd szMessageBoxA
    dd NO_APIS
nop
;%IMPORT kernel32.dll!GetProcAddress
;%IMPORT kernel32.dll!LoadLibraryA
nop
;%IMPORTS

%include '..\..\standard_ftr.asm'

;Ange Albertini, Creative Commons BY, 2010