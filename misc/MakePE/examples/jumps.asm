; various standard, obscure, obfuscated ways to jump

; may not run under any other os but XP (value of CS) or with DEP enabled (call on stack)

; compile with makepe

%include '../onesec.hdr'

%macro _ 0  ; remove them to make the file shorter
    nop
    jmp bad
    nop
%endmacro

_CS equ 01bh ; cs is 01bh on Windows XP usermode, will fail if different

EntryPoint:
    jmp short _jmp1     ; short jump, relative, EB
_

_jmp1:
    jmp near _jmp2      ; jump, relative, E9
_

_jmp2:                  ; jump via register
    mov edi, _jmp3
    jmp edi
_

_jmp3:
    jmp dword [buffer1]
    buffer1 dd _jmp4
_

    ; far jump, absolute
_jmp4:
                        ; jmp far is encoded as EA <ddOffset> <dwSegment>
;    mov [_patchCS + 5], cs
_patchCS:
    jmp _CS:_jmp5
_

_jmp5:
    ; mov [buffer3 + 4], cs
    jmp far [buffer3]
buffer3:
    dd _startflag
    dw _CS
_

                ; flags have the same starting values
_startflag:
                ; so this jump will always be taken
    je _startvals
_

_startvals:             ; conditional jump, assuming start values
    cmp eax, 0          ; eax is 0 on start of execution
    jz _jmpmid
_

_jmpmid:
    jmp $ + 3           ; jump in the middle of next instruction
    db 09ah
    jmp _jmpmidself
_

_jmpmidself:            ; jump in the middle of current instruction
    jmp $ + 1           ; jmp $+1 encodes as EB FF
    db 0c0h             ; FF C0 is decoded as inc eax
    dec eax             ; revert the changes of the inc eax
    jmp _setflag
_
                ; set a flag via an opcode, then take inconditionally a conditional jump
_setflag:
    stc         ; set carry flag
                ; jump if below is synonym of jump if carry is set (jb = jc)
    jb _setflag2
_
                ; set a flag manually, then take inconditionally a conditional jump
_setflag2:
    pushfd
    or dword [esp], 0800h   ; set Overflow flag
    popfd
    jo _oppjxx
_

_oppjxx:
    jz _opploop         ; two opposite conditional jumps after each other
    jnz _opploop
_

_opploop:               ; two opposite loop instructions after each other
    loope _jecx
    loopne _jecx
_

_jecx:                  ; the only conditional jxx on register content
    db 66h              ; YASM doesn't recognize bswap cx
    bswap ecx
                        ;    xor ecx, ecx
    jcxz _loop
_

_loop:
    bswap ecx
    db 66h              ; YASM doesn't recognize bswap cx
    bswap ecx
    loop _loopword
_

_loopword:
    mov ecx, 0ffff0001h
    db 67h
    loop badloop        ; if your emulator actually checks ecx, it will be wrong
    loop _pushret
badloop:
_

_pushret:               ; push an address then return to it
    push _pushretf
    ret                 ; it's also a way to make an absolute jump without changing a register or flag.
_

_pushretf:
    push cs
    push _pushiret
    retf
_

_pushiret:
    pushfd
    push cs
    push _callstack
    iretd
_

_callstack:
    push _noreturn
    push 0c308c483h     ; decodes as add esp,8 / retn
    call esp            ; won't work with DEP enabled
_
    ; call an address but never return
_noreturn:
    call _noreturn2
_

_noreturn2:
    add esp, 4

    ; call but return address is changed
_callchange:
    call _callchange2
_

_callchange2:
    mov dword [esp], _pushcallret
    ret
_

_pushcallret:           ; combination of push, ret and call
    push _callback
    call $ + 5
    ret
_

    ; using a CALLBACK based API
_callback:
    push 012345678h     ; lParam                Application-defined value
    push 0              ; dwFlags               Flags specifying the format of the language to pass to the callback function.
                        ;                       (can trigger 0x3ec ERROR_INVALID_FLAGS if wrong)
    push _scanandjump   ; UILanguageEnumProc    our callback function
    call EnumUILanguagesA
_
;%IMPORT kernel32.dll!EnumUILanguagesA

    ; look for some specific hex sequence in a loaded code range, and jump to it
_scanandjump:
    mov esi, dword [esp]    ; Kernel32 return address is in the stack
_scanloop:
    inc esi
    mov al, byte [esi]
    cmp al, 0c3h
    jnz _scanloop       ; let's look for a C3 RETN opcode

    push _spawnthread   ; and use it ourselves
    jmp esi
_
    ; create another thread in current process
_spawnthread:
    push 0              ; LPDWORD lpThreadId
    push 0              ; DWORD dwCreationFlags
    push 0              ; LPVOID lpParameter
    push _sehjump       ; LPTHREAD_START_ROUTINE lpStartAddress
    push 010000h        ; SIZE_T dwStackSize    ; typically 0 but this PE has a 0 stack in the header
    push 0              ; LPSECURITY_ATTRIBUTES lpThreadAttributes
    call CreateThread
    call ExitThread     ; other options: Sleep(dwMilliseconds), WaitForSingleObject, infinite loop (jmp $), or actually doing something meaningful
_

;%IMPORT kernel32.dll!CreateThread
;%IMPORT kernel32.dll!ExitThread

    ; set up an exception handler then trigger it
_sehjump:
    push _sehcontextchange_handler
    push dword [fs:0]
    mov [fs:0], esp                 ; no cleaning here, but it's quite common in packers
    db 66h
    jmp $ + 2
_

_sehcontextchange_handler:
    mov eax, [esp + 0ch]
    mov dword [eax + 0b8h], _sehcontextchange_end
    xor eax, eax
    retn
_

_sehcontextchange_end:          ; cleaning - not strictly required :p
    pop dword [fs:0]
    add esp, 4                  ; + 2 because call word pushed a word
    jmp _setldt
_

    ;set a new local descriptor, and jump to it
_setldt:
    base equ IMAGEBASE - 123456h    ; can be anything, just smaller than IMAGEBASE
    selector equ 0314h

    ; it might be worth explaining this more in detail, but it's completely f*cked up...
    push 0
    push 0
    push 0
    push (base & 0ff000000h) + 0c1f800h + ((base >> 10h) & 0ffh)
    push (((base << 10h) | 0ffffh)) & 0ffffffffh
    push selector
    call NtSetLdtEntries
    jmp selector:(_newsegment - base)
_
;%IMPORT ntdll.dll!NtSetLdtEntries

;   db 69h ; just for obfuscation
_newsegment:
    nop
    jmp _CS:_oldsegment
_
;   db 69h ; just for obfuscation
_oldsegment:
    jmp good

bad:
    push MB_ICONERROR   ; UINT uType
    push error          ; LPCTSTR lpCaption
    push errormsg       ; LPCTSTR lpText
    push 0              ; HWND hWnd
    call MessageBoxA
    push 042h
    call ExitProcess    ; UINT uExitCode
good:
    push MB_ICONINFORMATION ; UINT uType
    push success            ; LPCTSTR lpCaption
    push successmsg         ; LPCTSTR lpText
    push 0                  ; HWND hWnd
    call MessageBoxA
    push 0
    call ExitProcess        ; UINT uExitCode

error db "Bad", 0
errormsg db "Something went wrong...", 0
success db "Good", 0
successmsg db "Expected behaviour occured...", 0

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess

;%IMPORTS
align FILEALIGN,db 0
SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE

;Ange Albertini 2009-2010
