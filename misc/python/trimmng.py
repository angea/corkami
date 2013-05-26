# a simple script to trim MNGs without recompression

import struct
import sys

PNGSIG = "\x89PNG\x0d\x0a\x1a\x0a"
MNGSIG = "\x8AMNG\x0d\x0a\x1a\x0a"


def ReadNG(fn):
    with open(fn, "rb") as f:
        r = f.read()

    chunks = []
    cursor = 0
    sig = r[cursor:cursor + 8]
    cursor += 8
    if sig not in [PNGSIG, MNGSIG]:
        print "wrong sig"
        sys.exit()
    while cursor < len(r):
        offset = cursor
        size = struct.unpack(">I", r[cursor:cursor + 4])[0]
        cursor += 4
        type_ = r[cursor: cursor + 4]
        cursor += 4
        datacrc = r[cursor: cursor + size + 4]
        cursor += size + 4
        if type_ in ["tEXt"]:
            continue
        chunks += [[offset, datacrc, type_]]
    return chunks


def parseMHDR(c):
    assert c[2] == "MHDR"
    x, y, ticks = struct.unpack(">III", c[1][:4 * 3])
    return x, y, ticks


def WriteChunk(t, c):
    t.write(struct.pack(">I", len(c[1]) - 4))
    t.write(c[2])
    t.write(c[1])


def WritePNGFrame(i):
    with open("%s%03i.png" % (fnt, i), "wb") as t:
        t.write(PNGSIG)
        for ii in xrange(3):
            WriteChunk(t, chunks[i * 3 + 1 + ii])


def WriteTruncatedMNG(i, fn): # skip i frames
    # need to skip (i / ticks) seconds
    with open(fn, "wb") as t:
        t.write(MNGSIG)
        WriteChunk(t, chunks[0])
        for c in chunks[1 + i * 3:]:
            WriteChunk(t, c)


fn = sys.argv[1]
fnt = fn.replace(".mng", "")

chunks = ReadNG(fn)

x, y, ticks = parseMHDR(chunks[0])
print "MNG %i x %i, %i f/s" % (x, y, ticks),
print "(%i frames)" % ((len(chunks) - 2) / 3) # 1 MHDR, 1 MEND, then IHDR/IDAT/IEND sequences

#for i in xrange(40):
#    WritePNGFrame(i)
#
#WriteTruncatedMNG(38, "test.mng")
