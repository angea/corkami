# tiny png parser

# Ange Albertini, BSD Licence, 2011

import struct
import sys

def GetValue(s):
    global _file, _level
    type_, name = s.split(",")
    size = struct.calcsize(type_)
    offset = _file.tell()
    data = _file.read(size)
    v = struct.unpack(type_, data)[0]
    print "%04X:(+%i) %s%s: %x" % (offset, size, " " * _level, name, v)
    return v

def handle(typact):
    type_, action = typact
    v = GetValue(type_)
    if action is not None:
        action(v)
    return v

def handles(l):
    for i in l:
        handle(i)

def setoffset(v):
    global _file
    _file.seek(v)

_file = open(sys.argv[1], "rb")
_level = 0

############################################
# PNG

import binascii

# todo: add support for ascii buffer....
handle(["8B,header", None])
#sig = _file.read(8)
#if sig != "\x89PNG\x0d\x0a\x1a\x0a":
#        raise(BaseException("Wrong Header"))

while (True): #EOF() ?
    # should be printed only once the structure is confirmed correct
    print "%04X: %s%s:" % (_file.tell(), " " * _level, "Chunk")
    _level += 1
    try:
        size = handle([">I,Size", None])
    except struct.error:
        break
    type_ = handle([">I,Type", None])            # need a type for ascii stuff
    data = _file.read(size)
    crc = handle([">I,CRC32", None])
    if binascii.crc32(struct.pack(">I", type_) + data) % 0x100000000 != crc:
        print "invalid CRC, found : %08x, expected %08x" % (binascii.crc32(struct.pack(">I", type_) + data)  % 0x100000000, crc)
    _level -= 1
