import struct
import sys

OFFSET = 0x1006
LENGTH = 48

def xor(data, key=0xcafebabe):
    crypted = list()
    for j in xrange(LENGTH / 4):
        s = data[j * 4:(j + 1) * 4]
        i = struct.unpack("<L", "".join(s))[0]
        crypted.append(i ^ key)
    return struct.pack("L" * (LENGTH / 4), *crypted)


def prng(data, seed=0xcafebabe):
    acc = seed
    crypted = list()
    for char in data:
        i = struct.unpack("<B", char)[0]
        acc = (((acc * 0x343fd) + 0x269ec3) >> 0x10) & 0x7fff
        crypted.append(i ^ (acc & 0xff))
    return struct.pack("B" * LENGTH, *crypted)


def rc4(data, key="Key"):
    x = 0
    box = range(256)
    for i in xrange(256):
        x = (x + box[i] + ord(key[i % len(key)])) % 256
        box[i], box[x] = box[x], box[i]
    x,y = 0, 0
    out = list()
    for char in data:
        x = (x + 1) % 256
        y = (y + box[x]) % 256
        box[x], box[y] = box[y], box[x]
        out.append(chr(ord(char) ^ box[(box[x] + box[y]) % 256]))
    return ''.join(out)


fn = sys.argv[1]
fu = {"xor.exe":xor, "prng.exe":prng, "rc4.exe":rc4}[fn]

# buf should be the same, but in case...
with open(fn, "rb") as f:
    buf = list(f.read())

if buf[OFFSET:OFFSET + 2] != ["\x6a","\x40"]:
    print "Error - already crypted"
    sys.exit()
crypted = fu(buf[OFFSET: OFFSET + LENGTH])
buf[OFFSET: OFFSET + LENGTH] = crypted

with open(fn, "wb") as f:
    f.write("".join(buf))
