#xxd -r via windows clipboard

from win32clipboard import *
import win32con

OpenClipboard()
buf = GetClipboardData(win32con.CF_TEXT)

d = []
for l in buf.split("\n"):
    l = l.strip()
    l = l[8:-16].strip()
    l = l.replace(" ", "")
    d.append(l)
d = "".join(d)

d = "".join([chr(int(d[i*2:i * 2 + 2], 16))  for i in range(len(d) / 2)])

with open("xxd-dump", "wb") as f:
    f.write(d)
