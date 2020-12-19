#!/usr/bin/env python3

#HexII - a compact binary representation (mixing Hex and ASCII)

# because ASCII dump is usually useless,
# unless there is an ASCII string,
# in which case the HEX part is useless

# Ange Albertini, BSD Licence 2014-2020


# v0.14:
# - Python 3
# - ASCII is using a threshold - too many FPs
# - Zero display is using a threshold - too many FPs
# - no more alpha character
# - Hex ruler at the bottom
# - dots interleave line is displayed after a skip
# - gap size displayed
# - fixed ruler with different line length
# - ANSI colors, themes
# - charsets
# - filename and hash
# - arguments parsing

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

# Todo
# - text output ?


import hashlib
import argparse
import sys
from string import punctuation, digits, ascii_letters

def Ansi(l):
    if isinstance(l, int):
        l = [l]
    s = "{esc}[{params}m".format(esc="\x1b", params=";".join("%i" % c for c in l))
    return s

class Ansi:
    Black    = Ansi(30)
    Red      = Ansi(31)
    Green    = Ansi(32)
    Yellow   = Ansi(33)
    Blue     = Ansi(34)
    Magenta  = Ansi(35)
    Cyan     = Ansi(36)
    White    = Ansi(37) # don't use unless you set background

    ResetFG  = Ansi(39)

    bBlack   = Ansi(90)
    bRed     = Ansi(91)
    bGreen   = Ansi(92)
    bYellow  = Ansi(93)
    bBlue    = Ansi(94)
    bMagenta = Ansi(95)
    bCyan    = Ansi(96)
    bWhite   = Ansi(97) # don't use unless you set background

    ResetBG  = Ansi(49)

class Theme:
    reset  = Ansi.ResetFG

    offset = ""
    alpha  = ""
    skip   = ""
    ruler  = ""
    end    = ""
    zero   = ""

class thDark(Theme):
    offset = Ansi.Yellow   # the offsets on the left before the hex
    alpha  = Ansi.bCyan    # ASCII and control characters \n ^Z/
    zero   = Ansi.bBlack   # 
    skip   = Ansi.bYellow  # the dots when skipping ranges of data
    ruler  = Ansi.Green    # the  0  1  2 ... ruler before and after the hex
    end    = Ansi.bRed     # the end marker ]]


class thAscii(Theme):
    reset  = ""

themes = {
    "dark": thDark,
    "ascii": thAscii
}


class charset:
    end = "]]"
    skip = "---"
    skOff = ">"
    digits = ["%X" % i for i in range(16)]
    numbers = ["%X" % i for i in range(32)]

class csAscii(charset):
    pass

chrs = lambda start, end: [chr(i) for i in range(start, end)]
fully_circled_digits = sum([
    ["\u24ea"], # 0
    chrs(0x2460, 0x2469), # 1-9
    chrs(0x2469, 0x246F), # 11-15
    # chrs(0x24b6, 0x24bb), # A-F
    # chrs(0x24d0, 0x24d5), # a-z
    ], [])

neg_circled_digits = sum([
    ["\u24ff"], # 0
    chrs(0x2776, 0x277f),   # 1-9
    chrs(0x1f150, 0x1f155), # A-F
    ], [])

neg_circled_sserif = sum([
    ["\U0001f10c"], # 0
    chrs(0x278A, 0x2792), # 1-9
    ], [])

class csUnicode(charset):
    skip = "\u2508" * 3
    # \u2219 Bullet Operator
    # \u2500 Box Drawings Light Horizontal
    # \u2508 Box Drawings Light Quadruple Dash Horizontal
    skOff = "\u254c"


charsets = {
    "ascii": csAscii,
    "unicode": csUnicode
}


parser = argparse.ArgumentParser(description="Sbud raw hex viewer.")
parser.add_argument('file',
    help="input file.")
parser.add_argument('-t', '--theme', default="Dark",
    help="display theme: %s." % ", ".join(themes))
parser.add_argument('-c', '--charset', default="Unicode",
    help="charset theme: %s." % ", ".join(themes))
parser.add_argument('-l', '--length', type=int, default=16,
    help="row length.")

args = parser.parse_args()
theme = args.theme.lower()
charset = args.charset.lower()

fn = args.file
with open(fn, "rb") as f:
    r = f.read()

LINELEN = args.length

ASCII = punctuation + digits + ascii_letters + " \n\r\x1a"
ASCII = ASCII.encode()

if theme not in themes:
    print("Error: unknown theme %s, aborting." % repr(theme))
    sys.exit()
theme = themes[theme]
if charset not in charsets:
    print("Error: unknown charset %s, aborting." % repr(charset))
    sys.exit()
charset = charsets[charset]

CHARS_NEEDED = len("%x" % len(r))

PREFIX = b"%%0%iX: " % CHARS_NEEDED

#this should always be displayed on the top of the screen no matter the scrolling
HeaderS = " " * CHARS_NEEDED + "  " + theme.ruler + " ".join(charset.numbers[i].rjust(2) for i in range(LINELEN)) + theme.reset

sha256 = hashlib.sha256(r).hexdigest()

print(theme.zero + "%s - %s..%s" % (repr(fn), sha256[:4], sha256[-4:])  + theme.reset)
print()
print(HeaderS)
print("")

# the first offset on top of a window should be completely displayed
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
                return theme.alpha + "__" + theme.reset
            if c == ord("\n"):
                return theme.alpha + "\\n" + theme.reset
            if c == ord("\r"):
                return theme.alpha + "\\r" + theme.reset
            if c == 0x1a: # TODO: only in manual mode
                return theme.alpha + "^Z" + theme.reset
            return theme.alpha + " " + chr(c) + theme.reset

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
    l = b" ".join(seq)

    if l.strip() != b"": #
        if skipping == True:
            gap_s = i * LINELEN - before_skip
            gap_str = " +%X" % gap_s
            gap_strl = len(gap_str)
            print(theme.skip
             + charset.skOff * (CHARS_NEEDED)
             + " "
             + charset.skip * (LINELEN)
             + gap_str
             + theme.reset
             )
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
        print("%s%s" % (theme.offset+prefix.decode("utf-8")+theme.reset, l.decode("utf-8")))
    else:
        if skipping == False:
            before_skip = i * LINELEN
            skipping = True
            last_off = None
print("")
print(HeaderS)
