def marker(l):
    if l == []:
        return ""
    if isinstance(l, int):
        l = [l]
    s = "{esc}[{params}m".format(esc="\x1b", params=";".join("%i" % c for c in l))
    return s


class Ansi:
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


def generate(raw, fgs, bgs, reset=True):
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
            s += marker(style).encode("utf-8")
        s += bytes([c])

    # resetting styles if needed
    if reset:
        style = []
        if fg != 39:
            styles += [39]
        if bg != 49:
            styles += [49]
        for style in styles: # some viewers don't support combined settings
            s += marker(style).encode("utf-8")

    return s
