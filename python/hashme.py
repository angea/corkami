import hashlib
from win32clipboard import *
import win32con

OpenClipboard()
pw, salt = GetClipboardData(win32con.CF_TEXT).split(" ")
rounds = int(raw_input(">"))

s=hashlib.sha256()
s.update(pw)
for _ in xrange(int(rounds)):
	s.update(s.digest() + salt)

EmptyClipboard()
SetClipboardText(s.hexdigest())
del (s, pw, salt, rounds)
CloseClipboard()
print ":)"

raw_input("(clearing)")

OpenClipboard()
EmptyClipboard()
CloseClipboard()
