#!/usr/bin/env python3

# Sbud raw hex viewer

# Originally from HexII:
#  because ASCII dump is usually useless,
#  unless there is an ASCII string,
#  in which case the HEX part is useless.

# Ange Albertini, BSD Licence 2014-2020


import hashlib
import argparse
import sys
from string import punctuation, digits, ascii_letters
import ansi
import themes
import charsets


def propStyles(b):
    # propagate styles from one nibble to the next if identical
    raw, fgs, bgs = ansi.getStyles(b)

    for i,c in enumerate(raw):
        if c == ord(" ") and i in fgs and i+1 in fgs:
            del(fgs[i])
        if c == ord(" ") and i in bgs and i+1 in bgs:
            del(bgs[i])

    result = ansi.generate(raw, fgs, bgs)
    return result


def setAltBgs(b, bg2):
    """alternate backgrounds for each nibble"""
    global bCompact
    if not bCompact:
        return b

    bIsStr = False
    if isinstance(b, str):
        bIsStr = True
        b = b.encode("utf-8")
    raw, fgs, bgs = ansi.getStyles(b)
    bg = ansi.Colors.ResetBG
    fg = ansi.Colors.ResetFG
    for i in range(len(raw)):
        if i in bgs:
            bg = bgs[i]
        if i in fgs:
            fg = fgs[i]
        if bg != ansi.Colors.ResetBG:
            continue
        if i % 4 == 0:
            bgs[i] = ansi.Colors.ResetBG
        elif i % 4 == 2:

            # no need of alternate bg if we're showing an empty space
            if raw[i:i+2] == b"  ":
                continue

            # no need of alternate bg if we're surrounded by empty space
            # TODO: detect BGs in surround
            emptyBef = False
            if i < 2:
                emptyBef = True
            elif raw[i-2:i] == b"  ":
                emptyBef = True

            emptyAft = False
            if i >= len(raw) - 2:
                emptyAft = True
            elif raw[i+2:i+4] == b"  ":
                emptyAft = True

            if emptyAft and emptyBef:
                continue


            if ansi.sameColor(fg, bg2):
                fgs[i] = ansi.switchInt(bg2 - 10)
                if i+2 not in fgs:
                    fgs[i+2] = fg

            bgs[i] = bg2
    result = ansi.generate(raw, fgs, bgs)
    if bIsStr:
        result = result.decode("utf-8")

    return result


bAlpha = 0
parser = argparse.ArgumentParser(description="Sbud raw hex viewer.")
parser.add_argument('file',
    help="input file(s).")
parser.add_argument('-t', '--theme', default="Dark",
    help="color theme: %s." % ", ".join(sorted(themes.themes)))
parser.add_argument('-c', '--charset', default="Unicode",
    help="charset: %s." % ", ".join(sorted(charsets.charsets)))
parser.add_argument('-o', '--out', default=None,
    help="output to a file.")

parser.add_argument('--compact', action="store_true",
    help="compact view mode.")

parser.add_argument('--row_length', type=int, default=16,
    help="row length.")
parser.add_argument('--zero_count', default=3, type=int,
    help="how many zeros bytes in a row.")
parser.add_argument('--ascii_count', default=3, type=int,
    help="how many Ascii bytes in a row.")

args = parser.parse_args()
theme = args.theme.lower()
charset = args.charset.lower()
bCompact = args.compact
ZeroT = args.zero_count
AsciiT = args.ascii_count
LINELEN = args.row_length
out = args.out


fn = args.file
with open(fn, "rb") as f:
    r = f.read()


ASCII = punctuation + digits + ascii_letters + " \n\r\x1a"
ASCII = ASCII.encode()

if theme not in themes.themes:
    print("Error: unknown theme %s, aborting." % repr(theme))
    sys.exit()
theme = themes.themes[theme]
if charset not in charsets.charsets:
    print("Error: unknown charset %s, aborting." % repr(charset))
    sys.exit()
charset = charsets.charsets[charset]

CHARS_NEEDED = len("%x" % len(r))

PREFIX = b"%%0%iX " % CHARS_NEEDED

#this should always be displayed on the top of the screen no matter the scrolling
skip_l = 3 if not bCompact else 2
joiner = " " if not bCompact else ""

numbers = joiner.join(charset.numbers[i].rjust(2) for i in range(LINELEN))
#print (numbers)
HeaderS = " " * CHARS_NEEDED + " " + ansi.marker(92) + setAltBgs(numbers, 42) + theme.reset

sha256 = hashlib.sha256(r).hexdigest()

output = []
output += [theme.zero + "%s - %s..%s" % (repr(fn), sha256[:4], sha256[-4:])  + theme.reset]
output += ["", HeaderS, ""]

# the first offset on top of a window should be completely displayed
last_off = None

isAlpha = None


def leaveAlpha():
    global bAlpha, isAlpha
    if isAlpha == True:
        bAlpha = 1 - bAlpha
    isAlpha = False


def subst(r, i):
    global bAlpha, isAlpha
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
            leaveAlpha()
            return "  "

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
                isAlpha = True
                return theme.alpha[bAlpha] + "__" + theme.reset
            if c == ord("\n"):
                isAlpha = True
                return theme.alpha[bAlpha] + "\\n" + theme.reset
            if c == ord("\r"):
                isAlpha = True
                return theme.alpha[bAlpha] + "\\r" + theme.reset
            if c == 0x1a: # TODO: only in manual mode
                isAlpha = True
                return theme.alpha[bAlpha] + "^Z" + theme.reset

            isAlpha = True
            return theme.alpha[bAlpha] + " " + chr(c) + theme.reset
    leaveAlpha()

    if c == 0:
        return theme.zero + "00" + theme.reset
    #otherwise, return hex
    return "%02X" % c


def csplit(s, n):
    for i in range(0, len(s), n):
        yield s[i:i+n]


l = []
for i in range(len(r)):
    l += [subst(r, i).encode("utf-8")]

l += [(theme.end + charset.end + theme.reset).encode("utf-8")]

skipping = False
before_skip = 0
for i, seq in enumerate(csplit(l, LINELEN)):
    l = b" ".join(seq) if not bCompact else b"".join(seq)

    if l.strip() != b"": #
        if skipping == True:
            gap_s = i * LINELEN - before_skip
            gap_str = " +%X" % gap_s
            gap_strl = len(gap_str)
            output += [theme.skip
             + charset.skOff * (CHARS_NEEDED)
             + " "
             + charset.skip * (LINELEN) * skip_l
             + gap_str
             + theme.reset
             ]
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
        l = propStyles(l)
        l = setAltBgs(l, 100)
        output += ["%s%s" % (theme.offset+prefix.decode("utf-8")+theme.reset, l.decode("utf-8"))]
    else:
        if skipping == False:
            before_skip = i * LINELEN
            skipping = True
            last_off = None

output += ["", HeaderS, ""]

if out is None:
    for line in output:
        print(line)
else:
    with open(out, "w", encoding="utf8") as f:
        output = "\n".join(output)
        f.write(output)
