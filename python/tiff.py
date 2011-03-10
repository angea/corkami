# tiny tiff parser

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

def handles(l):
    for i in l:
        handle(i)

def setoffset(v):
    global _file
    _file.seek(v)

_file = open(sys.argv[1], "rb")
_level = 0

############################################
# TIFF specific

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
    _level += 1
    for _ in xrange(v):
        handles([
            [_C + "H,Tag", None],
            [_C + "H,type_", None], # {1:Byte, 2:Ascii, 3:Short, 4:Long, 5:Rational} sizes 1,1,2,4,8
            [_C + "I,Count", None],
            [_C + "I,ValOffset", None] # if Count*Size(type_) > 4 then offset else val
            ])
        print
    _level -= 1

handle(["H,ByteOrder", ReadEndianness])
handles([
    [_C + "H,_42", Check42],
    [_C + "I,Offset", setoffset],
    [_C + "H,Number", GetNumberDirectories],
    ])