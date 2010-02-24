; imports loading with stolen bytes

%include '..\..\standard_hdr.asm'

%include 'entrypoint.inc'

MessageBoxA:
    mov edi,edi
    push ebp
    mov ebp,esp
    jmp [iMessageBoxA]
ExitProcess:
    mov edi,edi
    push ebp
    mov ebp,esp
    jmp [iExitProcess]
nop
LoadImports:
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
    push eax            ; LPCSTR lpProcName
    push ebx            ; HMODULE hModule
    call GetProcAddress

    add eax, 5          ; makes us skip 'mov edi,edi / push ebp / mov ebp,esp' of the API's start

    stosd
    jmp api_loop
imports_end:
    popad
    retn
nop
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

user32.dll db 'user32.dll', 0
aMessageBoxA db 'MessageBoxA',0
aExitProcess db 'ExitProcess', 0
nop
;%IMPORT kernel32.dll!GetProcAddress
;%IMPORT kernel32.dll!LoadLibraryA

;%IMPORTS

%include '..\..\standard_ftr.asm'

;Ange Albertini, Creative Commons BY, 2010