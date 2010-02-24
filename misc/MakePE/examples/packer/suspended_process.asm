; example of a suspended process-based binder.

%include '..\..\standard_hdr.asm'

EntryPoint:
    push lpProcessInformation   ; lpProcessInformation
    push lpStartupInfo          ; lpStartupInfo
    push 0                      ; lpCurrentDirectory
    push 0                      ; lpEnvironment
    push CREATE_SUSPENDED       ; dwCreationFlags
    push 0                      ; bInheritHandles
    push 0                      ; lpThreadAttributes
    push 0                      ; lpProcessAttributes
    push 0                      ; lpCommandLine
    ; typically, the filename is obtained via could do something smarter via GetCommandLineA
    push lpName                 ; lpApplicationName
    call CreateProcessA

    push lpNumberOfBytes                        ; SIZE_T *lpNumberOfBytesWritten
    push EMBEDDED_FILESIZE                      ; SIZE_T nSize
    push embedded_file                          ; LPCVOID lpBuffer
    ; assuming both dropper and dropped the same imagebase
    push IMAGEBASE                              ; LPVOID lpBaseAddress
    push dword [lpProcessInformation + PROCESS_INFORMATION.hProcess]   ; HANDLE hProcess
    call WriteProcessMemory

; often, droppers add extra modification like changing thread registers, via GetThreadContext/SetThreadContext

    push dword [lpProcessInformation + PROCESS_INFORMATION.hThread]    ; HANDLE hThread
    call ResumeThread

    push 0  ; uExitCode
    call ExitProcess

;%IMPORT kernel32.dll!CreateProcessA
;%IMPORT kernel32.dll!WriteProcessMemory
;%IMPORT kernel32.dll!ResumeThread

;%IMPORT kernel32.dll!ExitProcess

SIZEOFCODE equ $ - base_of_code

align 16, db 0
base_of_data:
lpNumberOfBytes dd 0

lpStartupInfo istruc STARTUPINFO
iend

lpProcessInformation istruc PROCESS_INFORMATION
iend

lpName db 'suspended_process.exe', 0
SIZEOFINITIALIZEDDATA equ $ - base_of_data

align 16, db 0

;%IMPORTS

uninit_data equ IMAGEBASE
SIZEOFUNINITIALIZEDDATA equ 0

embedded_file:
; we need one with the OEP at the same address otherwise we need to change the context
incbin '..\imports_manual.exe'
EMBEDDED_FILESIZE equ $ - embedded_file

Section0Size EQU $ - Section0Start
align FILEALIGN,db 0
SIZEOFIMAGE EQU $ - IMAGEBASE

;Ange Albertini, Creative Commons BY, 2010
