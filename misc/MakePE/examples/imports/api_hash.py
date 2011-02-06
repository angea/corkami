#small script to generate hashes on (imports) strings
import sys

"""
>api_hash.py LoadLibraryA GetProcAddress
LOADLIBRARYA equ 06FFFE488h
GETPROCADDRESS equ 03F8AAA7Eh
"""

def rol(x, shift, size=32):
    return (x << shift) | (x >> (size - shift))

for s in sys.argv[1:]:
    cs = 0
    for c in s + "\x00":
        cs = rol(cs,7) + ord(c)
        cs %= 2**32
    print "%s equ 0%08Xh" % (s.upper(), cs)

#alternatives:
# \00 terminator included or not
# case conversion: nothing/lower/upper
# initial value
# rol/ror
# rotation amount
# merge : add/xor/sub/or/and
# size: 1 / 2 / 4

