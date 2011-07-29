%include '../header.inc'

%macro __ 0
    align 8, db 90h
%endmacro

MEM_RESERVE               equ 2000h
MEM_TOP_DOWN              equ 100000h

EntryPoint:
	call setup
	push good
	db 66h
	retn

int3
align 4, int3

good:
    push MB_ICONINFORMATION ; UINT uType
    push tada               ; LPCTSTR lpCaption
    push helloworld         ; LPCTSTR lpText
    push 0                  ; HWND hWnd
    call MessageBoxA

    push 0                  ; UINT uExitCode
    call ExitProcess

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess

tada db "Tada!", 0
helloworld db "Hello World!", 0

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

	mov edi, good
	and edi, 0ffffh
	mov esi, bad
	mov ecx, badsize
	rep movsb
	
	popf
	popad
    retn


;%IMPORT ntdll.dll!ZwAllocateVirtualMemory
MB_ICONINFORMATION equ 040h

zwsize dd 0ffffh
lpBuffer3 dd 1

bad:
	add esp, 2
    push MB_ICONINFORMATION ; UINT uType
    push badstr               ; LPCTSTR lpCaption
    push byeworld         ; LPCTSTR lpText
    push 0                  ; HWND hWnd
	call [__imp__MessageBoxA]

    push 0                  ; UINT uExitCode
    call [__imp__ExitProcess]

badstr db 'Fail !', 0
byeworld db 'Bye World !',0

badsize EQU $ - bad

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE
SUBSYSTEM equ 2
