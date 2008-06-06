import md5
import random

import misc
import testdata


def lz_compdec(testnb=5, length=300):
    import lz

    def setbyte(c):
        val = random.randrange(0,255)
        c.writebyte(chr(val));
        return val

    def setbit(c):
        val = random.randrange(0,2)
        c.writebit(val);
        return val

    def setvariablenumber(c):
        val = 2 + random.randrange(0,50000)
        c.writevariablenumber(val);
        return val

    def setfixednumber(c):
        val1 = random.randrange(0,50000)
        val2 = misc.getbinlen(val1)
        c.writefixednumber(val1, val2);
        return [val1, val2]


    def checkbyte(d, expected):
        value = ord(d.readbyte())
        return (True, None) if value == expected else (False, "error byte: expected %i, found %i" % (expected, value))

    def checkbit(d, expected):
        value = d.readbit()
        return (True, None) if value == expected else (False, "error bit: expected %i, found %i" % (expected, value))

    def checkvariablenumber(d, expected):
        value = d.readvariablenumber()
        return (True, None) if value == expected else (False, "error variablenumber: expected %i, found %i" % (expected, value))

    def checkfixednumber(d, expected):
        value = d.readfixednumber(expected[1])
        return (True, None) if value == expected[0] else (False, "error fixednumber: expected %i, found %i" % (expected[0], value))

    s_setfunc = {
        0: setbyte,
        1: setbit,
        2: setvariablenumber,
        3: setfixednumber,
            }
    nbfunc = len(s_setfunc)
    s_checkfunc = {
        0: checkbyte,
        1: checkbit,
        2: checkvariablenumber,
        3: checkfixednumber,
            }
    assert nbfunc == len(s_checkfunc)

    fail = []
    for test in xrange(testnb):
        cmdsize = 1 << (random.randrange(0,3))
        sequence = [{"cmdsize":cmdsize}]
        c = lz.compress(cmdsize)
        del(cmdsize)

        for i in xrange(length):
            r = random.randrange(0,nbfunc)
            sequence += [{"func" :r,"values": s_setfunc[r](c)}]

        d = lz.decompress(c.getdata(), sequence[0]["cmdsize"])
        for i, r in enumerate(sequence[1:]):
            ok, msg = s_checkfunc[r["func"]](d, r["values"])
            if not ok:
                print "lz"
                print msg
                fail += [{
                    "sequence" : sequence[0],
                    "position" : i,
                    "currentdata": d.getdata()[:10],
                    }]
                break
    if not fail:
        return None
    return fail


teststring = "this is a very very original string to decompress. let's see if it " \
    "decompresses correctly. let's add a few original strings to enhance compression."
testmd5 = "c388a7e2b0f63d7fc2f7a00b7a5d0aca"

def jcalg_decompress():
    import jcalg

    data = testdata.jcalg1[10:]    # skip header

    blz = jcalg.decompress(data)
    decomp, offset = blz.do()

    m = md5.md5(decomp).hexdigest()
    if m != "7cda56f22188840f178efeebfb01f6b1":
        print "jcalg decompression error"
    else:
        pass

def aplib_decompress():
    data = teststring
    comp, decomp = aplib_compdecsingle(data)
    if misc.md5(comp) not in ["a10554fc5762f6d65076121a4aed4c4e"]:
        print "aplib comp error"
    if misc.md5(decomp) != testmd5:
        print "aplib decomp serror"

def brieflz_decompress():
    data = teststring
    comp, decomp = brieflz_compdecsingle(data)
    if misc.md5(comp) not in ["05cf0b772e62f03d954dd1e3ed7a1658",
        "ada336ab80f728261a1f746e56c13ec8"]:
        print "brieflz comp error"
    if misc.md5(decomp) != testmd5:
        print "brieflz decomp serror"


def generatedata(length):
    data = "".join([chr(random.randrange(40,125)) for x in xrange(10)])
    while len(data) < length:
        c = random.randrange(0,10)
        if c > 8:
            start = random.randrange(0, len(data))
            size = random.randrange(1, len(data))
            data += data[start:start + size]
        else:
            data += chr(random.randrange(40,125))
    return data

def brieflz_compdecsingle(data):
    import brieflz
    c = brieflz.compress(data)
    compressed = c.do()
    d = brieflz.decompress(compressed, len(compressed))
    decompressed , consumed = d.do()
    return compressed, decompressed

def aplib_compdecsingle(data):
    import aplib
    c = aplib.compress(data)
    compressed = c.do()
    d = aplib.decompress(compressed)
    decompressed , consumed = d.do()
    return compressed, decompressed

def generic_compdec(testnb, testlength, compdecfunc, testdesc):
    for i in xrange(testnb):
        data = generatedata(testlength)
        compressed, decompressed = compdecfunc(data)
        #print len(compressed), len(decompressed) , "|",
        if  decompressed != data:
            print testdesc + " fail"
            limit = misc.getlongestcommon(data, decompressed)
            print limit
            print "original", misc.gethyphenstr(data[:limit]), misc.gethyphenstr(data[limit:]), len(data)
            print "result  ", misc.gethyphenstr(decompressed[:limit]), misc.gethyphenstr(decompressed[limit:]), len(decompressed)
            print
            return


def brieflz_compdec(testnb=100, testlength=300):
    generic_compdec(testnb, testlength, brieflz_compdecsingle, "brieflz compdec")

def aplib_compdec(testnb=30, testlength=300):
    generic_compdec(testnb, testlength, aplib_compdecsingle, "aplib compdec")


if __name__ == '__main__':
    debug = False
    lz_compdec()
    brieflz_decompress()
    jcalg_decompress()
    aplib_decompress()
    brieflz_compdec()
    aplib_compdec()
