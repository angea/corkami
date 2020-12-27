#!/usr/bin/env python3

ESC = 0x1b

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

    ResetFg  = 39

    bBlack   = 90
    bRed     = 91
    bGreen   = 92
    bYellow  = 93
    bBlue    = 94
    bMagenta = 95
    bCyan    = 96
    bWhite   = 97 # don't use unless you set background

    ResetBg    = 49

    BlackBg    = 40
    RedBg      = 41
    GreenBg    = 42
    YellowBg   = 43
    BlueBg     = 44
    MagentaBg  = 45
    CyanBg     = 46
    WhiteBg    = 47
    
    bBlackBg   = 100
    bRedBg     = 101
    bGreenBg   = 102
    bYellowBg  = 103
    bBlueBg    = 104
    bMagentaBg = 105
    bCyanBg    = 106
    bWhiteBg   = 107


class Markers:
    Black    = marker(30)
    Red      = marker(31)
    Green    = marker(32)
    Yellow   = marker(33)
    Blue     = marker(34)
    Magenta  = marker(35)
    Cyan     = marker(36)
    White    = marker(37) # don't use unless you set background

    ResetFg  = marker(39)

    bBlack   = marker(90)
    bRed     = marker(91)
    bGreen   = marker(92)
    bYellow  = marker(93)
    bBlue    = marker(94)
    bMagenta = marker(95)
    bCyan    = marker(96)
    bWhite   = marker(97) # don't use unless you set background

    ResetBg    = marker(49)

    BlackBg    = marker(40)
    RedBg      = marker(41)
    GreenBg    = marker(42)
    YellowBg   = marker(43)
    BlueBg     = marker(44)
    MagentaBg  = marker(45)
    CyanBg     = marker(46)
    WhiteBg    = marker(47)
    bBlackBg   = marker(100)
    bRedBg     = marker(101)
    bGreenBg   = marker(102)
    bYellowBg  = marker(103)
    bBlueBg    = marker(104)
    bMagentaBg = marker(105)
    bCyanBg    = marker(106)
    bWhiteBg   = marker(107)


def sameColor(fg, bg):
    if bg - fg == Colors.BlackBg - Colors.Black:
        if Colors.Black <= fg <= Colors.White or \
        Colors.bBlack <= fg <= Colors.bWhite:
            return True
    return False


def switchInt(color):
	intensify = Colors.bBlack - Colors.Black
	if Colors.Black <= color <= Colors.WhiteBg:
	    return color + intensify
	if Colors.bBlack <= color <= Colors.bWhiteBg:
	    return color - intensify
	return color


def isFg(color):
    if color == Colors.ResetFg or \
        Colors.Black <= color <= Colors.White or \
        Colors.bBlack <= color <= Colors.bWhite:
        return True
    return False


def isBg(color):
    if color == Colors.ResetBg or \
        Colors.BlackBg <= color <= Colors.WhiteBg or \
        Colors.bBlackBg <= color <= Colors.bWhiteBg:
        return True
    return False


def getStyles(b):
    """gets raw string, Fgs and Bgs styles from an ANSI string"""
    fgs = {0:Colors.ResetFg}
    fg = Colors.ResetFg
    bgs = {0:Colors.ResetBg}
    bg = Colors.ResetBg
    raw = b""
    i = 0
    while i < len(b):
        c = b[i]
        pos = len(raw)
        if c == ESC:
            idx = b.find(b"m", i)
            styles_s = b[i + 2:idx]
            styles = [int(_) for _ in styles_s.split(b";")]
            for s in styles:
                if isFg(s):
                    fgs[pos] = s
                    fg = s
                if isBg(s):
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
    """generate an ANSI string from raw text and sets of Fg and Bg styles"""
    fg = Colors.ResetFg
    bg = Colors.ResetBg
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
        if fg != Colors.ResetFg:
            styles += [Colors.ResetFg]
        if bg != Colors.ResetBg:
            styles += [Colors.ResetBg]
        for style in styles: # some viewers don't support combined settings
            s += marker(style).encode("utf-8")

    return s
