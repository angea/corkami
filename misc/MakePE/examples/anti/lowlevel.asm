; allocating buffers via all levels of user mode APIs or calls
; VirtualAlloc > VirtualAllocEx > ZwAllocateVirtualMemory > KiFastSystemCall > SYSENTER

%include '../../onesec.hdr'

EntryPoint:

base_of_code:
    push PAGE_READWRITE     ; DWORD flProtect
    push MEM_COMMIT         ; DWORD flAllocationType
    push 1000h              ; SIZE_T dwSize
    push 0                  ; LPVOID lpAddress
    call VirtualAlloc
    mov [lpBuffer1], eax

nop
    push PAGE_READWRITE     ; DWORD flProtect
    push MEM_COMMIT         ; DWORD flAllocationType
    push 1000h              ; SIZE_T dwSize
    push 0                  ; LPVOID lpAddress
    push -1                 ; HANDLE hProcess
    call VirtualAllocEx
    mov [lpBuffer2], eax
nop
    push PAGE_READWRITE     ; ULONG Protect
    push MEM_COMMIT         ; ULONG AllocationType
    push zwsize             ; PSIZE_T RegionSize
    push 0                  ; ULONG_PTR ZeroBits
    push lpBuffer3          ; PVOID *BaseAddress
    push -1                 ; HANDLE ProcessHandle
    call ZwAllocateVirtualMemory
nop
    push PAGE_READWRITE     ; ULONG Protect
    push MEM_COMMIT         ; ULONG AllocationType
    push zwsize             ; PSIZE_T RegionSize
    push 0                  ; ULONG_PTR ZeroBits
    push lpBuffer4          ; PVOID *BaseAddress
    push -1                 ; HANDLE ProcessHandle
    call myZwAllocateVirtualMemoryXP
nop

; let's make use of these 4 buffers
%macro makejmp 2
    mov eax, [%1]
    mov ebx, [%2]
    mov byte [eax], 68h         ; push <imm32>
    mov dword [eax + 1], ebx
    mov byte [eax + 5], 0c3h    ; retn
%endmacro

    makejmp lpBuffer1, lpBuffer2
    makejmp lpBuffer2, lpBuffer3
    makejmp lpBuffer3, lpBuffer4

    mov ebx, [lpBuffer4]
    mov byte [ebx], 0c3h

    push good
    jmp [lpBuffer1]
    jmp bad

align 16, int3

%include '..\goodbad.inc'

align 16, int3

;%IMPORT user32.dll!MessageBoxA

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

align 16, int3

myKiFastSystemCall:
    mov edx, esp
    sysenter
    retn

align 16, int3

ZwAllocateVirtualMemory7:
    mov eax, 015h
    xor ecx, ecx
    lea edx, [esp + 4]
    call [fs:0c0h]
    add esp, 4
    retn 18h

align 16, int3

;%IMPORT kernel32.dll!VirtualAlloc
;%IMPORT kernel32.dll!VirtualAllocEx
;%IMPORT ntdll.dll!ZwAllocateVirtualMemory
;%IMPORT ntdll.dll!KiFastSystemCall

;%IMPORT kernel32.dll!ExitProcess

SIZEOFCODE equ $ - base_of_code

;%IMPORTS

align 16, db 0
zwsize dd 1000h

lpBuffer1 dd 0
lpBuffer2 dd 0
lpBuffer3 dd 0
lpBuffer4 dd 0

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE


;Ange Albertini, Creative Commons BY, 2010