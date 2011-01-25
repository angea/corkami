;relative ip code

;in IDA
;Select instructions
;type Ctrl-R
;set 'Base Address'
;select 'Treat the base address as a plain number'
;click 'Ok'
;optionally select 'All operands'
;click 'Ok'

%include '..\..\onesec.hdr'

DELTA equ IMAGEBASE

EntryPoint:
    push PAGE_READWRITE     ; DWORD flProtect
    push MEM_COMMIT         ; DWORD flAllocationType
    push end_ - start_  ; SIZE_T dwSize
    push 0                  ; LPVOID lpAddress
    call VirtualAlloc
    push eax

    mov esi, start_
    mov edi, eax
    mov ecx, end_ - start_
    rep movsb
    retn

start_:
    call $ + 5
ip_here:
    pop ebp
    sub ebp, ip_here - DELTA


    push MB_ICONINFORMATION ; UINT uType
    lea eax, [ebp + tada - DELTA]                 ; LPCTSTR lpCaption
    push eax
    lea eax, [ebp + helloworld - DELTA]         ; LPCTSTR lpText
    push eax
    push 0                  ; HWND hWnd
    call [ebp - DELTA + __imp__MessageBoxA]
    push 0                  ; UINT uExitCode
    call [ebp - DELTA + __imp__ExitProcess]


tada db "Tada!", 0
helloworld db "Hello World!", 0

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!VirtualAlloc
;%IMPORT kernel32.dll!ExitProcess

;%IMPORTS

end_:

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE

;Ange Albertini, Creative Commons BY, 2009-2010
