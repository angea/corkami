from ansi import Markers, Colors

# TODO: consistent with markers and colors

class Theme:
    resetBg = Colors.ResetBg
    resetFg = Colors.ResetFg
    reset  = Markers.ResetFg + Markers.ResetBg

    offset = ""        # the offsets on the left before the hex
    # ASCII and control characters \n ^Z/
    alpha  = ["", ""]
    skip   = ""        # the dots when skipping ranges of data
    ruler  = ""        # the  0  1  2 ... ruler before and after the hex
    rulerBg = ""       # alt background for compact mode

    altBg  = ""        # alt background for compact mode
    end    = ""        # the end marker ]]
    zero   = ""        # alt color for zeroes


class thDark(Theme):
    offset  = Markers.Yellow   

    alpha   = [
        Markers.Cyan + Markers.BlueBg,
        Markers.bCyan + Markers.bBlueBg,
    ]
    skip    = Markers.bYellow
    ruler   = Markers.bGreen
    rulerBg = Colors.GreenBg
    altBg   = Colors.bBlackBg
    end     = Markers.bRed
    zero    = Markers.bBlack


class thLight(Theme):
    offset  = Markers.Yellow
    alpha   = [
        Markers.Cyan + Markers.BlueBg,
        Markers.bCyan + Markers.bBlueBg,
    ]
    skip    = Markers.Yellow
    ruler   = Markers.Green
    rulerBg = Colors.bGreenBg
    altBg   = Colors.WhiteBg
    end     = Markers.Red
    zero    = Markers.bBlack


class thAscii(Theme):
    reset  = ""


themes = {
    "dark"  : thDark,
    "light" : thLight,
    "ascii" : thAscii
}
