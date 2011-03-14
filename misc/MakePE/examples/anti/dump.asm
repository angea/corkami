; anti-dumping techniques

;Ange Albertini, BSD Licence, 2009-2011

%include '..\..\onesec.hdr'

EntryPoint:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; modify the module's SizeOfImage

    getPEB eax
    mov eax, [eax + PEB.LoaderData]
    mov eax, [eax + PEB_LDR_DATA.InLoadOrderModuleList]
    add dword [eax + LDR_MODULE.SizeOfImage], 1000h

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; erase the PE header in memory

    ;get image base
    push 0
    call GetModuleHandleA

    ; setting priorities
    push eax
    push dummy
    push PAGE_READWRITE
    push 1                                  ; the OS will round it up
    push eax
    mov edi, eax
    call VirtualProtect

    ; filling with zeroes
    mov al, 0
    mov ecx, 150h
    rep stosb

    push MB_ICONINFORMATION ; UINT uType
    push tada               ; LPCTSTR lpCaption
    push helloworld         ; LPCTSTR lpText
    push 0                  ; HWND hWnd
    call MessageBoxA
    push 0                  ; UINT uExitCode
    call ExitProcess

dummy dd 0

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess
;%IMPORT kernel32.dll!GetModuleHandleA
;%IMPORT kernel32.dll!VirtualProtect

tada db "Tada!", 0
helloworld db "Hello World!", 0

;%IMPORTS

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE
