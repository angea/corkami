# Minimalist virtualizer
# handles only PUSH (68/6A) and CALL (E8)
# no code analysis, dirty vm module.

import pefile, mypacklib

pe, oep, ib, start, size = mypacklib.load()

# virtualizes the original code
# (needs to parse the hex, transform the underneath assembly, and rewrite it)
opcodes = ["PUSH", "CALL"]
OPCODES = dict([o, chr(i)] for i, o in enumerate(opcodes))

virtualized_code = ""

for addr, op, arg in mypacklib.disasm(pe, oep):
    if op in ["PUSH", "CALL"]:
        # our manual assembly is encoded as: <opcode_byte> <argument_dword>
        virtualized_code += OPCODES[op] + pe.get_data_from_dword(arg)

# now we have our virtual code, which will be placed before our VM stub
vc_len = len(virtualized_code)

# assuming a maximum size for our VM code avoids a second pass

# generate our stub
my_stub = """bits 32
section .text valign=1 vstart=0%(stub_va)08xh
vm_start:
    mov esi, 0%(vc_va)08xh
vm_fetch:
    xor eax, eax
    lodsb
    lea edi , [handlers + eax * 4]
    jmp dword [edi]

push_handler:
    lodsd
    push eax
    jmp vm_fetch

call_handler:
    lodsd
    call eax
    jmp vm_fetch

handlers dd push_handler, call_handler ; generated according to the virtual opcodes table

"""
dummy_stub = my_stub % {'vc_va':start + ib , 'stub_va': start + ib + 1}
stub_length = len(mypacklib.build_stub(dummy_stub))

ep = start + (size - stub_length)
stub_start = ep - vc_len

my_stub = my_stub  % {'vc_va':stub_start  + ib, 'stub_va': ep + ib}

stub = mypacklib.build_stub(my_stub)

# concat our virtual code and our virtual machine code
stub = virtualized_code + stub

#patch the file with our changes, and modify EntryPoint value
mypacklib.patchas(pe, "virtualized.exe", stub_start, stub, ep)

# Ange Albertini, Creative Commons BY, 2009-2010
