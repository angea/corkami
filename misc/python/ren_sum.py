# a script to rename files by changing their names in a TC checksum list

#Ange Albertini 2013

import sys
import hashlib
import glob

fn = sys.argv[1]
with open(fn, "r") as s:
    r = s.readlines()

sums = {}
for s in r:
    s = s.strip()
    sha1, file = s[:40], s[40 + 2:]
    file = file[file.rfind("\\") + 1:]
    if sha1 not in sums:
        sums[sha1] = file
    else:
        del(sums[sha1])

unknowns = []
for f in sorted(glob.glob("*")):
    try:
        with open(f, "rb") as file:
            content = file.read()
    except:
        continue

    sum = hashlib.sha1(content).hexdigest()
    if sum in sums and f != sums[sum]:
        print 'ren %s %s' % (('"' + f + '"').ljust(30), ('"' + sums[sum] + '"').ljust(30))
    elif sum not in sums:
        unknowns += [f]

if unknowns:
    print "unknowns or duplicates: " + " ".join(unknowns)
