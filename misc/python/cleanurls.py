import sys
import urllib

fn = sys.argv[1]

with open(fn, "rb") as s:
	r = s.read()

URIP = "/URI ("
BADURL = "http://www.google.com/url?q="
START = URIP + BADURL

def cleanup(s):
    s = s[len(BADURL):]
    s = urllib.unquote(s)
    s = s[:s.find("&")]
    return s

start = r.find(START)
while (start > -1):
	start += len(URIP)
	end = r[start:].find(")") + start
	url = r[start:end]
	rep = cleanup(url)
	print url, rep
	r = r.replace(r[start:end], rep)
	start = r.find(START)

with open(fn + "_", "wb") as t:
	t.write(r)