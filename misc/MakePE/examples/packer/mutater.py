# Minimalist mutater
# handles only PUSH (68/6A), CALL (E8), and JUMPS <dword> (FF25)
# no real code analysis, but mutating our original program and using only ADD, MOV, RETN

import pefile, mypacklib

pe, oep, ib, start, size = mypacklib.load()

# mutates the original code
# (needs to parse the hex, transform the underneath assembly, and rewrite it)

mutated_code = """
bits 32
section .text valign=1 vstart=0%(start_va)08xh
""" % {"start_va":oep + ib}

#we need to keep track of jump targets
labels = []

pointer = oep

# parse the hex and convert in disassembly
for addr, op, arg in mypacklib.disasm(pe, oep):

    # jump targets need to be taken into account
    if addr + ib in labels:
        mutated_code += """
        _%(jump_va)i:
        """ % {"jump_va":addr + ib}

    # rewrite opcodes in mutated form
    if op == "PUSH":
        mutated_code += """
        add esp, -4
        mov dword [esp], %(arg)i
        """ % {"arg" : arg}

    elif op == "CALL":   # E8 xxxxxxxx call <dword> ; (dword is relative to next instruction address)
        labels.append(arg)          # we need to remember where it jumps
        mutated_code += """
        add esp, -4
        mov dword [esp], _%(returnaddress)i_ret
        add esp, -4
        mov dword [esp], _%(calltarget)i
        retn
        _%(returnaddress)i_ret:
        """ % {"returnaddress": addr, "calltarget":arg}

    elif op == "JUMP":   # FF25 xxxxxxxx jump [<dword>]
        mutated_code += """
        mov eax, dword [%i]
        add esp, -4
        mov dword [esp], eax
        retn""" % arg

# generate our stub
stub = mypacklib.build_stub(mutated_code)

#patch the file with our changes, and modify EntryPoint value
mypacklib.patchas(pe, "mutated.exe", oep, stub)

# Ange Albertini, Creative Commons BY, 2009-2010
