;simple obfuscated file, where code is not visible by IDA, hiew...

;Ange Albertini, BSD licence, 2011

%include '..\..\onesec.hdr'

%macro junkcall 0
    mov eax, 5 + 2
    call junkjump
    jmp near end
    db 069h, 84h
%endmacro

EntryPoint:
    mov eax, good - ($ + 0ah)
    call junkjump
end:
    push 0                  ; UINT uExitCode
    call ExitProcess
_c

;%IMPORT kernel32.dll!ExitProcess
_d

;%IMPORTS
_d

junkjump:
    add [esp], eax
    ret
_c

;%IMPORT user32.dll!MessageBoxA
_d
tada db "Tada!", 0
helloworld db "Hello World!", 0
_d

    times 8 int3
good:
junkcall
    push MB_ICONINFORMATION ; UINT uType
    push tada               ; LPCTSTR lpCaption
    push helloworld         ; LPCTSTR lpText
junkcall
    push 0                  ; HWND hWnd
    call MessageBoxA
    jmp end
_c

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE
