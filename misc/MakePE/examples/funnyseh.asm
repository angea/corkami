; complex SEH with Context checks, and direct use of KiFastSystemCallRet

%include '../onesec.hdr'

EntryPoint:
    sub esp, 38h
    mov eax, 0
    call _next
    jmp handler
_next:
    mov eax, [fs:eax + 18h]                 ; TEB
    mov ecx, [eax]
    push ecx
    mov [eax], esp
    mov eax, [eax + 4]  ; => "Actx" which is read only
trigger:
    not dword [eax]     ; should trigger exception

handler:
    pop eax
    lea esp, [esp + 4]
    pop edx
    pop ecx                                 ; ecx = Context

    pushad
    mov eax, [ecx + CONTEXT.regEax]         ; context check again
    imul eax, eax
    popad
    jnz bad                                 ; might fail

    push edi

    mov edi, [07ffe012ch]                   ; => edi = 0

    lea edi, [ecx + edi * 2 + CONTEXT.regEip]
    mov edi, [edi]                          ; => edi - trigger
    lea edi, [edi + good - trigger]         ; => edi = good

    push edi
    pop dword [ecx + CONTEXT.regEip]

    pop edi

    push ecx                                ; restoring the stack
    push eax
    push edx
    push eax

    xor eax, eax                            ; => eax = ExceptionContinueExecution

    cmp [07ffe0300h], eax                   ; checking if 7ffe0304h is actually ntdll.dll!KiFastSystemCallRet
    jnz not_ret
    retn
not_ret:
    jmp [7ffe0304h]                         ;hardcoded IMPORT ntdll.dll!KiFastSystemCallRet

%include 'goodbad.inc'

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess

;%IMPORTS

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE

;Ange Albertini, Creative Commons BY, 2010
