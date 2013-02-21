; Imports obfuscation where trampolines are built between api calls and API
; on a separate buffer (allocated or stack) so that it's missed during dumps
; 2 cases:
; - buffer is on the stack
; - buffer is allocated
%define on_stack

; also, imports directory is erased for more anti-dumping.
; custom imports loading would be even better - not the purpose here.


%include '..\..\standard_hdr.asm'

OEP:
    push MB_ICONINFORMATION ; UINT uType
    push tada               ; LPCTSTR lpCaption
    push helloworld         ; LPCTSTR lpText
    push 0                  ; HWND hWnd
    call dword [trampMsgBox]

    push 0                  ; UINT uExitCode
    call dword [trampExit]
_c
EntryPoint:
    sub esp, 3 * 4
    call PatchImports
    jmp OEP
_c
PatchImports:
    pusha
%ifdef on_stack
;    mov ebx, IMAGEBASE
    mov ebx, esp
    add ebx, 24h
%else
    push PAGE_EXECUTE_READWRITE  ; DWORD flProtect
    push MEM_COMMIT              ; DWORD flAllocationType
    push 1                       ; SIZE_T dwSize
    push 0                       ; LPVOID lpAddress
    call VirtualAlloc
    mov ebx, eax
%endif

    mov edi, trampMsgBox
    mov esi, __imp__MessageBoxA
    call patch_trampoline

    add ebx, 6
    mov edi, trampExit
    mov esi, __imp__ExitProcess
    call patch_trampoline

; let's erase the imports directory too
    mov edi, IMPORT_DESCRIPTOR
    mov ecx, DIRECTORY_ENTRY_IMPORT_SIZE
    mov al, 0
    rep stosb
    popad
    retn
_c
patch_trampoline:
    mov eax, [esi]
    mov byte [ebx], 068h            ; 68 xxxxxxxx   push xxxxxxxx
    mov [ebx + 1], eax
    mov byte [ebx + 5], 0c3h        ; C3            retn

    mov [edi], ebx
    retn
_c
;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess
;%IMPORT kernel32.dll!VirtualAlloc
_d
trampMsgBox dd 0
trampExit dd 0

tada db "Tada!", 0
helloworld db "Hello World!",0
_d
;%IMPORTS

%include '..\..\standard_ftr.asm'

;Ange Albertini, BSD Licence, 2010-2011