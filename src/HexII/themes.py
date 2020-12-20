from ansi import Ansi

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
    "dark" : thDark,
    "ascii": thAscii
}
