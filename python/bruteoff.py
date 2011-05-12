#simple offset start 'bruteforcer'
#todo: add inline aplib ?

import sys
import os

import zlib

fn = sys.argv[1]
with open(fn, "rb") as f:
	r = f.read()

for i in xrange(1,32):
	print "trying from offset %i" % i

	zlibed = ""
	try:
		zlibed = zlib.decompress(r[i:])
	except zlib.error:
		pass
	if zlibed:
		print "zlib successfull, offset %i" % i
	fn2 = "%s%02i.trunc" % (fn, i)

	with open(fn2, "wb") as f2:
		f2.write(r[i:])
	result = os.popen("lzma.exe d %s test-lzma.%02i.t" % (fn2, i), "r").read() 
	print result
#	os.remove(fn2)