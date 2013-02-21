; an int 2a based delay loop (anti emulation)

%include '..\..\standard_hdr.asm'

EntryPoint:
    mov esi,80h
    xor edi,edi
loop0:
    int 2ah
    mov ecx,eax

loop1:
    int 2ah
    cmp eax,ecx
    je loop1

    mov ecx,eax
    mov ebx,eax
    int 2ah
    mov ecx,eax

loop2:
    int 2ah
    cmp eax,ecx
    je loop2

    mov ecx,eax
    sub eax,ebx
    inc eax
    and eax,0fffffffeh
    add edi,eax
    dec esi
    jnz loop0

    mov eax,edi
    cmp eax,0800h
    jnb good
    jmp bad

%include '..\goodbad.inc'

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess

;%IMPORTS

%include '..\..\standard_ftr.asm'

;Ange Albertini, Creative Commons BY, 2009-2010
