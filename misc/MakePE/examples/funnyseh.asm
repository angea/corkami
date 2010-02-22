; complex SEH with Context checks, and direct use of KiFastSystemCallRet

%include '../onesec.hdr'

EntryPoint:
    sub esp, 38h
    mov eax, 0
    call _next
    jmp handler
_next:
    mov eax, [fs:eax + 18h]
    mov ecx, [eax]
    push ecx
    mov [eax], esp
    mov eax, [eax + 4]  ; => "Actx" which is read only
trigger:
    not dword [eax]     ; should trigger exception

handler:
    pop eax
    lea esp, [esp + 4]                      ; add esp, 4
    pop edx
    pop ecx
    pushad
    mov eax, [ecx + 0b0h]                   ; context check again
    imul eax, eax
    popad
    jnz bad                               ; might fail
    push edi
    mov edi, [07ffe012ch]  ; edx = 0
    lea edi, [ecx + edi * 2 + 0b8h]
    mov edi, [edi]
    lea edi, [edi + good - trigger]
    push edi
    pop dword [ecx + 0b8h]
    pop edi
    push ecx
    push eax
    push edx
    push eax
    xor eax, eax
    cmp [07ffe0300h], eax
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
