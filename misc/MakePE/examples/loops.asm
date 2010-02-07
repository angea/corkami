; unusual forms of looping

%include '../onesec.hdr'

EntryPoint:
    ; a loop you want to skip or fast forward
    mov ecx, 0ffffffffh
    loop $          ; xor ecx, ecx - could take several seconds

nop
nop

;loop with a single unconditional jump to a calculated adress depending on the loop condition
    ; our loop initializer
    mov cl, 4
loop1_start:
    xor eax, eax
    ; our loop condition, that changes the flags
    dec cl

    setz ah                                 ; ah = ZF
    aad loop1_end - loop1_start             ; al = ZF * (loop1_end - loop1_start)
;    setz bl                                ; bl = ZF
;
;    mov eax, loop1_end - loop1_start         ; eax = ZF * (loop1_end - loop1_start)
;    mul bl

    add eax, loop1_start                     ; possible to turn this adjustment in word only but yasm doesn't support complex enough macros
    jmp eax
loop1_end:
    test cl, cl
    jnz bad

nop
nop

; loop with multiple fake conditional jumps

%macro jump 4
    mov %1, %2
    xor %1, cx
    cmp %1, %2 ^%3
    jz loop3_end + %4
%endmacro

    ; loop initializer
    mov cx, 4
loop3_start:
    dec cx

    jump ax, 0cafeh, 5, 1
    jump bx, 0bf31h, 0, 0
    jump dx, 0c0deh, 0fh, -1
    jump si, 0babeh, 0eh, 2

    jmp loop3_start
loop3_end:
    test cl, cl
    jnz bad

nop
nop

;SEH-based loop, by Peter Ferrié
    push 3              ;     mov ecx, 3
    pop ecx

    call l1             ;     push handler
                        ;     jmp setup
                        ; handler:

    pop eax             ;     mov esp, [esp + 8] ; removes previous SEH
    pop eax
    pop esp

    pop ecx             ; restore counter value from the stack
l1:
    dec ecx             ; decrement counter, and sets ZF accordingly

    push ecx            ; save counter value back, and sets a fake SEH record on the stack

    setne cl            ; setne = cl = ZF ? 00 : 01

    xor eax, eax        ; set exception handler
    mov [fs:eax], esp

    ror cl, 01          ; cl = ZF ? 00 (OF 0): 80 (OF 1)
    into                ; OF ? int 4 : nothing => ZF ? nothing : exception trigger

    pop ecx
    test cl, cl
    jz good
    jmp bad

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
;%IMPORT kernel32.dll!ExitProcess
;%IMPORT user32.dll!MessageBoxA

error db "Bad", 0
errormsg db "Something went wrong...", 0
success db "Good", 0
successmsg db "Expected behaviour occured...", 0

;%IMPORTS

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE

;Ange Albertini 2010
