%include 'head.inc'
_d
%define DEP

; from roy g big's subtle SEH
; not working ATM

EntryPoint:
        push    8               ;replaced by "previous SEH"
        pop     eax             ;replaced by "previous SEH"
        call    delta           ;instruction must end on dword-aligned offset
                                ;replaced by handler address
%ifdef DEP                      ;you must define this variable 0 or 1
        push    -1              ;set "previous SEH"
                                ;if hardware DEP is not enabled by Windows for process, then stack chain is checked
                                ;all entries must be on stack, and finish with -1 entry
%else
        push    eax             ;set "previous SEH", just saves one byte, no other effect
                                ;if hardware DEP is enabled by Windows for process, then stack chain is not checked
                                ;Windows assumes that data execution will cause exception
%endif
        mov     ecx, fs         ;push would require extra dword before previous SEH
        mov     ss, ecx         ;emulator killer, and anti-single-step, too ;)
        xchg    esp, eax        ;fs:8
        call    set_seh         ;change stack limit so our code looks like stack
set_seh:
        push    eax             ;set new SEH
                                ;cannot appear after actual handler, otherwise handler looks like is on stack
                                ;can restore ss here if you want to delay exception
        mov     esp, ebp        ;esp must be valid on except. Windows will restore ss for us
                                ;cannot use leave to pop from stack because current ss limit is too small
                                ;to delay exception, add jmp here to somewhere else
delta:
        pop     esp             ;cause exception on second pass
        call    esp             ;set handler address

handler:
    push Msg
    call [__imp__printf]
    add esp, 1 * 4
_
    push 0
    call [__imp__ExitProcess]
_c

Msg db " * set a SEH via 'standard' stack", 0ah, 0
_d

bound_ dd 3, 5
ALIGN FILEALIGN, db 0