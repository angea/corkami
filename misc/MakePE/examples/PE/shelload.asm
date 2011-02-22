; simple shellcode loader, with optional file to open handle to.
; use at your own risk
; shelload <shellcode> [<file_to_open>]

%include '..\..\onesec.hdr'

EntryPoint:
    call main_
    jmp [lpBuffer]

main_:
    call GetCommandLineA

    mov esi, eax
_findspace1:
    lodsb
    cmp al, 20h
    jnz _findspace1

_skipspaces:
    lodsb
    cmp al, 20h
    jz _skipspaces

    mov edi, shellcode
_loop2:
    stosb
    lodsb
    cmp al, 20h
    jz _loop2_end
    cmp al, 0
    jz _no_opened
    jmp _loop2
_loop2_end:

_skipspaces2:
    lodsb
    cmp al, 20h
    jz _skipspaces2

    mov edi, opened
_loop3
    stosb
    lodsb
    cmp al, 0
    jnz _loop3

    push 0                  ; hTemplateFile
    push 0                  ; dwFlagsAndAttributes
    push OPEN_EXISTING      ; dwCreationDisposition
    push 0                  ; lpSecurityAttributes
    push FILE_SHARE_READ    ; dwShareMode
    push GENERIC_READ       ; dwDesiredAccess
    push opened             ; lpFileName
    call CreateFileA
    cmp eax, -1
    jz error

_no_opened:
    push 0                  ; hTemplateFile
    push 0                  ; dwFlagsAndAttributes
    push OPEN_EXISTING      ; dwCreationDisposition
    push 0                  ; lpSecurityAttributes
    push FILE_SHARE_READ    ; dwShareMode
    push GENERIC_READ       ; dwDesiredAccess
    push shellcode          ; lpFileName
    call CreateFileA
    cmp eax, -1
    jz error

    mov [hFile], eax

    push 0
    push eax
    call GetFileSize
    cmp eax, 0
    jz error

    mov [size], eax

    push PAGE_READWRITE     ; DWORD flProtect
    push MEM_COMMIT         ; DWORD flAllocationType
    push dword [size]       ; SIZE_T dwSize
    push 0                  ; LPVOID lpAddress
    call VirtualAlloc

    cmp eax, 0
    jz error

    mov [lpBuffer], eax

    push 0                  ; LPOVERLAPPED lpOverlapped
    push lpNumberOfBytes    ; LPDWORD lpNumberOfBytesRead
    push dword [size]       ; DWORD nNumberOfBytesToRead
    push dword [lpBuffer]   ; LPVOID lpBuffer
    push dword [hFile]      ; HANDLE hFile
    call ReadFile

    cmp eax, 1
    jnz error

    push dword [hFile]
    call CloseHandle

    retn

error:
    push 0
    call ExitProcess

;%IMPORT kernel32.dll!ExitProcess

;%IMPORT kernel32.dll!CreateFileA
;%IMPORT kernel32.dll!ReadFile
;%IMPORT kernel32.dll!GetFileSize
;%IMPORT kernel32.dll!CloseHandle

;%IMPORT kernel32.dll!GetCommandLineA
;%IMPORT kernel32.dll!VirtualAlloc

lpBuffer dd 0
hFile dd 0
lpNumberOfBytes dd 0
size dd 0

opened:
	times 256 db 0
shellcode:
	times 256 db 0

;%IMPORTS

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE

;Ange Albertini, Creative Commons BY, 2009-2010
