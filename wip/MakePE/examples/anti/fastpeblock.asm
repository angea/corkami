;simple helloworld example
;compile with: makepe.py helloworld.asm

%include '..\..\onesec.hdr'

EntryPoint:
    mov eax, [fs:30h]       ; _TEB.PEB
    lea eax, [eax + 20h]    ; _PEB.FastPebLockRoutine
    mov dword [eax], _mycall

    push 0                  ; UINT uExitCode
    call ExitProcess

align 16, int3

_mycall:
    mov eax, [fs:30h]       ; _TEB.PEB
    lea eax, [eax + 20h]    ; _PEB.FastPebLockRoutine
    mov ebx, [__imp__RtlEnterCriticalSection]
    mov [eax], ebx

    push MB_ICONINFORMATION ; UINT uType
    push tada               ; LPCTSTR lpCaption
    push helloworld         ; LPCTSTR lpText
    push 0                  ; HWND hWnd
    call MessageBoxA

    push 0                  ; UINT uExitCode
    call ExitProcess

align 16, int3

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess
;%IMPORT ntdll.dll!RtlEnterCriticalSection
align 16, int3

tada db "Tada!", 0
helloworld db "Hello World!", 0

;%IMPORTS

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE

;Ange Albertini, Creative Commons BY, 2009-2010
