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
# - Ansi style optimisation
# - style propagation over nibbles
# - compact mode via alternating backgrounds

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
# - clean compact mode: argument, theme, ascii
# - ASCII coloring bugged (cf WAD)
# - alpha coloring lost with compact mode (cf WAD)


import hashlib
import argparse
import sys
from string import punctuation, digits, ascii_letters

def ansi(l):
    if l == []:
        return ""
    if isinstance(l, int):
        l = [l]
    s = "{esc}[{params}m".format(esc="\x1b", params=";".join("%i" % c for c in l))
    return s

def sameColor(fg, bg):
    if bg - fg == 10:
        if 30 <= fg <= 37 or 90 <= fg <= 97:
            return True
    return False

def switchInt(color):
    if 30 <= color <= 47:
        return color + 60
    if 90 <= color <= 107:
        return color - 60
    return color

class Ansi:
    Black    = ansi(30)
    Red      = ansi(31)
    Green    = ansi(32)
    Yellow   = ansi(33)
    Blue     = ansi(34)
    Magenta  = ansi(35)
    Cyan     = ansi(36)
    White    = ansi(37) # don't use unless you set background

    ResetFG  = ansi(39)

    bBlack   = ansi(90)
    bRed     = ansi(91)
    bGreen   = ansi(92)
    bYellow  = ansi(93)
    bBlue    = ansi(94)
    bMagenta = ansi(95)
    bCyan    = ansi(96)
    bWhite   = ansi(97) # don't use unless you set background

    ResetBG    = ansi(49)

    BlackBG    = ansi(40)
    RedBG      = ansi(41)
    GreenBG    = ansi(42)
    YellowBG   = ansi(43)
    BlueBG     = ansi(44)
    MagentaBG  = ansi(45)
    CyanBG     = ansi(46)
    WhiteBG    = ansi(47)
    bBlackBG   = ansi(100)
    bRedBG     = ansi(101)
    bGreenBG   = ansi(102)
    bYellowBG  = ansi(103)
    bBlueBG    = ansi(104)
    bMagentaBG = ansi(105)
    bCyanBG    = ansi(106)
    bWhiteBG   = ansi(107)


def getStyles(b):
    """gets raw string, FGs and BGs styles from an ANSI string"""
    fgs = {0:39}
    bgs = {0:49}
    raw = b""
    i = 0
    while i < len(b):
        c = b[i]
        if c == 0x1b:
            idx = b.find(b"m", i)
            styles_s = b[i + 2:idx]
            styles = [int(_) for _ in styles_s.split(b";")]
            pos = len(raw)
            for s in styles:
                if s == 39:
                    fgs[pos] = s
                elif s == 49:
                    bgs[pos] = s
                elif 30 <= s <= 37 or 90 <= s <= 97:
                    fgs[pos] = s
                elif 40 <= s <= 47 or 100 <= s <= 107:
                    bgs[pos] = s
            # \x1b + [ + styles + m
            i += 2 + len(styles_s) + 1
            continue
        else:
            raw += bytes([c])
            i += 1
    return raw, fgs, bgs


def makeAnsi(raw, fgs, bgs, reset=True):
    """generate an ANSI string from raw text and sets of FG and BG styles"""
    fg = 39
    bg = 49
    s = b""
    for i, c in enumerate(raw):
        styles = []
        if i in fgs:
            new_fg = fgs[i]
            if new_fg != fg:
                styles += [new_fg]
                fg = new_fg
        if i in bgs:
            new_bg = bgs[i]
            if new_bg != bg:
                styles += [new_bg]
                bg = new_bg
        for style in styles: # some viewers don't support combined settings
            s += ansi(style).encode("utf-8")
        s += bytes([c])

    # resetting styles if needed
    if reset:
        style = []
        if fg != 39:
            styles += [39]
        if bg != 49:
            styles += [49]
        for style in styles: # some viewers don't support combined settings
            s += ansi(style).encode("utf-8")

    return s


def propStyles(b):
    # propagate styles from one nibble to the next if identical
    raw, fgs, bgs = getStyles(b)

    for i,c in enumerate(raw):
        if c == 32 and i in fgs and i+1 in fgs:
            del(fgs[i])
        if c == 32 and i in bgs and i+1 in bgs:
            del(bgs[i])

    result = makeAnsi(raw, fgs, bgs)
    return result


