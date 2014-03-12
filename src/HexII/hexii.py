#HexII - a compact binary representation (mixing Hex and ASCII)

# because ASCII dump is usually useless,
# unless there is an ASCII string,
# in which case the HEX part is useless

# Ange Albertini, BSD Licence 2014

# v0.11:
# Hex:
# - ASCII chars are replaced as .<char>
# - 00 is replaced by "  "
# - FF is replaced by "##"
# - other chars are returned as hex
#
# Output:
# - lines are ended with a |
#   (except last line if it's shorter)
# - lines full of 00 are skipped
# - offsets don't contain superfluous 0
# - Last_Offset+1 is marked with "]"
#   (because EOF could be absent)

#todo:
# - less brutal empty line skipping ?
# - something about unicode ?


import sys
import math
from string import punctuation, digits, letters

with open(sys.argv[1], "rb") as f:
    r = f.read()

try:
    LINELEN = int(sys.argv[2])
except:
    LINELEN = 16

ASCII = punctuation + digits + letters

PREFIX = "%%0%iX: " % (math.log(len(r), 16) + 1)

def subst(c):
    #replace 00 by empty char
    if c == "\0":
        return "  "

    #replace 00 by empty char
    if c == "\xFF":
        return "##"

    #replace printable char by .<char>
    if c in ASCII:
        return "." + c

    #otherwise, return hex
    return "%02X" % ord(c)

def csplit(s, n):
    for i in range(0, len(s), n):
        yield s[i:i+n]


l = []
for c in r:
    l += [subst(c)]

l += ["]"]

for i, seq in enumerate(csplit(l, LINELEN)):
    l = " ".join(seq)
    if l.strip() != "":
        if (len(seq) == LINELEN):
            l += "|"
        print (PREFIX + "%s") % (i * LINELEN, l)