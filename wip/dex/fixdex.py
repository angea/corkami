# fixes DEX sha1 and adler32

import sys
import zlib
import hashlib
import struct

fn = sys.argv[1]
with open(fn, "rb") as s:
    d = s.read()

if not d.startswith("dex\n035"):
    sys.exit()

d = d[:8 + 4] + \
    hashlib.sha1(d[8 + 4 + 20:]).digest() + \
    d[8 + 4 + 20:]

d = d[:8] + \
    struct.pack("<i", zlib.adler32(d[8 + 4:])) + \
    d[8 + 4:]

with open(fn + "x", "wb") as t:
    t.write(d)
