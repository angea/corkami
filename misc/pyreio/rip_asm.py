# PyReI/O script to extract selection and turn it into a text file, ready for asm2test
# BSD Licence, Ange Albertini 2011

from pyreio import *
from pydasm import get_instruction, get_instruction_string, MODE_32, FORMAT_INTEL
import os

sel = getselection()
offset = 0
r = ["%i" % len(sel)]

#TODO: get the source offset
while offset < len(sel):
    instruction = get_instruction(sel[offset:], MODE_32)

    l = instruction.length
    h = []
    for _ in sel[offset: offset + l]:
        h.append(" %02X" % ord(_))
    h = ",".join(h)
    asm = get_instruction_string(instruction, FORMAT_INTEL, offset)
    r.append([h, asm])
    offset += l
hlen = max(len(i[0]) for i in r) + 1

filename = "temp%s.txt" % os.getpid()
f = open(filename, "wt")

f.write("Add an * in front of the bytes you want to ignore\n\n")
f.write("\n".join(("%s //%s" % (i[0].ljust(hlen), i[1]) for i in r)))
f.close()
os.system(filename)

#TODO: call asm2test
#f = open(filename, "rt")
#r = f.read()
#f.close()
#
#os.remove(filename)
