# a tiny file differ with a Portable PixelMap image as output
# AKA "how to generate the simplest standard image file"

# Ange Albertini, BSD licence 2015

WIDTH = 32
WHITE = "\xff\xff\xff"
RED = "\xff\0\0"

import sys

filename1, filename2, imagename = sys.argv[1:4]

with open(filename1, "rb") as f1:
    d1 = f1.read()
with open(filename2, "rb") as f2:
    d2 = f2.read()

l = len(d1)
assert l == len(d2)
HEIGHT = (len(d1) / WIDTH) + 1


pixels = []
for i in range(l):
    pixels.append(WHITE if d1[i] == d2[i] else RED)
# remaining pixels will be black


with open(imagename, "wb") as fo:
    fo.write("P6 %i %i 255 " % (WIDTH, HEIGHT))
    fo.write("".join(pixels))
