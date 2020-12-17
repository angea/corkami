#!/usr/bin/env python3

#HexII - a compact binary representation (mixing Hex and ASCII)

# because ASCII dump is usually useless,
# unless there is an ASCII string,
# in which case the HEX part is useless

# Ange Albertini, BSD Licence 2014-2020


# v0.14:
# - Python 3
# - ASCII is only turned on if more than 3 characters in a row are ASCII - Too many FPs
# - Zero display is only turned on if more than 3 characters in a row are zero - Too many FPs
# - Underscore is now used as a zero character
# - Hex ruler is displayed at the bottom too
# - dots interleave line is displayed after a skip
# - fixed ruler with different line length


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
from string import punctuation, digits, ascii_letters

with open(sys.argv[1], "rb") as f:
    r = f.read()

try:
    LINELEN = int(sys.argv[2])
except:
    LINELEN = 16

ASCII = punctuation + digits + ascii_letters + " \n\r\x1a"
ASCII = ASCII.encode()

BLUE = '\033[94m'
ENDC = '\033[0m'
CHARS_NEEDED = int(math.log(len(r), 16) + 1)

PREFIX = b"%%0%iX: " % CHARS_NEEDED

#this should always be displayed on the top of the screen no matter the scrolling
HeaderS = " " * CHARS_NEEDED + "  " + " ".join("%2X".rjust(2) % i for i in range(LINELEN))
print(HeaderS)
print("")

#the first offset on top of a window should be completely displayed
last_off = None

ZeroT = 4
AsciiT = 3

def subst(r, i):
    c = r[i]
    ma = 0 if i == 0 else i

    #replace 00 by empty char
    if c == 0:
        count = 1
        mi = max(i-ZeroT, 0)
        bef, aft = r[mi:ma][::-1], r[i+1:i+ZeroT]
        for ss in [bef, aft]:
            for cc in ss:
                if cc != 0:
                    break
                count += 1

        if count >= ZeroT:
            return b"  "

    if c in ASCII:
        count = 1
        mi = max(i-AsciiT, 0)
        bef, aft = r[mi:ma][::-1], r[i+1:i+AsciiT]
        for ss in [bef, aft]:
            for cc in ss:
                if not cc in ASCII:
                    break
                count += 1

        if count >= AsciiT:
            if c == ord(" "):
                return b"__"
            if c == ord("\n"):
                return b"\\n"
            if c == ord("\r"):
                return b"\\r"
            if c == 0x1a:
                return b"^Z"
            return b"_" + bytes([c])

#        return BLUE + "." + c + ENDC

    #otherwise, return hex
    return b"%02X" % c

def csplit(s, n):
    for i in range(0, len(s), n):
        yield s[i:i+n]


l = []
for i in range(len(r)):
    l += [subst(r, i)]

l += [b"]]"]
skipping = False
previous = None

for i, seq in enumerate(csplit(l, LINELEN)):
    l = b" ".join(seq)
    if l.strip() != b"":
        if skipping == True:
            print("." * CHARS_NEEDED)
        skipping = False

        prefix = list(PREFIX % (i * LINELEN))

        #we'll skip starting chars if they are redundant
        if last_off is not None:
            save = last_off
            last_off = bytes(prefix)
            for i, j in enumerate(save):
                if prefix[i] == j:
                    prefix[i] = ord(" ")
                else:
                    break
        else:
            last_off = bytes(prefix)

        prefix = bytes(prefix)
        print("%s%s" % (prefix.decode("ascii"), l.decode("ascii")))
    else:
        if skipping == False:
            skipping = True
            last_off = None
print("")
print(HeaderS)
