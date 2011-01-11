# takes 2 files, extract bytes via getdata,
# blanks out different bytes of both byte sequences
# then generate a C test

CONSEC_LIMIT = 9 # use negative or null for no limit
ZERO_LIMIT = 16 # also counts 00 or FF (UGLY counter)

import sys

f1 = sys.argv[1]
f2 = sys.argv[2]

from utils import getEPdata, getwildstring, seq_to_snippets, templatize

d1 = getEPdata(f1, 100)
d2 = getEPdata(f2, 100)
seq = []
for i,j in enumerate(d1):
	seq.append("%02X" % ord(j) if d2[i] == j else None)

a1 = []
a2 = []
consec = 0
zero = 0
limit = 0
for i,j in enumerate(seq):
    if j is not None:
        consec = 0
        if j in ["00", "FF"]: # not algorithmically correct
            zero += 1
        else:
            zero = 0
        a1.append(j)
        a2.append(j)
        if ZERO_LIMIT > 0 and zero == ZERO_LIMIT:
            limit = i + 1 - ZERO_LIMIT
            break
    else:
        a1.append("00")
        a2.append("7f")

        # let's stop automatically if more than CONSEC_LIMIT consecutive bytes are differents
        consec += 1
        if CONSEC_LIMIT > 0 and consec > CONSEC_LIMIT:
            limit = i + 1 - ZERO_LIMIT
            break

seq = seq[:limit + 1]
a1 = a1[:limit + 1]
a2 = a2[:limit + 1]

print "// automated comparison and test-generation of :"
print "// file %s\n// %s" % (f1, " ".join(["%02X" % ord(i) for i in d1[:limit]]))
print "// file %s\n// %s" % (f2, " ".join(["%02X" % ord(i) for i in d2[:limit]]))
print

from utils import get_disassembly

a1 = get_disassembly("".join(chr(int(i, 16)) for i in a1))
a2 = get_disassembly("".join(chr(int(i, 16)) for i in a2))

hlen = max(len(i[0]) for i in a1) + 1
a1 = ["// %s:%s" % (i[0].ljust(hlen), i[1]) for i in a1]
a2 = ["// %s:%s" % (i[0].ljust(hlen), i[1]) for i in a2]

if len(a1) == len(a2):
    for i,j in enumerate(a1):
        print getwildstring(j, a2[i])
else:
    print "different length"

print templatize(seq_to_snippets(seq))