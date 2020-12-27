#!/usr/bin/env python3

# sets of characters for interface display (ascii, unicode)

class charset:
    end = "]]"
    skip = "-"
    skOff = ">"
    digits = ["%X" % i for i in range(16)]
    numbers = ["%X" % i for i in range(256)]


class csAscii(charset):
    pass


chrs = lambda start, end: [chr(i) for i in range(start, end)]
fully_circled_digits = sum([
    ["\u24ea"], # 0
    chrs(0x2460, 0x2469), # 1-9
    chrs(0x2469, 0x246F), # 11-15
    # chrs(0x24b6, 0x24bb), # A-F
    # chrs(0x24d0, 0x24d5), # a-z
    ], [])

neg_circled_digits = sum([
    ["\u24ff"], # 0
    chrs(0x2776, 0x277f),   # 1-9
    chrs(0x1f150, 0x1f155), # A-F
    ], [])

neg_circled_sserif = sum([
    ["\U0001f10c"], # 0
    chrs(0x278A, 0x2792), # 1-9
    ], [])


class csUnicode(charset):
    skip = "\u2508"
    # \u2219 Bullet Operator
    # \u2500 Box Drawings Light Horizontal
    # \u2508 Box Drawings Light Quadruple Dash Horizontal
    skOff = "\u254c"


charsets = {
    "ascii": csAscii,
    "unicode": csUnicode
}
