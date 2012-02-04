from win32clipboard import *
import win32con
import sys

def buftoChex(s):
    name = "sig_%s%i" % (buf, len(buf))
    for c in '"' + "' /;.($)[]":
        name = name.replace(c, "_")

    l = []
    l.append("static unsigned char %s[%i] = " % (name, len(buf)))
    l.append("{")
    s = ""
    for i, j in enumerate(buf):
        if (i % 12) == 11:
            l.append(s)
            s = ""
        if (i % 12) == 0:
            s = "\t" + s
        s = s + "0x%02X, " % ord(j)
    if s != "":
        l.append(s)    
    l.append("};")
    l.append("")
    return "\n".join(l)

while (raw_input(">") != "quit"):
    OpenClipboard()
    buf = GetClipboardData(win32con.CF_TEXT)
    buf = buf.strip()
    
    print "got:", buf
    s = buftoChex(buf)
    print "put:"
    print s
    print
    
    EmptyClipboard()
    SetClipboardText(s)
    CloseClipboard()
