; minimalist thread injection binder, 
; with a specific thread-host to make the remote thread simpler

%include '..\..\standard_hdr.asm'

EntryPoint:
    ; let's execute our thread host
    push lpProcessInformation   ; lpProcessInformation
    push lpStartupInfo          ; lpStartupInfo
    push 0                      ; lpCurrentDirectory
    push 0                      ; lpEnvironment
    push 0                      ; dwCreationFlags
    push 0                      ; bInheritHandles
    push 0                      ; lpThreadAttributes
    push 0                      ; lpProcessAttributes
    push 0                      ; lpCommandLine
    push szProcess              ; lpApplicationName
    call CreateProcessA

 ; typically, injectors are scanning process to find their target via CreateToolhelp32Snapshot/Process32First/Process32Next

    push dword [lpProcessInformation + PROCESS_INFORMATION.dwProcessId] ; HANDLE hProcess
    push 1                                                              ; BOOL bInheritHandle
    push PROCESS_CREATE_THREAD | PROCESS_QUERY_INFORMATION | \
        PROCESS_VM_WRITE | PROCESS_VM_OPERATION | PROCESS_VM_READ       ; DWORD dwDesiredAccess
    call OpenProcess
    mov [hProcess], eax

    push PAGE_READWRITE     ; DWORD flProtect
    push MEM_COMMIT         ; DWORD flAllocationType
    push THREAD_SIZE        ; SIZE_T dwSize
    push 0                  ; LPVOID lpAddress
    push dword [hProcess]   ; HANDLE hProcess
    call VirtualAllocEx
    mov [lpBuffer], eax

    push lpNumberOfBytes    ; SIZE_T *lpNumberOfBytesWritten
    push THREAD_SIZE        ; SIZE_T nSize
    push thread_start       ; LPCVOID lpBuffer
    push dword [lpBuffer]   ; LPVOID lpBaseAddress
    push dword [hProcess]   ; HANDLE hProcess
    call WriteProcessMemory

    push dword [lpThreadId] ; LPDWORD lpThreadId
    push 0                  ; DWORD dwCreationFlags
    push 0                  ; LPVOID lpParameter
    push dword [lpBuffer]   ; LPTHREAD_START_ROUTINE lpStartAddress
    push 0                  ; SIZE_T dwStackSize
    push 0                  ; LPSECURITY_ATTRIBUTES lpThreadAttributes
    push dword [hProcess]   ; HANDLE hProcess
    call CreateRemoteThread

    push 0                  ; uExitCode
    call ExitProcess

;%IMPORT kernel32.dll!CreateProcessA

;%IMPORT kernel32.dll!OpenProcess
;%IMPORT kernel32.dll!VirtualAllocEx
;%IMPORT kernel32.dll!WriteProcessMemory
;%IMPORT kernel32.dll!CreateRemoteThread

;%IMPORT kernel32.dll!ExitProcess

; simplified thread that doesn't need to resolve its own imports
thread_start:
    call $ + 5
base:
    pop ebp

    lea eax, [ebp + (tada - base)]
    lea ebx, [ebp + (helloworld - base)]

    push MB_ICONINFORMATION ; UINT uType
    push eax                ; LPCTSTR lpCaption
    push ebx                ; LPCTSTR lpText
    push 0                  ; HWND hWnd
    call iMessageBoxA

    push 0                  ; UINT uExitCode
    call iExitProcess
iMessageBoxA:
    push 400200h    ; absolute jump
    retn
iExitProcess:
    push 400206h    ; absolute jump
    retn
tada db "Tada!", 0
helloworld db "Hello World!", 0

THREAD_SIZE equ $ - thread_start

SIZEOFCODE equ $ - base_of_code

;%IMPORTS

align 16, db 0
base_of_data:

szProcess db 'thread_host.exe' , 0

align 16, db 0
lpBuffer dd 0
hProcess dd 0
lpThreadId  dd 0
lpNumberOfBytes dd 0

align 16, db 0
lpStartupInfo istruc STARTUPINFO
iend
align 16, db 0
lpProcessInformation istruc PROCESS_INFORMATION
iend

SIZEOFINITIALIZEDDATA equ $ - base_of_data

uninit_data equ IMAGEBASE
SIZEOFUNINITIALIZEDDATA equ 0
Section0Size EQU $ - Section0Start
align FILEALIGN,db 0
SIZEOFIMAGE EQU $ - IMAGEBASE

; Ange Albertini, Creative Commons BY, 2010