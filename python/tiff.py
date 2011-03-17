# tiny tiff parser

# Ange Albertini, BSD Licence, 2011

import struc
import sys

_file = open(sys.argv[1], "rb")
s  = struc.struc(_file)

#TODO
# * extract information from valoff
# * go to next directory

import struct
def ReadEndianness(v):
    global _C
    Little = {"II":True, "MM":False}[struct.pack("H", v)]
    _C = {True:"<", False:">"}[Little]

def Check42(v):
    if v != 42:
        print v
        
    return


s.handle(["H,ByteOrder", ReadEndianness])
if s.handle([_C + "H,_42", None]) != 42:
    raise(BaseException("Wrong Magic"))

diroffset = s.handle([_C + "I,Offset", None])
while (diroffset != 0):
    s.seek(diroffset)    
    nbdir = s.handle([_C + "H,Number", None])

    s.levelup()
    for _ in xrange(nbdir):
        tag = s.handle([_C + "H,Tag", None])
        type_ = s.handle([_C + "H,type_", None])
        typename = {1:"Byte", 2:"Ascii", 3:"Short", 4:"Long", 5:"Rational"}[type_]
        typesize = {1:1,2:1,3:2,4:4,5:8}[type_]
        count_ =  s.handle([_C + "I,Count", None])
        valoff = s.handle([_C + "I,ValOffset", None]) # if Count*Size(type_) > 4 then offset else val
        print
    s.leveldown()

    diroffset = s.handle([_C + "I,Offset", None])
