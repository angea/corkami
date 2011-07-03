#IBM dos 1.1 files extraction script (would work for any fat16 floppy ?)

#http://thestarman.narod.ru/DOS/ibm100/Disk.htm


import struct
import sys

with open("PCDOS11.160", "rb") as f:
	r = f.read()

CLUSTER = 512

"""sectors:
0 : Boot record
1-2: Fat (2 copies of 1 sector)
3-6: Root directory
7-319: file area
"""

ROOT = r[3 * 512: 7 * 512]
entry = 0
ENTRY_LEN = 32
ENTRIES_MAX = len(ROOT) / ENTRY_LEN

while entry < ENTRIES_MAX:
	data = ROOT[entry * ENTRY_LEN:(entry + 1) * ENTRY_LEN]
	entry += 1
	if data[0] == "\xe5":
		continue
	data = struct.unpack("<8B3BB10BHHHL", data)
	name = "".join([chr(i) for i in data[:8]]).strip()
	data = data[8:]

	ext = "".join([chr(i) for i in data[:3]]).strip()
	data = data[3:]

	attributes = data[0]
	data = data[1:]

	reserved = data[:10]
	data = data[10:]

	time_, date_, first_block, size = data

	filename = "%s.%s" % (name, ext)
	
	print "%s size %i" % (filename, size)

	data_start = (first_block + 5) * CLUSTER
	with open(filename, "wb") as f:
		f.write(r[data_start: data_start + size])
