; various ways of triggering exceptions, including all interrupts

%include '../onesec.hdr'

%macro _set 1
    push  %1
    push dword [fs:0]
    mov [fs:0], esp
%endmacro

%macro _before 0
    %push SEH
    _set %$handler
%endmacro

%macro _clear 0
    pop dword [fs:0]
    add esp, 4
%endmacro

%macro _after 1
%$after:
    jmp %$next
%$handler:
    mov edx, [esp + 4]
    cmp dword [edx], %1
    jnz bad
    mov eax, [esp + 0ch]
    mov dword [eax + 0b8h], %$after
    xor eax, eax
    retn
%$next:
    _clear
    nop
    nop
    %pop
%endmacro

%define PREFIX_OPERANDSIZE db 66h
%define PREFIX_ADDRESSSIZE db 67h

EntryPoint:
SINGLE_STEP equ 80000004h ;;;;;;;;;;;;;;;;;;

    _before
    db 0f1h                                 ;ICEBP
    _after SINGLE_STEP

    _before
    pushf
    pop eax         ; EAX  = EFLAGS
    or eax, 100h    ; set TF
    push eax
    popf
    nop             ; will trigger here
    _after SINGLE_STEP


ACCESS_VIOLATION equ 0c0000005h ;;;;;;;;;;;;

    _before
    xor eax, eax        ; not needed after initialization
    mov byte [eax], 0   ; the usual access violation trigger
    _after ACCESS_VIOLATION

PAGE_READONLY             equ 2
MEM_COMMIT equ 1000h

    _before
    ; create a non executable page
    push PAGE_READONLY  ; DWORD flProtect
    push MEM_COMMIT     ; DWORD flAllocationType
    push 1              ; SIZE_T dwSize
    push 0              ; LPVOID lpAddress
    call VirtualAlloc

    call [eax]
    ;%IMPORT kernel32.dll!VirtualAlloc
    _after ACCESS_VIOLATION


    push ints_handler
    push dword [fs:0]
    mov [fs:0], esp

    ; you might want to skip that lengthy part
   jmp after_ints

    call ints_start
    cmp dword [counter], INTS_COUNTER
    jnz bad
    jmp after_ints

ints_handler:
    ; let's get the exception error
    mov edx, [esp + 4]
    cmp dword [edx], ACCESS_VIOLATION
    jnz bad

    inc dword [counter]
    mov edx, [esp + 0ch]
    add dword [edx + 0b8h], 2               ; skipping CD ??

    xor eax, eax
    retn

%macro ints 2
%assign i %1
%rep    %2
;    _before
        int i
;    _after ACCESS_VIOLATION
%assign i i+1
%endrep
%endmacro

ints_start:
    ints 000h, 3
                ; int 003h = BREAKPOINT
                ; int 004h = INTEGER_OVERFLOW
    ints 005h, 02ah - 5    ; int 20 = sometimes shown as VXDCALL but triggering the same thing
        ; int 02ah ; edx = ????????, eax = edx << 8 + ?? [step into next instruction]
        ; int 02bh ; eax = C0000258 , ecx = 00000000 [step into next instruction]
        ; int 02ch ; eax = C000014F, ecx = esp , edx = IP (if ran, not stepped) [step into next instruction]
        ; int 02dh = BREAKPOINT if no debugger
        ; int 02eh ; eax = C0000xxx (depends on EAX before), ecx = esp , edx = IP (if ran, not stepped) [step into next instruction]
    ints 02fh, 0ffh - 02fh + 1
INTS_COUNTER equ ($ - ints_start) >> 1
    retn
counter dd 0

after_ints:

STATUS_GUARD_PAGE_VIOLATION equ 080000001h ;
PAGE_GUARD                equ 100h

    _before
    ; create a page with PAGE_GUARD attribute
    push PAGE_READONLY | PAGE_GUARD     ; DWORD flProtect
    push MEM_COMMIT                     ; DWORD flAllocationType
    push 1                              ; SIZE_T dwSize
    push 0                              ; LPVOID lpAddress
    call VirtualAlloc

    call [eax]
    _after STATUS_GUARD_PAGE_VIOLATION   ; OllyDbg will think it's a memory breakpoin access

INTEGER_DIVIDE_BY_ZERO equ 0C0000094h ;;;;;;
    _before
    xor eax, eax
    div eax
    _after INTEGER_DIVIDE_BY_ZERO


INTEGER_OVERFLOW equ 0C0000095h ;;;;;;;;;;;;

    _before
    mov eax, 0
    div ecx
    _after INTEGER_OVERFLOW

    _before
    int 4
    _after INTEGER_OVERFLOW

    _before
    mov cl, 07fh
    inc cl
    into        ; int 4 on OF
    _after INTEGER_OVERFLOW


BREAKPOINT equ 080000003h ;;;;;;;;;;;;;;;;;;

    _before
    int3    ; classic CC
    _after BREAKPOINT

    _before
    int 3   ; different encoding, CD 03
    _after BREAKPOINT

    _before
    int 2dh ; no exception triggered under a debugger
    inc eax ; and next byte is skipped by OllyDbg
    jmp bad
    _after BREAKPOINT

    _before
    call DebugBreak ; system official int3 call
    ;%IMPORT kernel32.dll!DebugBreak
    _after BREAKPOINT

INVALID_LOCK_SEQUENCE equ 0C000001eh;;;;;;;;

    _before
    lock nop
    _after INVALID_LOCK_SEQUENCE

INVALID_HANDLE equ 0C0000008h ;;;;;;;;;;;;;;
    _set bad
    push -1
    call CloseHandle    ; will trigger an exception only if a debugger is present
    _clear

PRIVILEGED_INSTRUCTION equ 0C0000096h;;;;;;;
    _before
    hlt
    _after PRIVILEGED_INSTRUCTION

good:
    push MB_ICONINFORMATION ; UINT uType
    push success            ; LPCTSTR lpCaption
    push successmsg         ; LPCTSTR lpText
    push 0                  ; HWND hWnd
    call MessageBoxA
    push 0
    call ExitProcess        ; UINT uExitCode
bad:
    push MB_ICONERROR   ; UINT uType
    push error          ; LPCTSTR lpCaption
    push errormsg       ; LPCTSTR lpText
    push 0              ; HWND hWnd
    call MessageBoxA
    push 042h
    call ExitProcess    ; UINT uExitCode

error db "Bad", 0
errormsg db "Something went wrong...", 0
success db "Good", 0
successmsg db "Expected behaviour occured...", 0

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess
;%IMPORT kernel32.dll!CloseHandle

;%IMPORTS

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE

; Ange Albertini, Creative Commons BY, 2009-2010