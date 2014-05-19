# dumb png chunks reader/writer

# Ange Albertini, BSD Licence, 2011-2014

import struct
import binascii

_MAGIC = "\x89PNG\x0d\x0a\x1a\x0a"

_crc32 = lambda d:(binascii.crc32(d) % 0x100000000)

def read(f):
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


def make(chunks):
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


if __name__ == "__main__":
    import sys

    fn = sys.argv[1]
    with open(fn, "rb") as f:
        c = read(f)

    # small 'fuzzer'
    import os, random, string
    rndtype = lambda : "".join([
        random.choice(string.lowercase)] + # required by GIMP
        random.sample(string.letters, 3))
    rnddata = lambda : os.urandom(random.randrange(1024 * 1024))

    assert c[1][0] == "IDAT"
    c[1][1] = c[1][1] + rnddata()

    assert c[-1][0] == "IEND"
    c[-1][1] = c[-1][1] + rnddata()

    c.insert( 1, [rndtype(), rnddata()])

    # firefox requires IHDR first
    #c.insert( 0, [rndtype(), rnddata()])

    c.insert(-1, [rndtype(), rnddata()])
    c.insert( 2, c[ 2]) # duplicate IDAT

    # firefox forbids data between IDATs
    #c.insert( 3, [rndtype(), rnddata()])

    c.insert(-1, c[-1]) # duplicate IEND
    c.insert(-1, [rndtype(), rnddata()])


    with open("test-" + fn, "wb") as f:
        f.write(make(c))
