; Using exceptions to control the execution flow

; this is a simple fibonacci number calculator, in which
; the flow instructions have been overwritten to trigger exceptions,
; and an exception handler has been added to manually handle the flow and/or restore the jumps

; consequently, correct execution can't happen without the right execution handler,
; and it's important to notice that code is not restored perfectly unless all code is executed.

; on a heavily protected program, the handler would be in a separate process,
; so dumping the original program will lead to something that might only work until the point of execution where it was dumped, but not further.

; this technique is used in in protectors such as SafeDisc and Armadillo (Software Passport).

; Ange Albertini, BSD Licence, 2010-2012

%include 'head.inc'

_NZ equ 75h
_MP equ 0ebh
JNZ_FLAG equ 040h

%macro Jxx 1 ; a short jump with an INT3 byte as the first byte
    db 0cch, %1 - ($ + 2)
%endmacro

EntryPoint:
    setSEH handler
nop
    mov ecx, 046

    mov eax, 0
    mov ebx, 1
_loop:
    mov edx, ebx
    add edx, eax
    mov eax, ebx
    mov ebx, edx
    add ecx, -1
jnz1:
    Jxx _loop
    mov ecx, ebx
    cmp ecx, 2971215073 ; 46th fibonacci number
jnz2:
    Jxx bad
jmp1:
    Jxx good
_
bad:
    push 42
    call [__imp__ExitProcess]
_c

good:
    push Msg
    call [__imp__printf]
    add esp, 1 * 4
_
    push 0
    call [__imp__ExitProcess]
_c

Msg db " * exception-controlled flow", 0ah, 0
_d

handler:
    mov ebx, [esp + exceptionHandler.pContext + 4]
    mov ecx, dword [ebx + CONTEXT.regEip]

    mov esi, jump_table - 8
lookup:
    add esi, 8
    mov eax, [esi]
    test eax, eax
    jz not_our_exception
;_
    cmp eax, ecx
    jnz lookup
;_
    mov eax, [esi + 4]
    jmp eax
;_c

jnz_handler:
    ; restore the jump for performance reasons - not compulsory
    mov al, _NZ
    call restore_jmp

    ; check the flags when the exception occured
    mov eax, dword [ebx + CONTEXT.regFlag]
    and eax, JNZ_FLAG

    ; act accordingly
    jnz jmp_not_taken
    jmp jmp_taken

jmp_handler:
    ; restore the jump for performance reasons - not compulsory
    mov al, _MP
    call restore_jmp

    ; this jump is unconditional
    jmp jmp_taken

handled:
    mov eax, ExceptionContinueExecution
    retn
;_c

not_our_exception:
    mov eax, 0
    retn
;_c

restore_jmp:
    ; restore the first byte of the jump
    mov ecx, dword [ebx + CONTEXT.regEip]
    mov byte [ecx], al
    retn
;_c

; the EIP change is done by calculating the target address
jmp_taken:
    mov ecx, dword [ebx + CONTEXT.regEip]
    mov eax, ecx    
    add eax, 2
    mov dl, byte [ecx + 1]
    add al, dl
    mov dword [ebx + CONTEXT.regEip], eax
    jmp handled
;_c

jmp_not_taken:
    add dword [ebx + CONTEXT.regEip], 2
    jmp handled
;_c

jump_table:
dd jnz1, jnz_handler
dd jnz2, jnz_handler
dd jmp1, jmp_handler
dd 0

ALIGN FILEALIGN, db 0
