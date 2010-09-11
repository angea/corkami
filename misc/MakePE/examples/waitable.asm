; anti emu with waitable timers
; theorically working but depending on the CPU speed so far :(

%include '../onesec.hdr'
; Period is in ms
; DueTime is in 100 ns
; Sleep is in ms

COUNTER equ 100

EntryPoint:
    push 0                  ; LPCTSTR lpTimerName
    push 0                  ; BOOL bManualReset
    push 0                  ; LPSECURITY_ATTRIBUTES lpTimerAttributes
    call CreateWaitableTimerA

    mov [hTimer], eax

    push 0                  ; BOOL fResume
    push 0                  ; LPVOID lpArgToCompletionRoutine
    push myret              ; PTIMERAPCROUTINE pfnCompletionRoutine
    push 10                  ; LONG lPeriod
    push liDueTime          ; LARGE_INTEGER *pDueTime
    push eax                ; HANDLE hTimer
    call SetWaitableTimer

    call GetTickCount
    mov [time1], eax

sleeploop:
    push 1                  ; BOOL bAlertable
    push 1                  ; DWORD dwMilliseconds
    call SleepEx

    call GetTickCount
    mov ebx, [time1]
    sub eax, ebx

    cmp eax, 1000
    jbe sleeploop

    push dword [hTimer]     ; HANDLE hTimer
    call CancelWaitableTimer

    push dword [hTimer]
    call CloseHandle

    cmp dword [counter], 05Fh
    jg bad
    cmp dword [counter], 05Ch
    jb bad
    jmp good

%include 'goodbad.inc'

myret:
    inc dword [counter]
    retn 0ch


align 4
liDueTime dq -1
time1 dd 0

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess
;%IMPORT kernel32.dll!CreateWaitableTimerA
;%IMPORT kernel32.dll!SetWaitableTimer
;%IMPORT kernel32.dll!CancelWaitableTimer
;%IMPORT kernel32.dll!WaitForSingleObject
;%IMPORT kernel32.dll!CloseHandle
;%IMPORT kernel32.dll!SleepEx
;%IMPORT kernel32.dll!GetTickCount

hTimer dd 0
counter dd 0
tada db "Tada!", 0
helloworld db "Hello World!", 0


;%IMPORTS

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE

;Ange Albertini, Creative Commons BY, 2010
