;FSG (real packer, thus optimized) style of imports loading

%include '..\..\standard_hdr.asm'

OEP:
    push MB_ICONINFORMATION ; UINT uType
    push tada               ; LPCTSTR lpCaption
    push helloworld         ; LPCTSTR lpText
    push 0                  ; HWND hWnd
    call MessageBoxA
    push 0                  ; UINT uExitCode
    Call ExitProcess
_c
MessageBoxA:
    jmp [iMessageBoxA]
ExitProcess:
    jmp [iExitProcess]
_d
tada db "Tada!", 0
helloworld db "Hello World!", 0
_d

EntryPoint:
    mov esi, import_table
_
next_dll:
    lodsd
    xchg eax,edi
    lodsd
    push eax            ; LPCTSTR lpFileName
    call LoadLibraryA
    xchg eax,ebp
_
next_entry:
    mov eax, [edi]
    inc eax
    js next_dll
    jnz next_api

    jmp OEP
_
next_api:
    push eax            ; LPCSTR lpProcName
    push ebp            ; HMODULE hModule
    call GetProcAddress
    stosd
    jmp next_entry
_c
;%IMPORT kernel32.dll!GetProcAddress
;%IMPORT kernel32.dll!LoadLibraryA
_d
szMessageBoxA db 0,'MessageBoxA',0
aUser32_dll	db 'user32.dll',0
szExitProcess	db 0,'ExitProcess',0

NO_DLLS EQU 080000000h
NO_APIS EQU NO_DLLS - 1

_d
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
_d
;%IMPORTS

%include '..\..\standard_ftr.asm'

;Ange Albertini, BSD Licence, 2010-2011