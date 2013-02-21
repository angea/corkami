"""small renamer from unicode to xml escaping, with correct ouput display"""

import codecs
codecs.register(lambda name: name == 'cp65001' and codecs.lookup('utf-8') or None)

import os
import sys

def u(s):
    return s if sys.stdin.encoding in ['cp65001'] else s.encode('ascii', 'replace').replace("?", "_")

for root, dirs, files in os.walk(u'.'):
    for f in files[:]:
        nf = f.encode("ascii", "xmlcharrefreplace")
        if f == nf:
            continue
        print "%s => %s" % (u(f), u(nf))
        os.rename(f, nf)
