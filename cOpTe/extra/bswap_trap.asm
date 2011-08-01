;simple bswap trap
;
; if a bswap <reg16> is statically analyzed as a bswap <reg32>,
; the wrong path will be determined
;
; Ange Albertini, BSD Licence 2011

%include '../header.inc'

MEM_RESERVE        equ 2000h
MEM_TOP_DOWN       equ 100000h
MB_ICONINFORMATION equ 040h

BASE equ 00c100000h


EntryPoint:
    mov eax, BASE + 4000h
db 66h
    bswap eax
    jmp eax
_c

good:
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

;%IMPORTS

times 100  db 0

setup:
    pushad
    pushf
    push PAGE_READWRITE     ; ULONG Protect
    push MEM_RESERVE|MEM_COMMIT|MEM_TOP_DOWN     ; ULONG AllocationType
    push zwsize             ; PSIZE_T RegionSize
    push 0                  ; ULONG_PTR ZeroBits
    push lpBuffer3          ; PVOID *BaseAddress
    push -1                 ; HANDLE ProcessHandle
    call ZwAllocateVirtualMemory

    mov edi, BASE
    mov esi, bad
    mov ecx, badsize
    rep movsb

    popf
    popad
    retn

;%IMPORT ntdll.dll!ZwAllocateVirtualMemory

zwsize dd 0ffffh
lpBuffer3 dd BASE

bad:
    push MB_ICONINFORMATION ; UINT uType
    push badstr             ; LPCTSTR lpCaption
    push byeworld           ; LPCTSTR lpText
    push 0                  ; HWND hWnd
    call [__imp__MessageBoxA]

    push 0                  ; UINT uExitCode
    call [__imp__ExitProcess]

badstr db 'Fail !', 0
byeworld db 'Bye World !',0

Image_Tls_Directory32:
    StartAddressOfRawData dd Characteristics
    EndAddressOfRawData   dd Characteristics
    AddressOfIndex        dd Characteristics
    AddressOfCallBacks    dd SizeOfZeroFill
    SizeOfZeroFill        dd setup
    Characteristics       dd 0

badsize EQU $ - bad

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE
SUBSYSTEM equ 2
