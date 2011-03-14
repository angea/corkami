; empty entry point file, looks buggy as much as possible
; but TLS is allocating memory at offset 0, so ADD EAX, [AL] will be valid

%include '../../onesec.hdr'


stub:
    push MB_ICONINFORMATION     ; UINT uType
    push aEntryPoint            ; LPCTSTR lpCaption
    push helloworld             ; LPCTSTR lpText
    push 0                      ; HWND hWnd
    call MessageBoxA
    push 0                      ; UINT uExitCode
    call ExitProcess
_c

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess
_c
aEntryPoint db "Entry Point", 0
helloworld db "Hello World!", 0
_d

MEM_RESERVE               equ 2000h
MEM_TOP_DOWN              equ 100000h
TLS:
    push PAGE_READWRITE     ; ULONG Protect
    push MEM_RESERVE|MEM_COMMIT|MEM_TOP_DOWN     ; ULONG AllocationType
    push zwsize             ; PSIZE_T RegionSize
    push 0                  ; ULONG_PTR ZeroBits
    push lpBuffer3          ; PVOID *BaseAddress
    push -1                 ; HANDLE ProcessHandle
    call ZwAllocateVirtualMemory
    retn
_c

;%IMPORT ntdll.dll!ZwAllocateVirtualMemory
_c

lpBuffer3 dd 1
zwsize dd 1000h
Image_Tls_Directory32:
    StartAddressOfRawData dd Characteristics ; VA, should point to something null
    EndAddressOfRawData   dd Characteristics ; VA, should point to something null
    AddressOfIndex        dd Characteristics ; VA, should point to something null
    AddressOfCallBacks    dd SizeOfZeroFill
    SizeOfZeroFill        dd TLS
    Characteristics       dd 0
_d

;Can't be in headers
;%IMPORTS
_d

EntryPoint:
    times 100h add [eax], al
    jmp stub
_c

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE

; Ange Albertini, Creative Commons BY, 2010