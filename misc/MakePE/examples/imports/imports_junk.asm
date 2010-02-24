;manually loaded imports but the trampolines have junk inserted
;to remove references to API in the code during debugging

%include '..\..\standard_hdr.asm'

%include 'entrypoint.inc'

MessageBoxA:
    nop
    jmp [iMessageBoxA]
ExitProcess:
    nop
    jmp [iExitProcess]
nop
%include 'imports_loader.inc'
nop
;%IMPORT kernel32.dll!GetProcAddress
;%IMPORT kernel32.dll!LoadLibraryA
nop
;%IMPORTS

%include '..\..\standard_ftr.asm'

;Ange Albertini, Creative Commons BY, 2010