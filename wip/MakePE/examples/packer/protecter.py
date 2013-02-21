# Minimalist protector
# exits if a debugger is found (via an inline IsDebuggerPresent implementation)

import pefile, mypacklib

pe, oep, ib, start, size = mypacklib.load()

# generates our stub
my_stub = """bits 32
    pushad       ; let's save registers
    mov eax, dword [fs:018h]    ; implementing IsDebuggerPresent
    mov eax, dword [eax + 030h]
    movzx eax, byte [eax + 2]
    test al, al                 ; al is 1 if debugger is present
    jnz _fail
    popad
    push 0%(oep_va)08xh
    retn
_fail:
    popad
    retn
""" % {'oep_va':oep + ib}

stub = mypacklib.build_stub(my_stub)
stub_length = len(stub)

# our stub will be located at the end of the section that contains the entry point
new_ep = start + (size - stub_length)

# patch the file with our changes, and modify EntryPoint value
mypacklib.patchas(pe, "protected.exe", new_ep, stub)

# Ange Albertini, Creative Commons BY, 2009-2010
