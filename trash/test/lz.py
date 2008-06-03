import misc

debug = False

class compress:
    def __init__(self, tagsize):
        self.out = ""
        self.__tagsize = tagsize
        self.__tag = 0
        self.__tagoffset = -1
        self.__maxbit = (self.__tagsize * 8) - 1
        self.__curbit = 0
        self.__isfirsttag = True


    def getdata(self):
        tagstr = misc.int2lebin(self.__tag, self.__tagsize)
        return misc.modifystring(self.out, tagstr, self.__tagoffset)

    def writebit(self, value):
        if self.__curbit != 0:
            self.__curbit -= 1
        else:
            if self.__isfirsttag:
                self.__isfirsttag = False
            else:
                self.out = self.getdata()
            self.__tagoffset = len(self.out)
            self.out += "".join(["\x00"] * self.__tagsize)
            self.__curbit = self.__maxbit
            self.__tag = 0

        if value:
            self.__tag |= (1 << self.__curbit)
        return

    def writebitstr(self, s):
        for c in s:
            self.writebit(0 if c == "0" else 1)
        return
        
    def writebyte(self, byte):
        self.out += byte
        return

    def writefixednumber(self, value, nbbit):
        for i in xrange(nbbit - 1, -1, -1):
            self.writebit( (value >> i) & 1)
        return

    def writevariablenumber(self, value):
        assert value >= 2

        length = misc.getbinlen(value) - 2 # the highest bit is 1
        self.writebit(value & (1 << length))
        for i in xrange(length - 1, -1, -1):
            self.writebit(1)
            self.writebit(value & (1 << i))
        self.writebit(0)
        return

# outdated debug visual stuff

#    def getstatus(self):
#        return "status " + " / ".join([
#            gethyphenstr(gethexstr(self.bsdata[:self.tagoffset])) ,
#            self.getunkbinstr(self.tag, self.currentbit, self.maxbit) + " %0X" % (self.tag),
#            gethexstr(self.bsdata[self.tagoffset + self.tagsize:])]).strip(" /")

#    def printstatus(self):
#        if not debug:
#            return
#        newstatus = self.getstatus()
#        if newstatus != self.status:
#            self.status = newstatus
#            print newstatus


class decompress:
    """decompression bitstream class"""
    def __init__(self, data, tagsize):
        self.__curbit = 0
        self.__offset = 0
        self.__tag = None
        self.__tagsize = tagsize
        self.__in = data
        self.out = ""

    def getoffset(self):
        """return the current byte offset"""
        return self.__offset

#    def getdata(self):
#        return self.__lzdata

    def readbit(self):
        """read next bit from the stream"""
        if self.__curbit != 0:
            self.__curbit -= 1
        else:
            self.__curbit = (self.__tagsize * 8) - 1
            self.__tag = ord(self.readbyte())
            for i in xrange(self.__tagsize - 1):
                self.__tag += ord(self.readbyte()) << (8 * (i + 1))

        bit = (self.__tag  >> ((self.__tagsize * 8) - 1)) & 0x01
        self.__tag <<= 1
        return bit

    def readbyte(self):
        """read next byte from the stream"""
        if type(self.__in) == str:
            result = self.__in[self.__offset]
        elif type(self.__in) == file:
            result = self.__in.read(1)
        self.__offset += 1
        return result

    def readfixednumber(self, nbbit, init=0):
        """reads a fixed bit-length number"""
        result = init
        for i in xrange(nbbit):
            result = (result << 1)  + self.readbit()
        return result

    def readvariablenumber(self):
        """return a variable bit-length number x, x >= 2

        reads a bit until the next bit in the pair is not set"""
        result = 1
        result = (result << 1) + self.readbit()
        while self.readbit():
            result = (result << 1) + self.readbit()
        return result

    def countbits(self, max, set=1):
        """count how many consecutive bits are set"""
        result = 0
        while result < max and self.readbit() == set:
            result += 1
        return result

    def dictcopy(self, offset, length=1):
        for i in xrange(length):
            self.out += self.out[-offset]
        return

    def literal(self, value=None):
        if value is None:
            self.out += self.readbyte()
        else:
            self.out += value
        return False


if __name__ == '__main__':
    import test
    debug = False
    test.lz_compdec()
