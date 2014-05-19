#appends data at PNG format level

import sys, png, os

fn = sys.argv[1]

with open(fn, "rb") as f:
	chunks = png.read(f)

for chunk in chunks:
	if chunk[0] == "IDAT":
		chunk[1] += os.urandom(1024 * 1024)

with open("app_%s" % fn, "wb") as f:
	f.write(png.make(chunks))
