; complex SEH with Context checks, and direct use of KiFastSystemCallRet

%include '../onesec.hdr'
EXCEPTION_ILLEGAL_INSTRUCTION equ 0c000001dh

EntryPoint:
; part 1 ActxSEH is disabled because it doesn't work on every computer

jmp part2
ActxSEH:
    sub esp, 38h
    mov eax, 0
    call _next
    jmp handler
_next:
    mov eax, [fs:eax + 18h]                 ; TEB
    mov ecx, [eax]
    push ecx
    mov [eax], esp
    mov eax, [eax + 4]                      ; => "Actx", which is read only
trigger:
    not dword [eax]                         ; should trigger exception

handler:
    pop eax
    lea esp, [esp + 4]
    pop edx
    pop ecx                                 ; ecx = Context

    pushad
    mov eax, [ecx + CONTEXT.regEax]         ; context check again
    imul eax, eax
    popad
    jnz bad                                 ; might fail on some computer

    push edi

    mov edi, [07ffe012ch]                   ; => edi = 0

    lea edi, [ecx + edi * 2 + CONTEXT.regEip]
    mov edi, [edi]                          ; => edi - trigger
    lea edi, [edi + part1clean - trigger]   ; => edi = good

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

part1clean:                                 ; cleaning, if part 1 was executed
    clearSEH
    add esp, 38h
    nop
    nop
    nop

part2:
    sub eax, eax                            ; mov eax, 0
    push dword [esp + eax]                  ; push ImageBase
    push ebp
    mov ebp, esp
    pusha                                   ; initialize
    test ecx, edx
    call parse_seh_chain

    mov eax, [esp + 4]
    add eax, [7FFE0080h]
    push esi
    mov esi, eax
    lodsd
    cmp eax, EXCEPTION_ILLEGAL_INSTRUCTION
    pop esi
    jnz short not_in_handler

    push ebp
    mov ebp, esp
    xor eax, eax
    pusha
    mov edx, eax
    add eax, esp
    mov dl, [7FFE02F8h + edx * 2]

    call change_eax
    mov ebp, eax
    dec dword [ebp + 0ACh]

    jnz short not_good
    lea ecx, [edx + ebp - 33h]
    add dword [ecx + 28h], 3
    mov edx, [ecx + 28h]
    add edx, good - trigger2
    mov ebp, [ecx + 24h]
    mov [ebp + 4], edx

not_good:
    popa
    leave
    retn                                    ; we should go to bad instead :)

not_in_handler:
    vmcall                                  ; ollydbg can't skip it
trigger2:
    add esp, 8
    mov [edx + 4], ebx
    popa
    leave
    retn

parse_seh_chain:
    push dword [ebp + 4]
    movzx ecx, byte [7FFE02F8h]
    test ecx, 5
    jz short loop_continue
    shr ecx, cl
    jz short loop_continue
    mov edx, [fs:ecx * 4 - 48h]
    mov edx, [edx]
    mov ebx, [esp + 4]
    xchg ebx, [edx + 4]
    mov ecx, 720Ch
    jmp dword [esp + 4]

loop_continue:
    jmp short parse_seh_chain

change_eax:
    lea esi, [eax + edx * 8 - 5E8h]
    mov eax, [edx + esi - 0C3h]
    retn

%include 'goodbad.inc'

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess

;%IMPORTS

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE

;Ange Albertini, Creative Commons BY, 2010
