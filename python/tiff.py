# tiny tiff parser

# Ange Albertini, BSD Licence, 2011

import struc
import sys

_file = open(sys.argv[1], "rb")
s  = struc.struc(_file)

############################################
# TIFF specific

import struct
def ReadEndianness(v):
    global _C
    Little = {"II":True, "MM":False}[struct.pack("H", v)]
    _C = {True:"<", False:">"}[Little]

def Check42(v):
    if v != 42:
        print v
        raise(BaseException("Wrong Magic"))
    return

def GetNumberDirectories(v):
    global _level
    s.levelup()
    for _ in xrange(v):
        s.handles([
            [_C + "H,Tag", None],
            [_C + "H,type_", None], # {1:Byte, 2:Ascii, 3:Short, 4:Long, 5:Rational} sizes 1,1,2,4,8
            [_C + "I,Count", None],
            [_C + "I,ValOffset", None] # if Count*Size(type_) > 4 then offset else val
            ])
        print
    s.leveldown()

s.handle(["H,ByteOrder", ReadEndianness])
s.handles([
    [_C + "H,_42", Check42],
    [_C + "I,Offset", s.setoffset],
    [_C + "H,Number", GetNumberDirectories],
    ])