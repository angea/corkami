;manually loading imports

%include '..\standard_hdr.asm'

%include 'entrypoint.inc'

MessageBoxA:
    jmp [iMessageBoxA]
ExitProcess:
    jmp [iExitProcess]
nop
%include 'imports_loader.inc'
nop
;%IMPORT kernel32.dll!GetProcAddress
;%IMPORT kernel32.dll!LoadLibraryA
nop
;%IMPORTS
%include '..\standard_ftr.asm'

;Ange Albertini, Creative Commons BY, 2010