def setAltBgs(b, bgs):
    global COMPACT
    if not COMPACT:
        return b
    bIsStr = False
    if isinstance(b, str):
        bIsStr = True
        b = b.encode("utf-8")
    bg1, bg2 = bgs
    raw, fgs, bgs = getStyles(b)
    bg = 49
    fg = 39
    #print(bgs)
    for i in range(len(raw)):
        if i in bgs:
            bg = bgs[i]
        if i in fgs:
            fg = fgs[i]
        if bg != 49:
            continue
        if i % 4 == 0:
            if sameColor(fg, bg1):
                fgs[i] = switchInt(bg1 - 10)
                fgs[i+2] = fg
            bgs[i] = bg1
        elif i % 4 == 2:
            if sameColor(fg, bg2):
                fgs[i] = switchInt(bg2 - 10)
                fgs[i+2] = fg
            bgs[i] = bg2
    result = makeAnsi(raw, fgs, bgs)
    if bIsStr:
        result = result.decode("utf-8")

    return result


class Theme:
    reset  = Ansi.ResetFG + Ansi.ResetBG

    offset = ""
    alpha  = ["", ""]
    skip   = ""
    ruler  = ""
    end    = ""
    zero   = ""


class thDark(Theme):
    offset = Ansi.Yellow   # the offsets on the left before the hex
    # ASCII and control characters \n ^Z/
    alpha  = [
        Ansi.Cyan + Ansi.BlueBG,
        Ansi.bCyan + Ansi.bBlueBG,
    ]
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
    skip = "-"
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
    skip = "\u2508"
    # \u2219 Bullet Operator
    # \u2500 Box Drawings Light Horizontal
    # \u2508 Box Drawings Light Quadruple Dash Horizontal
    skOff = "\u254c"


charsets = {
    "ascii": csAscii,
    "unicode": csUnicode
}

bAlpha = 0
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

COMPACT = False

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

PREFIX = b"%%0%iX " % CHARS_NEEDED

#this should always be displayed on the top of the screen no matter the scrolling
skip_l = 3 if not COMPACT else 2
joiner = " " if not COMPACT else ""
numbers = joiner.join(charset.numbers[i].rjust(2) for i in range(LINELEN))
#print (numbers)
HeaderS = " " * CHARS_NEEDED + " " + ansi(92) + setAltBgs(numbers, [49, 42]) + theme.reset

sha256 = hashlib.sha256(r).hexdigest()

print(theme.zero + "%s - %s..%s" % (repr(fn), sha256[:4], sha256[-4:])  + theme.reset)
print()
print(HeaderS)
print("")

# the first offset on top of a window should be completely displayed
last_off = None

ZeroT = 5
AsciiT = 3


def subst(r, i):
    global bAlpha
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
            bAlpha = 1 - bAlpha
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
                return theme.alpha[bAlpha] + "__" + theme.reset
            if c == ord("\n"):
                return theme.alpha[bAlpha] + "\\n" + theme.reset
            if c == ord("\r"):
                return theme.alpha[bAlpha] + "\\r" + theme.reset
            if c == 0x1a: # TODO: only in manual mode
                return theme.alpha[bAlpha] + "^Z" + theme.reset
            return theme.alpha[bAlpha] + " " + chr(c) + theme.reset
    bAlpha = 1 - bAlpha
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
    l = b" ".join(seq) if not COMPACT else b"".join(seq)

    if l.strip() != b"": #
        if skipping == True:
            gap_s = i * LINELEN - before_skip
            gap_str = " +%X" % gap_s
            gap_strl = len(gap_str)
            print(theme.skip
             + charset.skOff * (CHARS_NEEDED)
             + " "
             + charset.skip * (LINELEN) * skip_l
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
        l = propStyles(l)
        l = setAltBgs(l, [49, 100])
        print("%s%s" % (theme.offset+prefix.decode("utf-8")+theme.reset, l.decode("utf-8")))
    else:
        if skipping == False:
            before_skip = i * LINELEN
            skipping = True
            last_off = None
print("")
print(HeaderS)
