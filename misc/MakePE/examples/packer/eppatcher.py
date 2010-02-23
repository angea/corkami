# Minimalist entry-point patcher
# adds extra code that just jumps to the original entry point.

import pefile, mypacklib

pe, oep, ib, start, size = mypacklib.load()

# generate our stub
my_stub = """bits 32
    push 0%(oep_va)08xh
    retn
""" % {"oep_va":oep + ib}

stub = mypacklib.build_stub(my_stub)

stub_length = len(stub)

#our stub will be located at the end of the section that contains the entry point
new_ep = start + size  - stub_length

# patch the file with our changes, and modify EntryPoint value
mypacklib.patchas(pe, "eppatched.exe", new_ep, stub)

# Ange Albertini, Creative Commons BY, 2009-2010
