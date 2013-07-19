# should return something like
# 1 3 5 7 9 10 12 14 16 18 23 25 29 31 33 35 37 39 41 43 45 47 49 51 53 55-57 59 63 65 67 69 71 73 75 77 79 81 83 85 87 89 90 94 96 98 101-102 104 106-107 109-112 114-117 119
# when called:
# 119  2 4 6 8 11 13 15 17 19+4 24 26+3 32 34 36 38 40 42 44 46 48 50 52 54 58 60+3 64 66 68 70 72 74 76 78 80 82 84 86 88 91+3 95 97 99+2 103 105 108 113 118

# use with params like <full_length> {<slide_to_skip>[+following range to skip]}+

import sys

def print_couple(start, end):
    if end == start:
        print "%i" % start,
    else:
        print "%i-%i" % (start, end),

def print_shrunk(r):
    start = None
    end = None
    for i in r:
        if start is None:
            start = i
            end = i
        else:
            if i == end + 1:
                end = i
            else:
                print_couple(start, end)
                start = i
                end = i
    print_couple(start,end)

def print_range(r):
    for i, j in enumerate(r):
        print "%03i" % j,
        if (i % 20) == 19:
            print
    print

FULL = int((sys.argv[1]))
r = range(FULL+1)[1:]

# print_range(r)
# print_shrunk(r)
# print
for s in sys.argv[2:]:
    p = s.find("+")
    if p == -1:
        start = int(s)
        size = 1
    else:
        start = int(s[:p])
        size = int(s[p+1:])
    for i in range(size):
        r.remove(start + i)
#print_range(r)
print "pdftk %1 cat", 
print_shrunk(r)
print "output %~n1-trim.pdf"
