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
    """return a 0-padded binary string. ex:getpadbinstr(8,8) = "00001000" """
    s = getbinstr(value)
    l = len(s)
    mod = countmissing(l,bits)
    return "0" * mod + s

    def getunkbinstr(value, currentbit, maxbit):
        """returns a binary string representation of the command/tag

        including unset bits, according to currentbit: ex : 11010xxx"

        """
        s = getpadbinstr(value, maxbit + 1)\
            [:maxbit - currentbit + 1]
        mod = countmissing(len(s), maxbit + 1)
        return s + "x" * mod

def gethexstr(string):
    return " ".join(map(lambda i: "%02X" % (ord(i)),string))

def brutting_snippet(data, function):
    maxlen = 0
    result = {}
    for i in xrange(50):
        blz = function(data[i:])
        decomp, consumed = blz.do()
        maxlen = max(len(decomp), maxlen)
        result[len(decomp)] = i
        print

    print result
    print maxlen, result[maxlen]
    return result[maxlen]

def write_snippet(filename, data):
    f = open(filename + ".out", "wb")
    for i in data:
        f.write(i)
    f.close()

def checkfindest(dic, stream, offset, length):
    """checks that findlongeststring result is correct"""
    temp = dic[:]
    for i in xrange(length):
            temp += temp[-offset]
    if temp != dic + stream[:length]:
        print temp
        print dic + stream[:length]
        return False
    return True

def findmax(s, sub, limit):
    """returns latest <sub> occurence in <s> within [0; <limit>]"""
    result = -1
    pos = s.find(sub, result + 1, limit + 1)
    while result < pos:
        result = pos
        pos = s.find(sub, result + 1, limit + 1)
    return result

def searchdict(s, sub):
    limit = len(s)
    dic = s[:]
    """returns the number of byte to look backward and the length of byte to copy)"""
    l = 0
    offset = -1
    length = 0
    word = ""

    word += sub[l]
    pos = findmax(dic, word, limit)
    if pos == -1:
        return offset, length

    offset = limit - pos
    length = len(word)
    dic += sub[l]

    while l < len(sub) - 1:
        l += 1
        word += sub[l]

        pos = findmax(dic, word, limit)
        if pos == -1:
            return offset, length
        offset = limit - pos
        length = len(word)
        dic += sub[l]
    return offset, length

def md5(s):
    import md5
    return md5.md5(s).hexdigest()
    
def modifystring(s, sub, offset):
    return s[:offset] + sub + s[offset + len(sub):]
        
def int2lebin(value, size):
    """returns a binary string of an integer, as little-endian"""
    result = ""
    for i in xrange(size):
        result = result + chr((value >> (8 * i)) & 0xFF )
    return result

