# a script to turn a normal sentence into a sequence of left-to-right and right-to-left strings, with the same rendering

import sys
import random
import codecs

START = u"\u202e"
END = u"\u202d"

def _(s):
	return START + u"".join(s[::-1]) + END

def splitstr(s, c):
    if c < 2:
        return [s]
    size = len(s) / c
    off = 0
    words = []
    for i in xrange(c):
        words.append(s[off:off + size])
        off += size
    words[-1] = words[-1] + s[off:]
    return words

if len(sys.argv) == 1:
    print "Usage: %s <input_file>\n\t will create <input_file.rev>" % sys.argv[0]
    sys.exit()

fn = sys.argv[1]
with open(fn, "rb") as f:
    source = f.read()

l = len(source)

#let's split the string in 2
middle = random.randint(1, l - 1)
start, end = source[:middle], source[middle:]

# and split each side in the same amount of words
splitcounter = random.randint(1, min(middle, l - middle))
starts, ends = splitstr(start, splitcounter), splitstr(end, splitcounter)

assert len(starts) == len(ends)
i = len(starts)

final = []
for k in xrange(i):
    final.append(starts[k])
    final.append(_(ends[i - 1 - k]))

target = "".join(final)
with codecs.open(fn + ".rev", "w+", encoding='utf-16') as f:
	f.write(target)
sys.exit()
