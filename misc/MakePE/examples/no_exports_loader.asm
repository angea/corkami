%include '../onesec.hdr'

EntryPoint:
    push aDll           ; LPCTSTR lpFileName
    call LoadLibraryA
    push eax            ; HMODULE hModule
    call FreeLibrary
    push 0              ; UINT uExitCode
    call ExitProcess
;   retn

aExport db 'Export' , 0
aDll db 'no_exports.dll', 0

;%IMPORT kernel32.dll!LoadLibraryA
;%IMPORT kernel32.dll!FreeLibrary
;%IMPORT kernel32.dll!ExitProcess
;%IMPORTS

SECTION0SIZE EQU $ - Section0Start

SIZEOFIMAGE EQU $ - IMAGEBASE

; Ange Albertini 2009-2010