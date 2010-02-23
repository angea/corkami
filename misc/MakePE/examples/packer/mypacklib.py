#common fonctions for minimalist packers

import os, pefile

IMAGE_SCN_MEM_WRITE = pefile.SECTION_CHARACTERISTICS["IMAGE_SCN_MEM_WRITE"]

def build_stub(my_stub):
    temp_asm = open("temp.asm", "wt")
    temp_asm.write(my_stub)
    temp_asm.close()

    os.system("yasm temp.asm")

    temp_bin = open("temp", "rb")
    stub = temp_bin.read()
    temp_bin.close()

    # cleaning temp files
    os.remove("temp")
    os.remove("temp.asm")

    return stub

def getEPsection(pe):
    """returns the section that contains the entry point, -1 if none"""
    for i,s in enumerate(pe.sections):
        if s.contains_rva(pe.OPTIONAL_HEADER.AddressOfEntryPoint):
            break
    else: return -1
    return i

def load(name = "..\compiled.exe"):
    """load PE, return pe object, it's entry point, imagebase, VA of the section of the entry point, its physical size"""
    pe = pefile.PE(name)
    oep = pe.OPTIONAL_HEADER.AddressOfEntryPoint
    ib = pe.OPTIONAL_HEADER.ImageBase
    section = pe.sections[getEPsection(pe)]
    start, size = section.VirtualAddress, section.SizeOfRawData

    return pe, oep, ib, start, size

def patchas(pe, name, offset, buffer, ep=None):
    if ep is None:
        ep = offset
    # patch our stub
    pe.set_bytes_at_rva(offset, buffer)

    # set the entry point to our new value
    pe.OPTIONAL_HEADER.AddressOfEntryPoint = ep

    # save the result
    pe.write(name)

def disasm(pe, offset):
    """generator outputting disassembly of hex sequences at <offset> until an unsupported instruction is met"""
    pointer = offset
    ip = pointer
    ib = pe.OPTIONAL_HEADER.ImageBase
    while True: # virtualize until unsupported instruction
        ip = pointer
        b = pe.get_data(pointer, 1)
        if b == "\x68":     # 68 xxxxxxxx push <dword>
            pointer += 1
            arg = pe.get_dword_at_rva(pointer)
            pointer += 4
            yield [ip, "PUSH", arg]

        elif b == "\x6A":   # 6A xx push <byte>
            pointer += 1
            arg = ord(pe.get_data(pointer, 1))
            pointer += 1
            yield [ip, "PUSH", arg]

        elif b == "\xE8":   # E8 xxxxxxxx call <dword> ; (dword is relative to next instruction address)
            return_ip = pointer + 5
            pointer += 1
            arg = pe.get_dword_at_rva(pointer)
            pointer += 4
            arg += pointer + ib      # turning an EIP-relative address to an absolute VA
            yield [ip, "CALL", arg]

        elif b == "\xFF":   # FF25 xxxxxxxx jump [<dword>]
            if ord(pe.get_data(pointer + 1, 1)) != 0x25:
                break
            pointer += 2        # only FF25 is supported here
            arg = pe.get_dword_at_rva(pointer)
            pointer += 4
            yield [ip, "JUMP", arg]

        else:
            # unsupported, let's finish
            break

# Ange Albertini, Creative Commons BY, 2009-2010
