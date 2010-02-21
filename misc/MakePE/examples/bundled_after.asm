; open an external data file, and use the content to display a messagebox
; the external data file has been bundled in the binary itself,
; so extra code before the OEP install hooks on file-handling apis

%include '..\standard_hdr.asm'

EntryPoint:
    call hook
%include 'bundled.inc'

hook:
    mov dword [__imp__CreateFileA], CreateFileA_hook
    mov dword [__imp__ReadFile], ReadFile_hook
    mov dword [__imp__CloseHandle], CloseHandle_hook
    retn

CreateFileA_hook:
    retn 7 * 4

ReadFile_hook:
    pushad
    mov edi, [esp + 8 + 20h]
    mov ecx, [esp + 0ch + 20h]
    mov esi, Bundled
    rep movsb
    popad
    retn 5 * 4

CloseHandle_hook:
    retn 1 * 4

;%IMPORT kernel32.dll!CreateFileA
;%IMPORT kernel32.dll!ReadFile
;%IMPORT kernel32.dll!CloseHandle

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess

;%IMPORTS

Bundled:
    incbin 'bundled.dat'

%include '../standard_ftr.asm'

;Ange Albertini, Creative Commons BY, 2010