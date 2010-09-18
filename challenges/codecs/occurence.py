# count char based codec
# from Leet More 2010 Elf Quest

import random

def countocc(s):
    return [s.count(c) for c in (chr(i) for i in xrange(256))]

def enc(d, block=None):
    if block is None:
        block = ""
    occs = countocc(block)

    r = ""
    for i, j in enumerate(d):
        r += chr(i) * (ord(j) - occs[i])
    r = list(r)
    random.shuffle(r)
    r = block + "".join(r)
    return r

def dec(d):
    s = countocc(d)
    decrypted = "".join(chr(i) for i in s)
    stripped = decrypted.strip("".join([chr(i) for i in range(30)]))
    return stripped

import sys
block = open(sys.argv[1], "rb").read()

plaintext = "Thanks for everything!"
encrypted = enc(plaintext, block)
f = open(sys.argv[1] + ".enc", "wb")
f.write(encrypted)
f.close()

decrypted = dec(encrypted)
assert decrypted == plaintext

#import pprint
#pprint.pprint(encrypted)

