#transposition cipher

def findall(s, c):
    """yields all indexes where 'c' is found in 's'"""
    count_ = s.count(c)
    if not count_:
        return
    p = 0
    for _ in xrange(count_):
        p = s.find(c, p) + 1
        yield p - 1

key = "OZYMANDIAS"

l = [0] * len(key)
pos = 0
for i in (chr(c) for c in xrange(ord('A'), ord('Z') + 1)):
     for j in findall(key, i):
        pos += 1
        l[j] = pos

reverse_ = [l.index(i + 1) for i in xrange(len(l))]

plaintext = "company has reached primary goal"
cols = list()
for _ in range(len(key)):
    cols += [list()]

col = 0
for i,c in enumerate(plaintext.replace(" ","")):
    j = (i % len(key))
    cols[l[j] - 1] += [c]

cipher = []
for l1 in cols:
    for j in l1:
        cipher += ["".join(j)]

cipher = "".join(cipher)
print "plaintext", plaintext
print "key", key
print "cipher", cipher
