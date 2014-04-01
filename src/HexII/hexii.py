#HexII - a compact binary representation (mixing Hex and ASCII)

# because ASCII dump is usually useless,
# unless there is an ASCII string,
# in which case the HEX part is useless

# Ange Albertini, BSD Licence 2014

# v0.13:
# Hex:
# - ASCII chars are replaced as .<char>
#   (optionally in colors)
# - 00 is replaced by "  "
# - FF is replaced by "##"
# - other chars are returned as hex
#
# Output:
# - a hex ruler is shown at the top of the 'display'
# - offsets don't contain superfluous 0
# - offsets are removed identical starting characters if following the previous
# - lines full of 00 are skipped
# - offsets after a skip are fully written
# - Last_Offset+1 is marked with "]"
#   (because EOF could be absent)

#todo:
# - update hexii2bin (since v0.12)
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

BLUE = '\033[94m'
ENDC = '\033[0m'
CHARS_NEEDED = int(math.log(len(r), 16) + 1)

PREFIX = "%%0%iX: " % CHARS_NEEDED

#this should always be displayed on the top of the screen no matter the scrolling
print " " * CHARS_NEEDED + "  " + " ".join("% 2X" % i for i in range(LINELEN))

#the first offset on top of a window should be completely displayed
last_off = None

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
#        return BLUE + "." + c + ENDC

    #otherwise, return hex
    return "%02X" % ord(c)

def csplit(s, n):
    for i in range(0, len(s), n):
        yield s[i:i+n]


l = []
for c in r:
    l += [subst(c)]

l += ["]"]
skipping = False

print

for i, seq in enumerate(csplit(l, LINELEN)):
    l = " ".join(seq)
    if l.strip() != "":
        skipping = False

        prefix = list(PREFIX % (i * LINELEN))

        #we'll skip starting chars if they are redundant
        if last_off is not None:
            save = last_off
            last_off = "".join(prefix)
            for i, j in enumerate(save):
                if prefix[i] == j:
                    prefix[i] = " "
                else:
                    break
        else:
            last_off = "".join(prefix)

        prefix = "".join(prefix)
        print "%s%s" % (prefix, l)
    else:
        if skipping == False:
            skipping = True
            last_off = None
