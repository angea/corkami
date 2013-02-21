;custom import loader with a specific - non optimized - structure

%include '..\..\standard_hdr.asm'

OEP:
    push MB_ICONINFORMATION ; UINT uType
    push tada               ; LPCTSTR lpCaption
    push helloworld         ; LPCTSTR lpText
    push 0                  ; HWND hWnd
    call MessageBoxA
    push 0                  ; UINT uExitCode
    call ExitProcess
_c
tada db "Tada!", 0
helloworld db "Hello World!", 0
_d
MessageBoxA:
    jmp [iMessageBoxA]
ExitProcess:
    jmp [iExitProcess]
_c
EntryPoint:
;small import resolving stub, only works for imports by names
    pushad
    mov esi, my_imports_data
    mov edi, my_imports
dll_loop:
    lodsd
    test eax, eax
    jz imports_end
    push eax            ; LPCTSTR lpFileName
    call LoadLibraryA
    mov ebx, eax
api_loop:
    lodsd
    test eax, eax
    jz dll_loop
    push eax            ; HMODULE hModule
    push ebx            ; LPCSTR lpProcName
    call GetProcAddress
    stosd
    jmp api_loop
imports_end:
    popad
    jmp OEP
_d
my_imports:
iMessageBoxA:
    dd 0
iExitProcess:
    dd 0

my_imports_data:
    dd user32.dll
    dd aMessageBoxA
    dd 0

    dd kernel32.dll
    dd aExitProcess
    dd 0

    dd 0
_d
user32.dll db 'user32.dll', 0
aMessageBoxA db 'MessageBoxA',0
aExitProcess db 'ExitProcess', 0
_d
;%IMPORT kernel32.dll!GetProcAddress
;%IMPORT kernel32.dll!LoadLibraryA
_d
;%IMPORTS

%include '..\..\standard_ftr.asm'

;Ange Albertini, BSD Licence, 2010-2011
