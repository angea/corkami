; small stack (or array) scanner that skips invalid address with no SEH

%include '../../onesec.hdr'

MARKER equ 48414042h
EntryPoint:
dd MARKER
_scanloop:
    pop edx
    push edx
    push 2
    pop eax
    int 02eh
    cmp al,5                ; C0000005 (ACCESS VIOLATION) if [eax] is invalid
                            ; C000005C (NO IMPERSONATION TOKEN) if not
    pop edx
    je _scanloop            ; invalid address ?

    mov eax, MARKER
    mov edi,edx
    scasd
    jnz _scanloop                           ; found ?

    add edi, good - EntryPoint - 4          ; scasd already skipped a dword
    jmp edi

    jmp bad

%include '..\goodbad.inc'

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess

;%IMPORTS

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE
