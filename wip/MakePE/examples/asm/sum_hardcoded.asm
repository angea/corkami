;example file where a 2nd thread checks that the first one is unmodified
;which prevent patches and software breakpoint

;the checksum is compared with a hardcoded value, making it easier to spot and patch

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

checkthread:
    mov esi, EntryPoint
    mov ecx, (checkthread - EntryPoint) / 4
    xor ebx, ebx
next_char:
    lodsd
    rol eax, 8
    xor ebx, eax
    loop next_char
    cmp ebx, 05EB4239Ch
    jnz bad
    jmp checkthread
    
;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess
;%IMPORT kernel32.dll!Sleep
;%IMPORT kernel32.dll!CreateThread

tada db "Tada!", 0
helloworld db "Hello World!", 0

;%IMPORTS

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE
