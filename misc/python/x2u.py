"""small renamer from xml escaping to unicode, with correct ouput display"""

import codecs
codecs.register(lambda name: name == 'cp65001' and codecs.lookup('utf-8') or None)

import os
import sys

def u(s):
    return s if sys.stdin.encoding in ['cp65001'] else s.encode('ascii', 'replace').replace("?", "_")

for root, dirs, files in os.walk(u'.'):
    for f in files[:]:
        nf = f
        while nf.find("&#") != -1:
            off = nf.find("&#")
            off2 = nf.find(";", off)
            uc = nf[off: off2 + 1]
            n = int(uc[2:-1])
            nf = nf.replace(nf[off: off2 + 1], unichr(n))
        if f == nf:
            continue
        print "%s => %s" % (u(f), u(nf))
        os.rename(f, nf)
