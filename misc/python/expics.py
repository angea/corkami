import sys, base64

def extracttext(start, r, ext):
    c = 0
    while r.find(start) > -1:
        c += 1
        r = r[r.find(start) + len(start):]
        end = r.find('"')
        with open("%s-%02i.%s" % (fn, c, ext), "wb") as t:
            t.write(base64.b64decode(r[:end]))

fn = sys.argv[1]
with open(fn, "rb") as f:
    r = f.read()

extracttext("data:image/jpeg;base64,", r, "jpg")
extracttext("data:image/png;base64,", r, "png")
extracttext("data:image/gif;base64,", r, "gif")

