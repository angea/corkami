# this program generates a DLL to bring backward compatibility to executables compiled under SP3

# roughly speaking, those executables will expect new functions from kernel32
# this dll creates dummies for these functions leaving the other untouched.
# this lower the security provided by these new functions, but make it possible to run new executable on older systems
# with minimum binary modification

import pefile

template = """;%%EXPORT %(api)s
;%%reloc 2
;%%IMPORT kernel32.dll!%(api)s
"""

EXCLUDE = "EncodePointer DecodePointer".split()

enums = []
pe = pefile.PE(r"c:\windows\system32\kernel32.dll")
for sym in pe.DIRECTORY_ENTRY_EXPORT.symbols:
    if sym.name in EXCLUDE:
        continue
    enums.append(template % {"api":sym.name})


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

f.write("\n".join(enums))
f.write("""
;%IMPORTS

;%EXPORTS kernel31.dll

;%relocs

%include '..\..\standard_ftr.asm'

;Ange Albertini, Creative Commons BY, 2010
""")
f.close()