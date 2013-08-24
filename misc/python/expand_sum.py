from hashlib import sha1
import sys
import os.path

with open(sys.argv[1], "rt") as f:
    t = f.readlines()

o = []
current = {}
for s, f in ([l[:40], l[42:].rstrip()] for l in t):
    if s not in current:
        if not os.path.exists(f):
            print "Warning: file %s is missing" % f
        else:
            current[s] = f
    else:
        o += ['copy "%s" "%s"' % (current[s], f)]

print "\n".join(o)

with open("expand.bat", "wt") as f:
    f.write("\n".join(o))
