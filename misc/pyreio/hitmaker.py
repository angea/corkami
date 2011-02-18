"""walk PE files, extract entry point, generate hit map of opcodes via libdasm disassembly
groups have their own marks
some operands are also stored

better prefix representation...
"""

# PE specific code here... (init and check)
import spec

import pydasm
import pefile

import struct
import os
import sys
import pprint

NUMBYTES = 4
SHOW_NEW = False

class List(list):
    """a list class with Hex byte representation and hashes for dictionary storage"""
    def __repr__(self):
        return "[%s]" % " ".join("%02X" % _ for _ in self)

    def __hash__(self):
        return `self`.__hash__()

def getMinMax(min_, max_, v):
    if min_ is None:
        min_ = v
    if max_ is None:
        max_ = v
    min_ = min(min_, v)
    max_ = max(max_, v)
    return min_, max_

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
#TODO: make sure lengths are correct even with prefixes
operands = {
    0xE9:[4,{}],
    0xE8:[4,{}],
    0xEB:[1,{}],
    }

for i in xrange(16):
    operands[0x70 + i] = [1, {}]

operands0F = dict()
for i in xrange(16):
    operands0F[0x80 + i] = [4, {}]

hitmap = dict([i, {List([]):0}] for i in range(256) if i not in GROUPS)
hitmap0F = dict([i, {List([]):0}] for i in range(256) if i not in GROUPS0F)
hitmap_groups = {}
hitmap0F_groups = {}

for i in GROUPS:
    hitmap_groups[i] = [{List([]):0}] * 8
for i in GROUPS0F:
    hitmap0F_groups[i] = [{List([]):0}] * 8


def mid(b):
    """ModR/M or SIB ? opcode in the group"""
    return (b >> 3) & 7

def print_operands(d):
    for i in d:
        if len(d[i][1]) == 0:
            continue
        if d[i][0] == 4:
            print "%02X: %s" % (i, " ".join("%08X:%i" % (j, d[i][1][j]) for j in d[i][1]))
        elif d[i][0] == 1:
            print "%02X: %s" % (i, " ".join("%02X:%i" % (j, d[i][1][j]) for j in d[i][1]))

def print_group(d):
    """prefixes are not displayed"""
    groups = 0
    for i in d:
        if max(j[List([])] for j in d[i]) != 0:
            groups += 1
            print " %02X:" % i,
            if min(j[List([])] for j in d[i]) == 0:
                print " ".join("%02i" % j if j > 0 else "  "for j in d[i] )
            else:
                print "(complete)"
    if groups == 0:
        print " <nothing>"
    return

def print_hitmap(hitmap):
    """collapsed vertically, 0 entries are hidden, no displayed prefix"""
    lines = 0
    for i in xrange(256):
      if (i % 16) == 0:
          line = ["%02X: "% (i)]
      if i not in hitmap or hitmap[i][List([])] == 0:
          line.append("   ")
      else:
          line.append("%03i" % hitmap[i][List([])])

      if (i % 16) == 15:
          line = " ".join(line)
          if len(line.strip()) > 3:
              lines += 1
              print line
    if lines == 0:
        print " <nothing>"
    return

def d_l(d, l):
    """set as one or increment a value on the dictionary, based on a List hash"""
    if s not in d:
        d[s] = 1
    else:
        d[s] += 1
    return d[s] - 1


def getinfo(data, fn):
    """parse data and collect information"""
    print fn
    offset = 0

    #target specific inits
    spec.init()

    while offset < len(data) - 0x10:
        prefixes = []
        opcode_off = offset

        byte = ord(data[offset])
        byte2 = ord(data[offset + 1])
        previous = -1

        while byte in PREFIX:
            prefixes.append(byte)
            opcode_off += 1
            byte = ord(data[opcode_off])
            byte2 = ord(data[opcode_off + 1])

        #target specific alerts, termination, data collection
        if spec.check(data, opcode_off, fn) == -1:
            instruction = pydasm.get_instruction(data[offset:], pydasm.MODE_32)
            print "%08X: %s %s" % (
                offset,
                (" ".join(["%02X" % ord(i) for i in data[offset:offset + min(NUMBYTES, instruction.length)]])).ljust(NUMBYTES * 3),
                pydasm.get_instruction_string(instruction, pydasm.FORMAT_INTEL, offset))
            break

        #todo: merge double byte in a recursive way
        if byte == 0x0f:
            opcode_off += 1
            byte = ord(data[opcode_off])
            byte2 = ord(data[opcode_off + 1])
            if byte in GROUPS0F:
                previous = d_l(hitmap0F_groups[byte][mid(byte2)], prefixes)
            else:
                previous = d_l(hitmap0F[byte], prefixes)

            if byte in operands0F:
                size, d = operands0F[byte]
                if size == 4:
                    op = struct.unpack("L", data[opcode_off + 1:opcode_off + 1 + 4])[0]
                elif size == 1:
                    op = ord(data[opcode_off + 1])
                if op not in d:
                    d[op] = 0
                d[op] += 1

        elif byte in GROUPS:
            previous = d_l(hitmap_groups[byte][mid(byte2)], prefixes)
        else:
            previous = d_l(hitmap[byte], prefixes)

        if byte in operands:
            size, d = operands[byte]
            if size == 4:
                op = struct.unpack("L", data[opcode_off + 1:opcode_off + 1 + 4])[0]
            elif size == 1:
                op = ord(data[opcode_off + 1])
            if op not in d:
                d[op] = 0
            d[op] += 1

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
print "operands"
print_operands(operands)
print
print

print "2 bytes:"
print "table"
print_hitmap(hitmap0F)
print
print "groups"
print_group(hitmap0F_groups)

print
print "operands"
print_operands(operands0F)

print
print "prefixes"
for i in hitmap:
    c = 0
    max_ = None
    min_ = None
    for j in hitmap[i]:
        if j == List([]):
            continue
        c += 1
        min_, max_ = getMinMax(min_, max_, hitmap[i][j])
    if c > 0:
        print "opcode %02X %i different prefix(es) found, %i min occurences, %i max occurences" % (i, c, min_, max_)
