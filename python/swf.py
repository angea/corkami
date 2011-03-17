#trivial shockwave crawler

# converts CWS to FWS

import struc
import struct
import sys

def cws(d, v):
    """returns decompressed length, decompressed stream"""
    import zlib
    theoriclen = struct.unpack("<I", d.read(4))[0]
    dec = zlib.decompress(d.read())
    l = len(dec)
    if theoriclen != l + 8:
        raise(BaseException("Wrong Decompressed length"))
    decfile = "".join(
        ["FWS",
        v,
        struct.pack("<I", theoriclen),
        dec,
        ])
    d = struc.data(decfile)
    d.seek(4)
    with open("dec.bin", "wb") as fw:
        fw.write(decfile)
    return d

SIGS = {"FWS":None,"CWS": cws}

with open(sys.argv[1], "rb") as f:
    d = struc.data(f.read())

sig = d.read(3)
if sig not in SIGS:
    raise(BaseException("Wrong Signature"))

version = d.read(1)

if version not in (chr(i) for i in xrange(10)):
    raise(BaseException("Wrong Version"))

do = SIGS[sig]
if do is not None:
    d = do(d, version)

s = struc.struc(d)
# weird, must be wrong
s.handles([
       ["<I,SizeTag", None],
       ["<I,FrameSize", None],
       ["<H,FrameRate", None],
       ["<I,FrameCount", None],
    ])
