# this program generates a DLL to bring backward compatibility to executables compiled under SP3

# those executables will expect new functions from kernel32.
# this dll creates dummies for these functions leaving the other untouched.
# this lower the security provided by these new functions, but make it possible to run new executable on older systems
# with minimum binary modification

# so patch the DLL name in the imports of your program, and maybe as well MSC100*.dll.
# also lower the Major version for windows 2000 compatibility.

import pefile

template = """;%%EXPORT %(api)s
;%%reloc 2
;%%IMPORT kernel32.dll!%(api)s
"""

EXCLUDE = "EncodePointer DecodePointer".split()

tramps = []
import exports
for export in exports.XP:
    if export in EXCLUDE:
        continue
    tramps.append(template % {"api":export})


f = open("kernel31.asm", "wt")
f.write("""
; DLL for kernel32 imports forwarding, with dummy replacement for EncodePointer and DecodePointer

%include '..\..\standard_hdr.asm'

; same image_base as PE on purpose, to show relocations

CHARACTERISTICS EQU IMAGE_FILE_EXECUTABLE_IMAGE | IMAGE_FILE_LINE_NUMS_STRIPPED | IMAGE_FILE_LOCAL_SYMS_STRIPPED | IMAGE_FILE_32BIT_MACHINE | IMAGE_FILE_DLL

EntryPoint:
    retn 3 * 4
_

;%EXPORT DecodePointer
;%EXPORT EncodePointer
    mov eax, [esp+4]
    retn 4

""")

f.write("\n".join(tramps))

f.write("""
;%IMPORTS

;%EXPORTS kernel31.dll

;%relocs

%include '..\..\standard_ftr.asm'

;Ange Albertini, Creative Commons BY, 2010
""")
f.close()