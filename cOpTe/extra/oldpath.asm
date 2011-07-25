%include '../header.inc'

setup:
    xor eax, eax
    push cs
    pop ecx
    mov edx, nop_bounds

    push ds
    pop word [lsd + 4]
    add esp, 2

    mov esi, lsd
    retn

    EntryPoint:
    call setup
            into
            bound eax, [edx]
            verr cx
    lar eax, ecx ; => eax = 0cffb00h
    str edx
    aaa     ; => eax = 00CFFC06h

    lsl eax, ecx ; => eax = -1
            sfence
            arpl cx, ax
    aam     ; eax = FFFF1905
    bswap ecx
    lock cmpxchg8b [esi]
    lds ebx, [esi] ; eax = -1
    xlatb
    daa
    xadd ecx, eax
            prefetch [eax]
    ; ecx = <cs><401034h> ?


times 100 db 90h
    push cs
    pop edx
    ror edx, 8
    xor dx, dx
    or edx, 401034h
    cmp ecx, edx
    jnz bad

    push 40h                ; UINT uType
    push tada               ; LPCTSTR lpCaption
    push helloworld         ; LPCTSTR lpText
    push 0                  ; HWND hWnd
    call MessageBoxA
bad:
    push 0                  ; UINT uExitCode
    call ExitProcess

align 16, db 0

nop_bounds:
    dd -1
    dd 800000h

lsd :
    dd EntryPoint
    dw 0


;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess

tada db "Correct!", 0
helloworld db "no error detected...", 0

;%IMPORTS

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE
SUBSYSTEM equ 2
