; misc anti debuggers

%include '..\..\standard_hdr.asm'


EntryPoint:
    call trig

    call beingdebugged
    call ntglobalflag
    call forceflag
    call deletefib

    call popss
    call outputdbg
;    call ntqueryinfo
;    call checkremote

    jmp good

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; DeleteFiber
; triggers a BREAKPOINT exception if debugger present, else just an ERROR INVALID PARAMETER
; (ForceFlag check)

ERROR_INVALID_PARAMETER equ 00000057h

deletefib:
    push EntryPoint     ; LPVOID lpFiber
    call DeleteFiber

    call GetLastError
    cmp eax, ERROR_INVALID_PARAMETER
    jnz bad
    retn
;%IMPORT kernel32.dll!GetLastError
;%IMPORT kernel32.dll!DeleteFiber

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;

trig:
    push 0
    call _CIasin
    add esp, 4
    cmp al, 98H     ; a8h if debugger present
    jnz bad
    retn
;%IMPORT msvcrt.dll!_CIasin

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;

beingdebugged:
    getPEB eax
    movzx eax, byte [eax + PEB.BeingDebugged]
    test eax, eax
    jnz bad
    retn

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;

ntglobalflag:
    getPEB eax
    mov eax, [eax + PEB.NtGlobalFlag]
    and eax, FLG_HEAP_ENABLE_TAIL_CHECK | FLG_HEAP_ENABLE_FREE_CHECK | FLG_HEAP_VALIDATE_PARAMETERS
    test eax, eax
    jnz bad
    retn

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
forceflag:
    mov eax, [fs:30h]
    mov eax, [eax+18h] ;process heap
    mov eax, [eax+10h] ;heap.forceflags flags
    test eax, eax
    jnz bad
    retn

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;

popss:              ; anti-stepping
    push ss
    pop ss
    pushf           ; debugger can't step directly after pop ss
    pop eax
TF equ 0100h
    and eax, TF
    test eax, eax
    jnz bad
    retn

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;

outputdbg:
    push _ErrorCheck
    call SetLastError
    xor eax, eax
    push error
    call OutputDebugStringA
    cmp eax, 1
    jnz bad
    call GetLastError
    cmp eax, _ErrorCheck
    jz bad
    retn

_ErrorCheck equ 123456h

;%IMPORT kernel32.dll!SetLastError
;IMPORT kernel32.dll!GetLastError
;%IMPORT kernel32.dll!OutputDebugStringA

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;

ntqueryinfo:
    push 0
    push 4
    push isdebugged
    push 7 ;ProcessDebugPort
    push -1
    call NtQueryInformationProcess
    test eax, eax
    jnz bad
    cmp dword [isdebugged], 0
    jnz bad

;%IMPORT ntdll.dll!NtQueryInformationProcess

isdebugged dd 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;

checkremote:
    push isdebugged
    push -1
    call CheckRemoteDebuggerPresent
    test eax, eax
    jnz bad
    retn

;%IMPORT kernel32.dll!CheckRemoteDebuggerPresent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

%include '..\goodbad.inc'

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess
;%IMPORTS

%include '..\..\standard_ftr.asm'

; Ange Albertini, Creative Commons BY, 2009-2010
