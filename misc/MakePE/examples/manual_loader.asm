%include '..\standard_hdr.asm'

EntryPoint:
    push aDll           ; LPCTSTR lpFileName
    call LoadLibraryA

    mov [hDLL], eax

    push dword [hDLL]
    call FreeLibrary    ; will actually work because the lib has been loaded manually
    cmp eax, 1
    jnz bad

    push aExport        ; HMODULE hModule
    push dword [hDLL]   ; LPCSTR lpProcName
    call GetProcAddress
    cmp eax, 0          ; importing fails, the lib is indeed not in memory anymore
    jnz bad

    push aDll           ; LPCTSTR lpFileName
    call LoadLibraryA
    push aExport        ; HMODULE hModule
    push eax            ; LPCSTR lpProcName
    call GetProcAddress
    call eax
    ;jmp good


%include 'goodbad.inc'
;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess

aExport db 'Export' , 0
aDll db 'dll.dll', 0
hDLL dd 0


;%IMPORT kernel32.dll!LoadLibraryA
;%IMPORT kernel32.dll!GetProcAddress

;%IMPORT kernel32.dll!FreeLibrary

;%IMPORTS

%include '..\standard_ftr.asm'
