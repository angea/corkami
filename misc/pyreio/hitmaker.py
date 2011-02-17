"""walk PE files, extract entry point, generate hit map of opcodes via libdasm disassembly
groups have their own marks
some operands are also stored

future?
collect opcodes after prefix
represent map for each prefix
"""

import pydasm
import pefile
import struct

import os
import sys
import pprint

NUMBYTES = 4
SHOW_NEW = False

GROUPS = set([
    0x80, 0x81, 0x82, 0x83,
    0xc0, 0xc1,
    0xd0, 0xd1, 0xd2, 0xd3,
    0xf6, 0xf7,
    0x8f,
    0xc6, 0xc7,
    0xfe,
    0xff,
    ])

GROUPS0F = set([
    0x00,
    0x01,
    0xba,
    0xc7,
    0xb9,
    0x71, 0x72, 0x73,
    0xae, 0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f,
    ])

PREFIX = set([
    0x26, 0x2e, 0x36, 0x3f, 0x64, 0x65,
    0xf0,
    0xf2, 0xf3,
    ])

operands = {
    0xE9:[4,[]],
    0xE8:[4,[]],
    0xEB:[1,[]],
    }

for i in xrange(16):
    operands[0x70 + i] = [1, []]

operands0F = dict()
for i in xrange(16):
    operands0F[0x80 + i] = [4, []]

# for now, PREFIX are taken as a single byte opcode - big potential problem of wrong disasm length...
#TODO: improve that logic, by writing down what might comes next...
#it might be interesting if a specific opcode is always prefixed

hitmap = dict([i, 0] for i in range(256) if i not in GROUPS) #GROUPS.union(PREFIX)
hitmap0F = dict([i, 0] for i in range(256) if i not in GROUPS0F) #GROUPS.union(PREFIX)
hitmap_groups = {}
hitmap0F_groups = {}

for i in GROUPS:
    hitmap_groups[i] = [0] * 8
for i in GROUPS0F:
    hitmap0F_groups[i] = [0] * 8

def mid(b):
    return (b >> 3) & 7

def print_operands(d):
    for i in d:
        if len(d[i][1]) == 0:
            continue
        if d[i][0] == 4:
            print "%02X: %s" % (i, " ".join("%08X" % j for j in d[i][1]))
        elif d[i][0] == 1:
            print "%02X: %s" % (i, " ".join("%02X" % j for j in d[i][1]))

def print_group(d):
    for i in d:
        if max(d[i]) != 0:
            print " %02X:" % i,
            if min(d[i]) == 0:
                print " ".join("%02i" % j if j > 0 else "  "for j in d[i] )
            else:
                print "(complete)"
    return

def print_hitmap(hitmap):
    """collapsed vertically, 0 entries are hidden"""
    for i in xrange(256):
      if (i % 16) == 0:
          line = ["%02X: "% (i)]
      if i not in hitmap or hitmap[i] == 0:
          line.append("   ")
      else:
          line.append("%03i" % hitmap[i])

      if (i % 16) == 15:
          line = " ".join(line)
          if len(line.strip()) > 3:
              print line
    return


def getinfo(data, fn):
    print fn
    offset = 0

#target specific inits

############################################

    while offset < len(data) - 0x10:

#target specific alerts, termination, data collection

####################################

        byte = ord(data[offset])
        byte2 = ord(data[offset + 1])
        previous = -1

        #todo: merge double byte in a recursive way
        if byte == 0x0f:
            byte = ord(data[offset + 1])
            byte2 = ord(data[offset + 2])
            if byte in GROUPS0F:
                previous = hitmap0F_groups[byte][mid(byte2)]
                hitmap0F_groups[byte][mid(byte2)] += 1
            else:
                previous = hitmap0F[byte]
                hitmap0F[byte] += 1
            if byte in operands0F:
                size, l = operands0F[byte]
                if size == 4:
                    op = struct.unpack("L", data[offset + 2:offset + 2 + 4])[0]
                elif size == 1:
                    op = ord(data[offset + 2])
                l.append(op)


        elif byte in PREFIX:
            previous = hitmap[byte]
            hitmap[byte] += 1

            offset += 1
            continue

        elif byte in GROUPS:
            previous = hitmap_groups[byte][mid(byte2)]
            hitmap_groups[byte][mid(byte2)] += 1
        else:
            previous = hitmap[byte]
            hitmap[byte] += 1

        if byte in operands:
            size, l = operands[byte]
            if size == 4:
                op = struct.unpack("L", data[offset + 1:offset + 1 + 4])[0]
            elif size == 1:
                op = ord(data[offset + 1])
            l.append(op)

        instruction = pydasm.get_instruction(data[offset:], pydasm.MODE_32)

        # optional output current line if opcode/group never marked before
        if SHOW_NEW and previous == 0:
            print "%08X: %s %s" % (
                offset,
                (" ".join(["%02X" % ord(i) for i in data[offset:offset + min(NUMBYTES, instruction.length)]])).ljust(NUMBYTES * 3),
                pydasm.get_instruction_string(instruction, pydasm.FORMAT_INTEL, offset))
        offset += instruction.length
    print "final offset %08X"  % offset
    return

filecount = 0
for root, dirs, files in os.walk('.'):
    for file in files[:]:
        if file.find('python') > -1:
            continue
        if file.find('.pyd') > -1:
            continue
        fn = root + '\\' + file
        try:
            pe = pefile.PE(fn)
        except pefile.PEFormatError,s:
            continue
        try:
            data = pe.get_data(pe.OPTIONAL_HEADER.AddressOfEntryPoint, 0x1200)
        except pefile.PEFormatError:
            print "ERROR: data", pe.OPTIONAL_HEADER.AddressOfEntryPoint , fn
            continue
        filecount += 1
    	getinfo(data, fn)

print "%i file(s) analyzed" % filecount

print
print "1 byte:"
print "table"
print_hitmap(hitmap)
print
print "groups"
print_group(hitmap_groups)
print
print

print "2 bytes:"
print "table"
print_hitmap(hitmap0F)
print
print "groups"
print_group(hitmap0F_groups)

print
print_operands(operands)
print
print_operands(operands0F)