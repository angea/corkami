;example file where a 2nd thread checks that the first one is unmodified
;which prevent patches and software breakpoint

;here, the checksum is used in a blind way,
;which may lead to an exception,
;and the exception handler exits the process

;Ange Albertini, BSD licence, 2011

%include '..\..\onesec.hdr'

EntryPoint:
    push 0              ; LPDWORD lpThreadId
    push 0              ; DWORD dwCreationFlags
    push 0              ; LPVOID lpParameter
    push checkthread    ; LPTHREAD_START_ROUTINE lpStartAddress
    push 010000h        ; SIZE_T dwStackSize    ; typically 0 but this PE has a 0 stack in the header
    push 0              ; LPSECURITY_ATTRIBUTES lpThreadAttributes
    call CreateThread

    mov ecx, 046
    mov eax, 0
    mov ebx, 1

_loop:
    ; delay to let the other thread do its job
    pushad
    push 100h
    call Sleep
    popad

    mov edx, ebx
    add edx, eax
    mov eax, ebx
    mov ebx, edx
    add ecx, -1
    jnz _loop

    mov ecx, ebx
    cmp ecx, 2971215073 ; 46th fibonacci number
    jnz bad

good:
    push MB_ICONINFORMATION ; UINT uType
    push tada               ; LPCTSTR lpCaption
    push helloworld         ; LPCTSTR lpText
    push 0                  ; HWND hWnd
    call MessageBoxA
bad:
    push 0                  ; UINT uExitCode
    call ExitProcess
_c

checkthread:
    setSEH bad
    mov esi, EntryPoint
    mov ecx, (cmp2 + 2 - EntryPoint) / 4
    xor ebx, ebx
next_char:
    lodsd
    rol eax, 8
    xor ebx, eax
    loop next_char
cmp2:
    xor ebx, 0FF3BBC61h ^ 0401077h
    jmp ebx
_c

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess
;%IMPORT kernel32.dll!Sleep
;%IMPORT kernel32.dll!CreateThread

tada db "Tada!", 0
helloworld db "Hello World!", 0

;%IMPORTS

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE
