import sys
with open(sys.argv[1], 'rt') as f:
	a = f.readlines()[1:]
a = set(a)

with open(sys.argv[2], 'rt') as f:
	c = f.readlines()[1:]

c = set(c)

print "total: %s" % len(a | c)
print

sets = a & c, a - c, c - a
sets = [sorted(i, key=str.lower) for i in sets]

line = ""
for m in ["common", "<", ">"]:
	line += '{:^17}'.format(m)
print line

line = ""
for i in sets:
	line += '{:<17}'.format(len(i))
print line

l = max(len(i) for i in sets)
for x in range(l):
	line = ""
	for i in sets:
		s = i[x].strip() if x < len(i) else ""
		line += " " + '{:<16}'.format(s)
	print line
