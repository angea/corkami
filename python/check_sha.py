from hashlib import sha1
with open("bin.sha", "rt") as f:
    t = f.readlines()
errors = 0
for s, f in ([l[:40], l[42:].rstrip()] for l in t):
    try:
        with open(f, "rb") as f1:
            r = f1.read()
        fs = sha1(r).hexdigest()
        if s != fs:
            errors += 1
            print "%s\r\n < %s\r\n > %s" % (f, s, fs)
    except IOError:
        errors += 1
        print "%s\r\n missing" % f
if errors:
    print "\r\n%i error(s)" % errors
