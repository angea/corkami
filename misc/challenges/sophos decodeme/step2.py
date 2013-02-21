from operator import itemgetter

f = open("cryptogram.txt", "rt")
r = f.read()
f.close()

r = r.replace(" ", "").replace("\n", "")
print r

d = {}
for i in set(list(r)):
    d[i] = 0
for i in r:
    d[i] += 1
print "letters by frequencies: " + "".join([e[0] for e in sorted(d.items(), key=itemgetter(1), reverse=True)])

def swap(s, a, b):
    return s.replace(a,"|").replace(b, a).replace("|", b)

r = swap(r, "B", "E")
r = swap(r, "W", "T")

r = swap(r, "O", "R")
r = swap(r, "L", "I")
r = swap(r, "D", "A")

r = swap(r, "K", "H")
r = swap(r, "G", "J")
r = swap(r, "F", "C")
r = swap(r, "Q", "N")
r = swap(r, "V", "S")
r = swap(r, "X", "U")
r = swap(r, "M", "P")
r = swap(r, "Z", "Y")
print r