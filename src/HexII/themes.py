from ansi import Markers

class Theme:
    reset  = Markers.ResetFG + Markers.ResetBG

    offset = ""
    alpha  = ["", ""]
    skip   = ""
    ruler  = ""
    end    = ""
    zero   = ""


class thDark(Theme):
    offset = Markers.Yellow   # the offsets on the left before the hex
    # ASCII and control characters \n ^Z/
    alpha  = [
        Markers.Cyan + Markers.BlueBG,
        Markers.bCyan + Markers.bBlueBG,
    ]
    zero   = Markers.bBlack   # 
    skip   = Markers.bYellow  # the dots when skipping ranges of data
    ruler  = Markers.Green    # the  0  1  2 ... ruler before and after the hex
    end    = Markers.bRed     # the end marker ]]


class thAscii(Theme):
    reset  = ""


themes = {
    "dark" : thDark,
    "ascii": thAscii
}
