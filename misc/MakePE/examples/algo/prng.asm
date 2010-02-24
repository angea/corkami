; PRNG-based (xor) crypted hello world

%include '..\..\standard_hdr.asm'

KEY equ 0cafebabeh

EntryPoint:
    call decrypt
    nop
buffer:
incbin 'prng.enc'
;    push MB_ICONINFORMATION ; UINT uType
;    push tada               ; LPCTSTR lpCaption
;    push helloworld         ; LPCTSTR lpText
;    push 0                  ; HWND hWnd
;    call MessageBoxA
;_
;    push 0                  ; UINT uExitCode
;    call ExitProcess
;_
;tada db "Tada!", 0
;helloworld db "Hello World!", 0

BUFFLEN equ $ - buffer
align 16, db 0
;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess

;%IMPORTS

decrypt:
    mov esi, buffer
    mov edi, esi
    mov ecx, BUFFLEN
    mov ebx, KEY
_loop:
    imul ebx, ebx, 0x343FD
    add ebx, 0x269EC3
    shr ebx,0x10
    and ebx,0x7FFF
    lodsb
    xor al, bl
    stosb
    loop _loop
    retn

%include '..\..\standard_ftr.asm'

;Ange Albertini, Creative Commons BY, 2010
