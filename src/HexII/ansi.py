def marker(l):
    if l == []:
        return ""
    if isinstance(l, int):
        l = [l]
    s = "{esc}[{params}m".format(esc="\x1b", params=";".join("%i" % c for c in l))
    return s


class Colors:
    Black    = 30
    Red      = 31
    Green    = 32
    Yellow   = 33
    Blue     = 34
    Magenta  = 35
    Cyan     = 36
    White    = 37 # don't use unless you set background

    ResetFG  = 39

    bBlack   = 90
    bRed     = 91
    bGreen   = 92
    bYellow  = 93
    bBlue    = 94
    bMagenta = 95
    bCyan    = 96
    bWhite   = 97 # don't use unless you set background

    ResetBG    = 49

    BlackBG    = 40
    RedBG      = 41
    GreenBG    = 42
    YellowBG   = 43
    BlueBG     = 44
    MagentaBG  = 45
    CyanBG     = 46
    WhiteBG    = 47
    
    bBlackBG   = 100
    bRedBG     = 101
    bGreenBG   = 102
    bYellowBG  = 103
    bBlueBG    = 104
    bMagentaBG = 105
    bCyanBG    = 106
    bWhiteBG   = 107


class Markers:
    Black    = marker(30)
    Red      = marker(31)
    Green    = marker(32)
    Yellow   = marker(33)
    Blue     = marker(34)
    Magenta  = marker(35)
    Cyan     = marker(36)
    White    = marker(37) # don't use unless you set background

    ResetFG  = marker(39)

    bBlack   = marker(90)
    bRed     = marker(91)
    bGreen   = marker(92)
    bYellow  = marker(93)
    bBlue    = marker(94)
    bMagenta = marker(95)
    bCyan    = marker(96)
    bWhite   = marker(97) # don't use unless you set background

    ResetBG    = marker(49)

    BlackBG    = marker(40)
    RedBG      = marker(41)
    GreenBG    = marker(42)
    YellowBG   = marker(43)
    BlueBG     = marker(44)
    MagentaBG  = marker(45)
    CyanBG     = marker(46)
    WhiteBG    = marker(47)
    bBlackBG   = marker(100)
    bRedBG     = marker(101)
    bGreenBG   = marker(102)
    bYellowBG  = marker(103)
    bBlueBG    = marker(104)
    bMagentaBG = marker(105)
    bCyanBG    = marker(106)
    bWhiteBG   = marker(107)


def sameColor(fg, bg):
    if bg - fg == Colors.BlackBG - Colors.Black:
        if Colors.Black <= fg <= Colors.White or \
        Colors.bBlack <= fg <= Colors.bWhite:
            return True
    return False


def switchInt(color):
	intensify = Colors.bBlack - Colors.Black
	if Colors.Black <= color <= Colors.WhiteBG:
	    return color + intensify
	if Colors.bBlack <= color <= Colors.bWhiteBG:
	    return color - intensify
	return color


def isFG(color):
    if color == Colors.ResetFG or \
        Colors.Black <= color <= Colors.White or \
        Colors.bBlack <= color <= Colors.bWhite:
        return True
    return False


def isBG(color):
    if color == Colors.ResetBG or \
        Colors.BlackBG <= color <= Colors.WhiteBG or \
        Colors.bBlackBG <= color <= Colors.bWhiteBG:
        return True
    return False


def getStyles(b):
    """gets raw string, FGs and BGs styles from an ANSI string"""
    fgs = {0:Colors.ResetFG}
    fg = Colors.ResetFG
    bgs = {0:Colors.ResetBG}
    bg = Colors.ResetBG
    raw = b""
    i = 0
    while i < len(b):
        c = b[i]
        pos = len(raw)
        if c == 0x1b:
            idx = b.find(b"m", i)
            styles_s = b[i + 2:idx]
            styles = [int(_) for _ in styles_s.split(b";")]
            for s in styles:
                if isFG(s):
                    fgs[pos] = s
                    fg = s
                if isBG(s):
                    bgs[pos] = s
                    bg = s
            # '\x1b' + '['' + styles + 'm'
            i += 2 + len(styles_s) + 1

            continue
        else:
            # style propagation - causing bugs :(
            #if pos not in fgs:
            #    fgs[pos] = fg
            #if pos not in bgs:
            #    bgs[pos] = bg
            raw += bytes([c])
            i += 1
    return raw, fgs, bgs


def generate(raw, fgs, bgs, reset=True):
    """generate an ANSI string from raw text and sets of FG and BG styles"""
    fg = Colors.ResetFG
    bg = Colors.ResetBG
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
            s += marker(style).encode("utf-8")
        s += bytes([c])

    # resetting styles if needed
    if reset:
        style = []
        if fg != Colors.ResetFG:
            styles += [Colors.ResetFG]
        if bg != Colors.ResetBG:
            styles += [Colors.ResetBG]
        for style in styles: # some viewers don't support combined settings
            s += marker(style).encode("utf-8")

    return s
