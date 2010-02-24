;imports loading, with a parameter-based dispatcher instead of direct calls to API
%include '..\standard_hdr.asm'

%include 'entrypoint.inc'

MessageBoxA:
    push 0
    jmp dispatcher
ExitProcess:
    push 1
    jmp dispatcher

dispatcher:
    cmp dword [esp], 1
    jz one
    add esp, 4
    jmp [iMessageBoxA]
one:
    add esp, 4
    jmp [iExitProcess]
nop
%include 'imports_loader.inc'
nop
;%IMPORT kernel32.dll!GetProcAddress
;%IMPORT kernel32.dll!LoadLibraryA

;%IMPORTS

%include '..\standard_ftr.asm'

;Ange Albertini, Creative Commons BY, 2010