#!/usr/bin/env python
#
# takes 2 paletted (16c , 4BPP) pictures and merge them in a single file with 2 palettes
# => image schizophreny, depending on which palette is used (ex: Internet Explorer / Imagine)
#
# Ange Albertini, Philippe Teuwen, BSD Licence, 2014-2015
# Based on Dominique Bongard's original idea

import struct, sys, zlib, binascii

_MAGIC = "\x89PNG\x0d\x0a\x1a\x0a"
_crc32 = lambda d:(binascii.crc32(d) % 0x100000000)

def pngread(f):
    """gets a file, returns a list of [type, data] chunks"""
    assert f.read(8) == _MAGIC
    chunks = []
    while (True):
        l, = struct.unpack(">I", f.read(4))
        t = f.read(4)
        d = f.read(l)
        assert _crc32(t + d) == struct.unpack(">I", f.read(4))[0]
        chunks += [[t, d]]
        if t == "IEND":
            return chunks
    raise(BaseException("Invalid image"))

def pngmake(chunks):
    """returns a PNG binary string from a list of [type, data] PNG chunks"""
    s = [_MAGIC]
    for t, d in chunks:
        assert len(t) == 4
        s += [
            struct.pack(">I", len(d)),
            t,
            d,
            struct.pack(">I", _crc32(t + d))
            ]
    return "".join(s)

FileNameInPNG1, FileNameInPNG2, FileNameOutPNG = sys.argv[1:4]

with open(FileNameInPNG1, "rb") as file1:
    in1 = pngread(file1)

with open(FileNameInPNG2, "rb") as file2:
    in2 = pngread(file2)

for i in [in1, in2]:
    # expect specific chunks
    assert [e[0] for e in i] == ["IHDR", "PLTE", "IDAT", "IEND"]
    # 16 colors palette, in RGB
    assert len(i[1][1]) == 3 * 16


header = in1[0][1]
# both images should have the same dimensions, bpp...
assert in2[0][1] == header

#assume they have a 4 BPP
assert header[8] == "\4"

width, height = struct.unpack(">LL", in1[0][1][0:0 + 4 * 2])

data1 = zlib.decompress(in1[2][1])
data2 = zlib.decompress(in2[2][1])

assert len(data1) == len(data2)

#merge pixel datas
data = []
for y in range(height):
    data.append("\0") # line filter = None

    for x in range(width / 2):
        i = x + ((width / 2) + 1) * y

        # encoding each palette index on each nibble
        n1 = ord(data1[i]) >> 4
        n2 = ord(data2[i]) >> 4
        data.append(chr((n1 << 4) | n2))

        n1 = ord(data1[i]) & 0xf
        n2 = ord(data2[i]) & 0xf
        data.append(chr((n1 << 4) | n2))


#compute palettes
plte1, plte2 = [], []
for i in range(16):
    # each row is made of the i-th color
    plte1.append(16 * in1[1][1][i*3:i*3 + 3])
    # each column is made of the i-th color
    plte2.append(in2[1][1])

# set BPP to 8
header = header[:8] + "\x08" + header[9:]

out = [
    ["IHDR", header],
    ["PLTE", "".join(plte1)],
    ["PLTE", "".join(plte2)],
    ["IDAT", zlib.compress("".join(data), 9)],
    ["IEND", ""]
]

with open(FileNameOutPNG, "wb") as fout:
    fout.write(pngmake(out))
