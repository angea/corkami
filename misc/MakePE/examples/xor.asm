; dword xor crypted helloworld

%include '..\standard_hdr.asm'

KEY equ 0cafebabeh

EntryPoint:
    call decrypt
    nop
buffer:
incbin 'xor.enc'
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
    mov ecx, BUFFLEN / 4
    mov ebx, KEY
_loop:
    lodsd
    xor eax, ebx
    stosd
    loop _loop
    retn


%include '../standard_ftr.asm'

;Ange Albertini, Creative Commons BY, 2010
