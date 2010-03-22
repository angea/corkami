; misc anti debuggers

%include '..\..\standard_hdr.asm'

EntryPoint:
    call trig

    call beingdebugged
    call ntglobalflag
    call heapflags
    call forceflag
    call deletefib

    call popss
    call outputdbg
    call ntqueryinfo
    call checkremote
    call hidefromdbg
    ; call opencsr ; not working ?

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
    getPEB eax
    mov eax, [eax + PEB.ProcessHeap]
    mov eax, [eax + _HEAP.ForceFlags]
    test eax, eax
    jnz bad
    retn

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;

heapflags:
    getPEB eax
    mov eax, [eax + PEB.ProcessHeap]
    mov eax, [eax + _HEAP.Flags]
    cmp eax, HEAP_GROWABLE
    jnz bad
    retn

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
STATUS_ACCESS_DENIED equ 0C0000022h

opencsr:
    ; not working correctly
    call CsrGetProcessId
    push eax
    push 0;FALSE
    push PROCESS_QUERY_INFORMATION
    call OpenProcess
    cmp eax, STATUS_ACCESS_DENIED ; equ 0C0000022h
    jnz bad
    retn
    jmp good
;%IMPORT ntdll.dll!CsrGetProcessId
;%IMPORT kernel32.dll!OpenProcess

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;

ThreadhideFromDebugger equ 11h
hidefromdbg:
    push 0
    push -1
    push ThreadhideFromDebugger
    push -2
    call NtSetInformationThread
    retn
;%IMPORT ntdll.dll!NtSetInformationThread

;kernel32.dll!SetUnhandledExceptionFilter

;kernel32.dll!_BasepCurrentTopLevelFilter

;Exceptionfilter:
; eax = ExceptionInfo.ContextRecord
;mov eax, [esp + 4]
;mov eax, [eax + 4]
; mov [eax + CONTEXT.regEIP], ...
;mov eax, -1 ; EXCEPTION_CONTINUE_EXECUTION
;retn

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

ProcessDebugPort equ 7
ntqueryinfo:
    push 0
    push 4
    push isdebugged
    push ProcessDebugPort
    push -1
    call NtQueryInformationProcess
    test eax, eax
    jnz bad
    cmp dword [isdebugged], 0
    jnz bad
    retn
;%IMPORT ntdll.dll!NtQueryInformationProcess

isdebugged dd 312452

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;

checkremote:
    push isdebugged
    push -1 ; GetCurrentProcess
    call CheckRemoteDebuggerPresent
    cmp dword [isdebugged], 0
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
