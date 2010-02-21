; open an external data file, and use the content to display a messagebox

%include '..\standard_hdr.asm'

times 5 db 0
EntryPoint:
%include 'bundled.inc'

;%IMPORT kernel32.dll!CreateFileA
;%IMPORT kernel32.dll!ReadFile
;%IMPORT kernel32.dll!CloseHandle

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess

;%IMPORTS

%include '../standard_ftr.asm'

;Ange Albertini, Creative Commons BY, 2010