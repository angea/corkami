from hashlib import sha1
import sys

with open(sys.argv[1], "rt") as f:
    t = f.readlines()
errors = 0

for s, f in ([l[:40], l[42:].rstrip()] for l in t):
    try:
        with open(f, "rb") as f1:
            r = f1.read()
        fs = sha1(r).hexdigest()
        if s != fs:
            errors += 1
            print "%s *%s\r" % (fs, f)
    except IOError:
        errors += 1
        print "MISSING: %s\r" % f
if errors:
    print "\r\n%i error(s)" % errors
