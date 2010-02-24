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
    jnz bad


; lfsr loop, idea by Baboon
; lfsr = (lfsr >> 1) ^ (-(lfsr & 1) & poly)
%macro lfsr 3
    mov %3, %1
    and %3, 1
    neg %3
    and %3, %2
    shr %1, 1
    xor %1, %3
%endmacro

%macro lfsr16 2
    lfsr %1, %2, ax
%endmacro

%macro lfsr32 2
    lfsr %1, %2, eax
%endmacro

    mov cx, -1          ; lfsr 16
    mov edx, 01020304h  ; lfsr 32
    mov ebx, 0          ; our iteration counter, just for debugging purpose here

loop_start:
    ; do your loop stuff here

    lfsr32 edx, 0d0000001h ; x^32 + x^31 + x^29 + x^11 + 1
    xor dword [loop_exit], edx  ; exit address is updated blindly

    inc bx
;    cmp ebx, 35
;    jnz loop_start

    lfsr16 cx, 0b400h      ; x^16 + x^14 + x^13 + x^11 + 1
    cmp cx, 0eaa2h          ; our loop termination condition
    jnz loop_start

    jmp dword [loop_exit]       ; exit address is jumped to blindly

loop_end:
    cmp bx, 35
    jnz bad
    jmp good

%include 'goodbad.inc'

;%IMPORT kernel32.dll!ExitProcess
;%IMPORT user32.dll!MessageBoxA

; WARNING - HARDCODED
loop_exit dd 40022fh ^ 0ac5a1c44h; = loop_end ^ 0ac5a1c44h (= 35 iterations) 

;%IMPORTS

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE

;Ange Albertini, Creative Commons BY, 2010
