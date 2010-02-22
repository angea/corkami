# generator of empty files with exports from an existing DLL
# ex: genfake.py hal.dll > hal.asm
# (then makepe.py hal.asm)

import pefile, sys

name = sys.argv[1]
names = []
pe = pefile.PE(r"c:\windows\system32\%s" % name)
for sym in pe.DIRECTORY_ENTRY_EXPORT.symbols:
    names += [";%%EXPORT %s" % sym.name]

decls = "\n".join(names)

print """
CHARACTERISTICS equ IMAGE_FILE_EXECUTABLE_IMAGE | IMAGE_FILE_32BIT_MACHINE | IMAGE_FILE_DLL

%%include '../onesec.hdr'

EntryPoint:
    retn 3 * 4

%(decls)s
    retn

;%%reloc 2
;%%IMPORT user32.dll!MessageBoxA
;%%reloc 2
;%%IMPORT kernel32.dll!VirtualAlloc
;%%IMPORTS

;%%EXPORTS %(name)s

;%%relocs

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE

""" % locals()

# Ange Albertini, Creative Commons BY, 2010
