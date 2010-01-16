.386
.model flat, stdcall
option casemap :none   ; case sensitive

include c:\masm32\include\windows.inc

include c:\masm32\include\user32.inc
include c:\masm32\include\kernel32.inc

includelib c:\masm32\lib\user32.lib
includelib c:\masm32\lib\kernel32.lib

.data
    tada db "Tada!", 0
    helloworld db "Hello World!", 0

.code
Main proc
    push MB_ICONINFORMATION     ; UINT uType
    push offset tada            ; LPCTSTR lpCaption
    push offset helloworld      ; LPCTSTR lpText
    push 0                      ; HWND hWnd
    call MessageBoxA
    push 0                      ; UINT uExitCode
    call ExitProcess
Main Endp
End Main