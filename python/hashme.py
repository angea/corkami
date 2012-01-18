import hashlib
from win32clipboard import *
import win32con

OpenClipboard()
pw, salt, rounds = GetClipboardData(win32con.CF_TEXT).split(" ")

s=hashlib.sha256()
s.update(pw)
for _ in xrange(int(rounds)):
	s.update(s.digest() + salt)

EmptyClipboard()
SetClipboardText(s.hexdigest())
CloseClipboard()
print ":)"