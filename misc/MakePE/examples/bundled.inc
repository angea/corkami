; open an external data file, and use the content to display a messagebox

%strlen hwc 'Hello World!0'
%strlen tac 'Tada!0'
BUFFLEN equ tac + hwc

    call load

    push MB_ICONINFORMATION ; UINT uType
    push Buffer + hwc       ; LPCTSTR lpCaption
    push Buffer             ; LPCTSTR lpText
    push 0                  ; HWND hWnd
    call MessageBoxA

    push 0                  ; UINT uExitCode
    call ExitProcess

load:
    push 0                  ; hTemplateFile
    push 0                  ; dwFlagsAndAttributes
    push OPEN_EXISTING      ; dwCreationDisposition
    push 0                  ; lpSecurityAttributes
    push FILE_SHARE_READ    ; dwShareMode
    push GENERIC_READ       ; dwDesiredAccess
    push lpFileName         ; lpFileName
    call CreateFileA
    mov [hFile], eax

    push 0                  ; LPOVERLAPPED lpOverlapped
    push lpNumberOfBytes    ; LPDWORD lpNumberOfBytesRead
    push BUFFLEN            ; DWORD nNumberOfBytesToRead
    push dword [lpBuffer]   ; LPVOID lpBuffer
    push dword [hFile]      ; HANDLE hFile
    call ReadFile

    push dword [hFile]    ; hObject
    call CloseHandle
    retn

lpFileName db 'bundled.dat',0

hFile dd 0
lpNumberOfBytes dd 0
Buffer:
    times BUFFLEN db 0

lpBuffer dd Buffer

;Ange Albertini, Creative Commons BY, 2010