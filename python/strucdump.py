#simple hex structure viewer
#TODO: classify!

# Ange Albertini, BSD Licence, 2011

import struct
import sys
fn = sys.argv[1]

last = -1
lastdata = []
lastrend = -1
INDENT = "\t"
COLS = 2

tags_types = [
 ('BOGUSTYPE', 50829),
 ]
 
TAGS = dict([(i[1], i[0]) for i in tags_types] + tags_types)
for i,j in TAGS.iteritems():
    TAGS[j] = i


def ph(start, end, cmt=None, skip=None, ccb=None):
    global r, last, lastrend, INDENT
    if end > len(r):
        end = len(r)
    if cmt is None:
        cmt = ""
    if ccb is not None:
        cmt = parseformat(r[start:end], ccb) + " " + cmt
    cmt = cmt.splitlines()
    rstart = (start / (16*COLS)) * (16*COLS)
    rend = (end / (16*COLS) * (16*COLS))  + (10 if (end % 0x10 > 0) else 0)
    heads = range(rstart, rend, (16*COLS))
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
        for i in range((16*COLS)):
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

def tag_cb(d):
    return "0x%02x (%s)" % (d, TAGS[d])

def small_hex(d):
    if 0 <= d < 10:
        return "%i" % d
    else:
        return "0x%X" % d

def types(d):
    return "%s (%s)" % (small_hex(d), {1:"Byte", 2:"Ascii", 3:"Short", 4:"Long", 5:"Rational"}[d])

def dec(d):
    return "%i" % d

STRUCTURE = [["H,Tag", tag_cb], ["H,Type", types], ["I,Count", small_hex], ["I,ValOffset", small_hex]]

def parseformat(d,f):
    s = []
    for f in f:
        type_, name = f[0].split(",")
        size = struct.calcsize(type_)
        val = struct.unpack(type_, d[:size])[0]
        d = d[size:]
        if len(f) == 1:
            s.append("%s:0x%x" % (name, val))
        else:
            s.append("%s:%s" % (name, f[1](val)))
    return ", ".join(s)
