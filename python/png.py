# tiny png parser

# Ange Albertini, BSD Licence, 2011

import struc
import sys

_file = open(sys.argv[1], "rb")
s = struc.struc(_file)

############################################
# PNG

import binascii
import struct

# todo: add support for ascii buffer....
s.handle(["8B,header", None])
#sig = _file.read(8)
#if sig != "\x89PNG\x0d\x0a\x1a\x0a":
#        raise(BaseException("Wrong Header"))

while (True): #EOF() ?
    # should be printed only once the structure is confirmed correct

#   print "%04X: %s%s:" % (_file.tell(), " " * _level, "Chunk") # should be handled at class level
    s.levelup()
    try:
        size = s.handle([">I,Size", None])
    except struct.error:
        break
    type_ = s.handle([">I,Type", None])            # need a type for ascii stuff
    data = _file.read(size)
    crc = s.handle([">I,CRC32", None])
    if binascii.crc32(struct.pack(">I", type_) + data) % 0x100000000 != crc:
        print "invalid CRC, found : %08x, expected %08x" % (binascii.crc32(struct.pack(">I", type_) + data)  % 0x100000000, crc)
    s.leveldown()
