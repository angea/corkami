from win32clipboard import *
import win32con
import datetime

OpenClipboard()
t = GetClipboardData(win32con.CF_TEXT)

if t.find("Back to top") == -1:
	print "error"
	import sys
	sys.exit
c = 0
l = []
for s in t.split("\n"):
    if s.find("? @") > -1:
        c += 1
        l.append(s[s.find("? @") + 2:].strip())
l = l[3:]
l = [" %i" % len(l)] + l

with open("%s.txt" % (datetime.date.today()), "wt") as f:
	f.write("\n".join(l))