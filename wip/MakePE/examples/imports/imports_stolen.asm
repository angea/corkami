; imports loading with stolen bytes

%include '..\..\standard_hdr.asm'

EntryPoint:
    call steal_imports
    push MB_ICONINFORMATION ; UINT uType
    push tada               ; LPCTSTR lpCaption
    push helloworld         ; LPCTSTR lpText
    push 0                  ; HWND hWnd
    call MessageBoxA
    push 0                  ; UINT uExitCode
    call ExitProcess
_c

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess
_c

tada db "Tada!", 0
helloworld db "Hello World!", 0
_d

steal_imports:
    pushad
    push dword [__imp__ExitProcess]
    push dword [__imp__MessageBoxA]

    mov al, 0
    mov edi, ImportAddressTable
    mov ecx, DIRECTORY_ENTRY_IMPORT_SIZE
    rep stosb

    pop eax
    add eax, 5
    mov [_stolen_MessageBoxA], eax

    mov dword [__imp__MessageBoxA], _MessageBoxA

    pop eax
    add eax, 5
    mov [_stolen_ExitProcess], eax

    mov dword [__imp__ExitProcess], _ExitProcess
_
    popad
    retn
_c

_MessageBoxA:
    mov edi,edi
    push ebp
    mov ebp,esp
    jmp [_stolen_MessageBoxA]
_c

_ExitProcess:
    mov edi,edi
    push ebp
    mov ebp,esp
    jmp [_stolen_ExitProcess]
_c

_stolen_MessageBoxA dd 0
_stolen_ExitProcess dd 0
_d

;%IMPORTS
_d

%include '..\..\standard_ftr.asm'

;Ange Albertini, BSD Licence, 2010-2011