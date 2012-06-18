from win32clipboard import *
import win32con
import datetime

OpenClipboard()
t = GetClipboardData(win32con.CF_TEXT)

c = 0
l = []
for s in t.split("\n"):
    if s.find("? @") > -1:
        c += 1
        l.append(s[s.find("? @") + 2:].strip())
l = l[3:]
l = ["%s %i" % (datetime.date.today(), len(l))] + l

EmptyClipboard()
SetClipboardText("\r\n".join(l))
CloseClipboard()
