import base64
f = open("decodeme.txt", "rt")
r = f.readlines()
f.close()

r = r[1:-2]

r = "".join(r)
r = r.replace(" ", "")
r = base64.standard_b64decode(r)

f = open("url.gif.gz", "wb")
f.write(r)
f.close()

# gif reads (difficultly) as http://www.sophos.com/anz/sofarsogood.html