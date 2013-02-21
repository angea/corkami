; allocating buffers via all levels of user mode APIs or calls
; VirtualAlloc > VirtualAllocEx > ZwAllocateVirtualMemory > KiFastSystemCall > SYSENTER

;Ange Albertini, BSD LICENCE, 2011

%include '../../onesec.hdr'

;[%1] will be patched to jump to [%2]
%macro makejmp 2
    mov eax, [%1]
    mov ebx, [%2]
    mov byte [eax], 68h         ; push <imm32>
    mov dword [eax + 1], ebx
    mov byte [eax + 5], 0c3h    ; retn
%endmacro

base_of_code:

CreateBuffer1:
    push PAGE_READWRITE     ; DWORD flProtect
    push MEM_COMMIT         ; DWORD flAllocationType
    push 1000h              ; SIZE_T dwSize
    push 0                  ; LPVOID lpAddress
    call VirtualAlloc
    mov [lpBuffer1], eax
    retn

;%IMPORT kernel32.dll!VirtualAlloc

align 16, int3

CreateBuffer2:
    push PAGE_READWRITE     ; DWORD flProtect
    push MEM_COMMIT         ; DWORD flAllocationType
    push 1000h              ; SIZE_T dwSize
    push 0                  ; LPVOID lpAddress
    push -1                 ; HANDLE hProcess
    call VirtualAllocEx
    mov [lpBuffer2], eax
    retn
;%IMPORT kernel32.dll!VirtualAllocEx

align 16, int3

CreateBuffer3:
    push PAGE_READWRITE     ; ULONG Protect
    push MEM_COMMIT         ; ULONG AllocationType
    push zwsize             ; PSIZE_T RegionSize
    push 0                  ; ULONG_PTR ZeroBits
    push lpBuffer3          ; PVOID *BaseAddress
    push -1                 ; HANDLE ProcessHandle
    call ZwAllocateVirtualMemory
    retn
;%IMPORT ntdll.dll!ZwAllocateVirtualMemory

align 16, int3

CreateBuffer4:
    push PAGE_READWRITE     ; ULONG Protect
    push MEM_COMMIT         ; ULONG AllocationType
    push zwsize             ; PSIZE_T RegionSize
    push 0                  ; ULONG_PTR ZeroBits
    push lpBuffer4          ; PVOID *BaseAddress
    push -1                 ; HANDLE ProcessHandle
    call [myZwAlloc]
    retn

align 16, int3

ZwAllocateVirtualMemoryXP:
    mov eax, 011h
    mov edx, 07ffe300h
    call dword [edx]
    retn 18h

align 16, int3

myZwAllocateVirtualMemoryXP:
    mov eax, 011h
    call myKiFastSystemCall
    retn 18h
;%IMPORT ntdll.dll!KiFastSystemCall

align 16, int3

myKiFastSystemCall:
    mov edx, esp
    sysenter
    retn

align 16, int3

myZwAllocateVirtualMemory7:
    mov eax, 015h
    xor ecx, ecx
    lea edx, [esp + 4]
    call [fs:0c0h]
    add esp, 4
    retn 18h

align 16, int3

EntryPoint:
    push bad
    push dword [fs:0]
    mov [fs:0], esp
nop
    call CreateBuffer1
    call CreateBuffer2
    makejmp lpBuffer1, lpBuffer2
    call CreateBuffer3
    makejmp lpBuffer2, lpBuffer3
    call CreateBuffer4
    makejmp lpBuffer3, lpBuffer4
    makejmp lpBuffer4, happyend
nop
    jmp [lpBuffer1]

align 16, int3

; small version checking TLS to fix W7/XP compatibility

TLS:
    mov eax, [fs:18h]
    mov ecx, [eax + 030h]
    xor eax, eax
    or eax, [ecx + 0a8h]
    shl eax,8
    or eax, [ecx + 0a4h]
    cmp eax, 0106h               ; Win7 ?
    jz W7
nop
    mov dword [myZwAlloc], myZwAllocateVirtualMemoryXP
    retn
W7:
nop
    mov dword [myZwAlloc], myZwAllocateVirtualMemory7
    retn

align 16, int3

%include '..\goodbad.inc'

align 16, int3

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess

SIZEOFCODE equ $ - base_of_code

;%IMPORTS

align 16, db 0
zwsize dd 1000h
happyend dd good

lpBuffer1 dd 0
lpBuffer2 dd 0
lpBuffer3 dd 0
lpBuffer4 dd 0
myZwAlloc dd 0
Image_Tls_Directory32:
    StartAddressOfRawData dd Characteristics
    EndAddressOfRawData   dd Characteristics
    AddressOfIndex        dd Characteristics
    AddressOfCallBacks    dd Callbacks
    SizeOfZeroFill        dd 0
    Characteristics       dd 0

Callbacks:
    dd TLS
    dd 0

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE
