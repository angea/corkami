; simple fibonacci number calculator
; with a non-linear IP, and SEH to jump from one opcode to the other via single stepping

; still buggy - need to recover from an instruction after a jump

; Ange Albertini, BSD Licence 2012

%include '../../onesec.hdr'

STEPLENGTH equ 1 << 3
_starts dd _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, 0
_next     dd -1, _6, _7, _4, _2, _1,  0, _3, _9, _5, _8
_trigs dd _0, _7, _8, _5, _3, _2,  0, _4, _10, _6, _9
_trig dd _1

handler:
    mov eax, [esp + exceptionHandler.pContext + 4]
    mov ebx, dword [eax + CONTEXT.regEip]

	mov esi, [_trig]
	mov edi, ebx

    xor ecx, ecx
scan:
    lea edx, [_starts + ecx * 4]
    cmp ebx, [edx]

    jz found
    jl skip

    inc ecx
    jmp scan
found:

    lea edx, [_trigs + ecx * 4]
    mov ebx, [edx]
    mov dword [_trig], ebx

	cmp esi, edi
	jnz skip

    lea edx, [_next + ecx * 4]
    mov ebx, [edx]
    mov dword [eax + CONTEXT.regEip], ebx

    jmp end_
skip:
    nop
end_:
    or dword [eax + CONTEXT.regFlag], 100h
    mov eax, ExceptionContinueExecution
    retn

EntryPoint:
    setSEH handler
    pushf
    or dword [esp], 100h
    popf


start:
_0:
;0
    mov ecx, 046

_1:
;5
    mov eax, ebx

_2:
;3
_loop:
    mov edx, ebx

_3:
;2
    mov ebx, 1

_4:
;4
    add edx, eax

_5:
;9
    jmp end
_6:
;1
    mov eax, 0

_7:
;6
    mov ebx, edx

_8:
;8
    jnz _loop

_9:
;7
    add ecx, -1
_10:

end:
    mov ecx, ebx
    cmp ecx, 2971215073 ; 46th fibonacci number
    jnz bad

    jmp good

%include '..\goodbad.inc'

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess

;%IMPORTS

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE
