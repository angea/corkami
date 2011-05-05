# simple ascii to hex convertor
import sys

default =  "909090C3"

try:
	s = sys.argv[1]
except:
	s = default
b = list()
for i in xrange(len(s) /2):
	c = s[i * 2: i * 2 + 2]
	b.append(chr(int(c,16)))
with open("decrypted", "wb") as f:
	f.write("".join(b))
