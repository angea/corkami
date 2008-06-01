debug = False

def getbinlen(value):
    """return the bit length of an integer"""
    result = 0
    while value != 0:
        value >>= 1
        result += 1
    return result

def getlongestcommon(a, b):
    """returns i, maximum value such that a[:i] == b[:i]"""
    l = min(map(len, [a, b]))
    res = 0
    while res < l and a[res] == b[res]:
        res += 1
    return res

def gethyphenstr(s, limit = 9, sep = " [...] "):
    """turns a long string into a [...]-shortened string"""
    if len(s) > 2*limit + len(sep):
        return s[:limit].rstrip() + sep + s[-limit:].lstrip()
    else:
        return s

def getbinstr(value):
    """return the smallest binary representation of an integer

    getbinstr(8) -> "1000"

    """
    result = ""
    while value != 0:
        if value & 1:
            result = "1" + result
        else:
            result = "0" + result
        value >>= 1
    return result

def countmissing(value, modulo):
    """returns x > 0 so that (value + x) % modulo = 0"""
    result = value % modulo
    if result == 0:
        result = modulo
    return modulo - result

def getpadbinstr(value,bits):
    """return a 0-padded binary string

    getpadbinstr(8,8) = "00001000"

    """
    s = getbinstr(value)
    l = len(s)
    mod = countmissing(l,bits)

    return "0" * mod + s

def gethexstr(string):
    return " ".join(map(lambda i: "%02X" % (ord(i)),string))

def brutting_snippet(data):
    maxlen = 0
    result = {}
    for i in xrange(50):
        blz = jcalg_decompress(data[i:])
        decomp, offset = blz.do()
        maxlen = max(len(decomp), maxlen)
        result[len(decomp)] = i
        print

    print result
    print maxlen, result[maxlen]
    return result[maxlen]

def write_snippet(filename):
    f = open(filename + ".out", "wb")
    for i in decomp:
        f.write(i)
    f.close()


def checkfindest(dic, stream, offset, length):
    temp = dic[:]
    for i in xrange(length):
            temp += temp[-offset]
    if temp != dic + stream[:length]:
        print temp
        print dic + stream[:length]
        return False
    return True

def findlongeststring(s, sub):
    stream = s[:]
    """returns the number of byte to look backward and the length of byte to copy)"""
#    if sub :
#        return -1, -1
    l = 0
    offset = -1
    size = 0
    w = ""

    w += sub[l]
    i = stream.find(w)
    if debug:print offset, size, stream, w
    if i == -1:
        if debug: print "notfound1"
        return -1, -1

    offset = len(s) - i
    size = len(w)
    stream += sub[l]

    while l < len(sub) - 1:
        l += 1
        w += sub[l]

        if debug:print offset, size, "'", stream, "'", w
        i = stream.find(w)
        if i == -1:
            if debug: print "not found2"
            assert checkfindest(s, sub, offset, size)

            return offset, size
        stream += sub[l]
        offset = len(s) - i
        size = len(w)

    else:
        #print "end of while"
        pass
    return offset, size
