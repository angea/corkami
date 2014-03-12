#converts a HexII output back to a file

#Ange Albertini, BSD Licence 2014

from sys import argv

hexii, bin = argv[1:3]

def _3g(s):
    """splits a string in trigrams"""
    for i in range(0, len(s), 3):
        yield s[i:i+2] # we don't need the space separator


def convert_char(c):
    """converts  HexII characters to HEX"""
    if c.startswith("."):
        return "%02X" % ord(c[1:])
    if c == "  ":
        return "00"
    if c == "##":
        return "FF"
    return c


with open(hexii, "rb") as f:
    r = f.readlines()

cur_off = 0
d = []
for l in r:
    offset, _, content = l.strip().partition(":")
    offset = int(offset, 16)

    # add skipped line(s)
    if cur_off != offset:
        d += ["00" ] * (offset - cur_off)
        cur_off = offset

    content = content[1:] # there is a space after the offset ':'

    # "|" is just a delimiter
    if content.endswith("|"):
        content = content[:-1]
    for c in _3g(content):
        cur_off += 1
        d += [convert_char(c)]

d = d[:-1] # remove the "]" char

# writes the file
with open(bin, "wb") as f:
    f.write("".join(chr(int(c, 16)) for c in d)) # at this stage, we have a HEX representation