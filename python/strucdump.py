#simple hex structure viewer
#TODO: classify!

# Ange Albertini, BSD Licence, 2011

import struct
import sys
fn = sys.argv[1]

last = 0
lastdata = []
lastrend = 0
INDENT = None

def ph(start, end, cmt=None, skip=None):
	global r, last, lastrend, INDENT
	if end > len(r):
		end = len(r)
	if cmt is None:
		cmt = ""
	cmt = cmt.splitlines()
	rstart = (start / 16) * 16
	rend = (end / 16 * 16)  + (10 if (end % 0x10 > 0) else 0)
	heads = range(rstart, rend, 16)
	if skip is None:
		skip = len(heads)
	elif skip == -1:
		skip = 1
	non_skipped = True
	for line, head in enumerate(heads):
		if line > skip and line < len(heads) - skip:
			if non_skipped:
				
				print INDENT + "[..]"
				non_skipped = False
			continue
		if head==lastrend and line == 0: 
			print INDENT + "    ",
		else:
			print INDENT + "%03x:" % head, 
		for i in range(16):
			if (head + i < start) or (head + i > end - 1):
				print "  ",
			else:
				print "%02x" % ord(r[head + i]),
		print("// " + cmt[line] if line < len(cmt) else "")
	last = end
	lastdata = r[start:end]
	lastrend = heads[-1]


fcuts = []

with open(fn, "rb") as f:
	r = f.read()


INDENT = "\t\t\t"
