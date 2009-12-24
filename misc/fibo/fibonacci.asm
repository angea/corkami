; simple fibonacci number calculator, used as base for various virtualization exercices

.386
.model flat, stdcall
option casemap :none

include c:\masm32\include\kernel32.inc
includelib c:\masm32\lib\kernel32.lib

.code smc   ;  /SECTION:smc,erw

Main proc
    ; start of code to virtualize
    mov ecx, 046

    mov eax, 0
    mov ebx, 1
_loop:
    mov edx, ebx
    add edx, eax
    mov eax, ebx
    mov ebx, edx
    add ecx, -1
    jnz _loop
    mov ecx, ebx
; end of code to virtualize
    cmp ecx, 2971215073 ; 46th fibonacci number
    jnz bad
nop
good:
    push 0
    Call ExitProcess
nop
bad:
    push 42
    Call ExitProcess

Main Endp

End Main

; Ange Albertini, 2009
