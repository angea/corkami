#IBM dos 1.1 extraction script
#(cf http://thestarman.pcministry.com/tool/hxd/dimtut.htm)

import hashlib

with open("TK-DOS11.DIM", "rb") as f:
	r = f.read()

r = r[84:]
r = r.replace("\xB0\xA3\xAA\x4C\xF5\x1A\x1E\xC5", "")


assert 0x28000 == len(r)
assert "47bfb4371d28cd9e45fb1197f2a70c00" == hashlib.md5(r).hexdigest()

print "ok"

with open("PCDOS11.160", "wb") as f:
	f.write(r)