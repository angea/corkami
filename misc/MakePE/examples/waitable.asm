;simple helloworld example
;compile with: makepe.py helloworld.asm

%include '../onesec.hdr'

EntryPoint:
    push 0                  ; LPCTSTR lpTimerName
    push 0                  ; BOOL bManualReset
    push 0                  ; LPSECURITY_ATTRIBUTES lpTimerAttributes
    call CreateWaitableTimerA
    mov [hTimer], eax

    push 0                  ; BOOL fResume
    push 0380004h           ; LPVOID lpArgToCompletionRoutine
    push myret              ; PTIMERAPCROUTINE pfnCompletionRoutine
    push 0ah                ; LONG lPeriod
    push 0380010h           ; LARGE_INTEGER *pDueTime
    push eax                ; HANDLE hTimer
    call SetWaitableTimer

sleeploop:
    push 1                  ; BOOL bAlertable
    push 1000h              ; DWORD dwMilliseconds
    call SleepEx
;    jmp sleeploop

    push dword [hTimer]     ; HANDLE hTimer
    call CancelWaitableTimer

    push dword [hTimer]
    call CloseHandle

    cmp dword [counter], 1
    jnz bad

    push MB_ICONINFORMATION ; UINT uType
    push tada               ; LPCTSTR lpCaption
    push helloworld         ; LPCTSTR lpText
    push 0                  ; HWND hWnd
    call MessageBoxA
bad:
    push 0                  ; UINT uExitCode
    call ExitProcess

myret:
    inc dword [counter]
    retn 0ch

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess
;%IMPORT kernel32.dll!CreateWaitableTimerA
;%IMPORT kernel32.dll!SetWaitableTimer
;%IMPORT kernel32.dll!CancelWaitableTimer
;%IMPORT kernel32.dll!CloseHandle
;%IMPORT kernel32.dll!SleepEx

hTimer dd 0
counter dd 0
tada db "Tada!", 0
helloworld db "Hello World!", 0


;%IMPORTS

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE

;Ange Albertini, Creative Commons BY, 2009-2010
