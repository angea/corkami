from hashlib import sha1
import os, sys

sumfn = sys.argv[1]

#gathering existing files
real_names = []
for root, dirs, files in os.walk('.'):
    for file in files:
        real_names += [os.path.join(root, file).replace(".\\", "")]


with open(sumfn, "rt") as f:
    t = f.readlines()
errors = 0

def get_sum(f):
    with open(f, "rb") as f1:
        r = f1.read()
    return sha1(r).hexdigest()


list_names = [sumfn]
for s, f in ([l[:40], l[42:].rstrip()] for l in t):
    list_names += [f]
    try:
        fs = get_sum(f)
        if s != fs:
            errors += 1
            print "%s *%s\r" % (fs, f)
    except IOError:
        errors += 1
        print "MISSING: %s\r" % f
if errors:
    print "\r\n%i error(s)" % errors

absents = list(set(real_names) - set(list_names))

if absents:
    print "files not in checksum list"
    for f in absents:
        print "%s *%s" % (get_sum(f), f)