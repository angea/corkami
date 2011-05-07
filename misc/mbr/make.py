import sys
import os

import hashlib

SIG = ";ORIGINAL "
fn = sys.argv[1]
bin = fn
tmp = fn
bin = bin.replace(".asm", ".bin")
tmp = tmp.replace(".asm", ".tmp")
print fn, tmp, bin

with open(fn, "rt") as f:
	r = f.readlines()

w = list()
checksum = None
for s in r:
	if s.find(";CHECKSUM ") > -1:
		checksum = s[10:].strip()
	i = s.find(SIG)
	if i == -1:
		w.append(s)
		continue
	l = s[i + len(SIG):].strip().split(" ")
	l = ["0%sh" % c for c in l]
	w.append("db %s\r\n" %  (", ".join(l)))

with open(tmp, "wt") as f:
	f.write("".join(w))

if os.system("yasm %s -o %s" % (tmp, bin)) == 0:
	os.remove(tmp)

with open(bin, "rb") as f:
    md5 = hashlib.md5(f.read()).hexdigest()
if checksum is None:
	print "no checksum found"
elif md5 != checksum:
	print "invalid checksum"
