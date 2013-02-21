%include '..\..\standard_hdr.asm'

EntryPoint:
    smsw eax
    cmp ax, 03bh
    jnz bad

    fnop
    smsw eax
    cmp ax, 031h   ; 03bh if debugged or
    jnz bad

_1:
    smsw eax
    cmp ax, 031h
    jz _1

    jmp good

%include '..\goodbad.inc'

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess

;%IMPORTS

%include '..\..\standard_ftr.asm'

;Ange Albertini, Creative Commons BY, 2009-2010
