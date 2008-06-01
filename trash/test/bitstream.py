"""Kabopan project, 2008,

written by Ange Albertini - not to be distributed

"""

debug = True

import lz
import misc

if __name__ == '__main__':
    import os, md5

    def dumphex(data):
        for i in data:
            print "%02x" % (ord(i)),
        print
        return

    debug = False

    #print
    #print
    #c = brieflz_compress("aaaaaa")
    #comp = c.do()
    #print
    #print
    #print gethexstr(comp)
    #d = brieflz_decompress(comp, len(comp))
    #print d.do()
    print
    #d = brieflz_decompress("\x61\x00\xC0\x00", 4)
    #print d.do()


    #test = compresstest(10000,500)
    brieflz_test(30, 200)
