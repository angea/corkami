# a simple script to trim MNGs and corresponding WAVs without recompression

# Ange Albertini, BSD Licence 2013

# only MHRD-(IHDR/[PLTE/]IDAT/IEND)*-MEND are supported
# tEXt and FRAM are dropped
# complex framerate via FRAM not supported

# 1- run to get xxx frames
# 2- enter your first wanted frame's number as the 'skip' one
# 3- rerun to trim

DUMP_START = 500
DUMP_RANGE = 500
SKIP = 676

FRAMES_PER_PNG = 3 # FRAM chunks are ignored, PLTE are not expected

import struct
import sys
import wave

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
        if type_ in ["tEXt", "FRAM"]:
            continue
        chunks += [[offset, datacrc, type_]] # ugly, lazy :p
    return chunks


def WriteChunk(t, c):
    t.write(struct.pack(">I", len(c[1]) - 4))
    t.write(c[2])
    t.write(c[1])


def parseMHDR(c):
    assert c[2] == "MHDR"
    x, y, ticks = struct.unpack(">III", c[1][:4 * 3])
    return x, y, ticks


def WritePNGFrame(i):
    with open("%s%08i.png" % (fnt, i), "wb") as t:
        t.write(PNGSIG)
        for ii in xrange(FRAMES_PER_PNG):
            WriteChunk(t, chunks[i * FRAMES_PER_PNG + 1 + ii])


def TrimMNG(fn, frames): # skip i frames
    with open("trimmed-%s.mng" % fn, "wb") as t:
        t.write(MNGSIG)
        WriteChunk(t, chunks[0])
        for c in chunks[1 + frames * FRAMES_PER_PNG:]:
            WriteChunk(t, c)


def TrimWav(fn, frames, fps):
    s = wave.open("%s.wav" % fn, 'r')

    framerate = s.getframerate()
    skip = frames * framerate / fps

    total = s.getnframes()
    s.setpos(skip)
    d = s.readframes(total - skip)

    t = wave.open("trimmed-%s.wav" % fn, 'w')
    t.setparams(s.getparams())
    t.writeframes(d)

    t.close()
    s.close()


fn = sys.argv[1]
fnt = fn.replace(".mng", "")

chunks = ReadNG(fn)

x, y, ticks = parseMHDR(chunks[0]) # ticks will be not enough if FRAM chunks are used

print "MNG %i x %i, %i f/s" % (x, y, ticks),
print "(%i frames)" % ((len(chunks) - 2) / FRAMES_PER_PNG) # 1 MHDR + 1 MEND to be skipped

# dump PNG frames
#for i in xrange(DUMP_RANGE):
#    WritePNGFrame(DUMP_START + i)

#trim MNG and WAV
TrimMNG(fnt, SKIP)
TrimWav(fnt, SKIP, ticks)
