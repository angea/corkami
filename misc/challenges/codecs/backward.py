# backward codec

import sys
fn = sys.argv[1]
f = open(fn, "rb")
r = f.read()
f.close()

w = open(fn + ".back", "wb")

for c in r[::-1]:
	w.write(c)
w.close()
