# Minimalist cryptor
# crypts code section with fixed key

import pefile, mypacklib

pe, oep, ib, start, size = mypacklib.load()

# make the code section writable
section = pe.sections[mypacklib.getEPsection(pe)]
section.Characteristics |= pefile.SECTION_CHARACTERISTICS["IMAGE_SCN_MEM_WRITE"]

# let's generate our stub
my_stub = """bits 32
    pushad       ; save registers
    mov esi, 0%(start_va)08xh  ; set up registers for decryption loop
    mov edi, esi
    mov ecx, 0%(size)08xh
_loop:
    lodsb
    xor al, 042h
    stosb
    loop _loop
    popad
    push 0%(oep_va)08xh
    retn
"""
# % {'start_va':start + ib, 'size':crypted_size, 'oep_va':oep + ib}

# incorrect values, just to get the stub size
dummy_stub = my_stub % {'start_va':start + ib, 'size':size, 'oep_va':oep + ib}
stub_length = len(mypacklib.build_stub(dummy_stub))

# calculating real values
crypted_size = size - stub_length

# final stub generation
final_stub = my_stub % {'start_va':start + ib, 'size':crypted_size, 'oep_va':oep + ib} 

stub = mypacklib.build_stub(final_stub)

# crypts the original section
buffer = list(pe.get_data(start, crypted_size))
for i,b in enumerate(buffer):
    buffer[i] = chr(ord(b) ^ 0x42)
buffer = str().join(buffer)


# write crypted section
pe.set_bytes_at_rva(start, buffer)

# our stub will be located near the end of the section that contains the entry point
new_ep = start + (size - stub_length)

# patch the file with our changes, and modify EntryPoint value
mypacklib.patchas(pe, "crypted.exe", new_ep, stub)

# Ange Albertini, Creative Commons BY, 2009-2010
