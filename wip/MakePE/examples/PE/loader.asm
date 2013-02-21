%include '..\..\standard_hdr.asm'

EntryPoint:
    push dll.dll
    call GetModuleHandleA
    mov [hDLL], eax

    push dword [hDLL]
    call FreeLibrary
    cmp eax, 1
    jnz bad
 
    push aExport        ; HMODULE hModule
    push dword [hDLL]   ; LPCSTR lpProcName
    call GetProcAddress
    cmp eax, 0          ; importing fails, the lib is indeed not in memory anymore
    jz bad

    call Export
;   jmp good

%include '..\goodbad.inc'

aExport db 'Export' , 0
hDLL dd 0

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess

;%IMPORT dll.dll!Export


;%IMPORT kernel32.dll!GetModuleHandleA
;%IMPORT kernel32.dll!GetProcAddress
;%IMPORT kernel32.dll!FreeLibrary
;%IMPORTS

%include '..\..\standard_ftr.asm'

;Ange Albertini, Creative Commons BY, 2010
