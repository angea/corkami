;PE wrap around opcodes32
;compile with makePE
IMPORT_DESCRIPTOR equ IMAGEBASE

%include '..\..\onesec.hdr'

EntryPoint:
%include 'opcodes32.asm'

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE

;Ange Albertini, Creative Commons BY, 2009-2010