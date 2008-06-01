import misc

debug = False

class compress:
    def __init__(self, tagsize):
        self.bsdata = ""
        self.status = ""
        self.tagsize = tagsize
        self.tag = 0
        self.tagoffset = -1
        self.maxbit = (self.tagsize * 8) - 1
        self.currentbit = 0
        self.isfirsttag = True

    def getunkbinstr(self, value):
        """returns a binary string representation of the command/tag

        including unset bits, according to currentbit: ex : 11010xxx"

        """
        s = getpadbinstr(value, self.maxbit + 1)\
            [:self.maxbit - self.currentbit + 1]
        mod = countmissing(len(s), self.maxbit + 1)
        return s + "x" * mod

    def __getstrtag(self):
        """returns the current tag as binary value, little-endian"""
        result = ""
        for i in xrange(self.tagsize):
            result  = result + chr((self.tag >> (8 * i)) & 0xFF )
        return result

    def getstatus(self):
        return "status " + " / ".join([
            gethyphenstr(gethexstr(self.bsdata[:self.tagoffset])) ,
            self.getunkbinstr(self.tag) + " %0X" % (self.tag),
            gethexstr(self.bsdata[self.tagoffset + self.tagsize:])]).strip(" /")

    def printstatus(self):
        if not debug:
            return
        newstatus = self.getstatus()
        if newstatus != self.status:
            self.status = newstatus
            print newstatus

    def getdata(self):
        return self.bsdata[:self.tagoffset] + self.__getstrtag() \
               + self.bsdata[self.tagoffset + self.tagsize:]

    def writebit(self, value):
        self.printstatus()
        if self.currentbit != 0:
            self.currentbit -= 1
        else:
            # write the tag to the string
            if debug:
                print "tag full {"

            if self.isfirsttag:
                if debug:
                    print "first"
                self.isfirsttag = False
            else:
                self.printstatus()
                self.bsdata = self.bsdata[:self.tagoffset] \
                              + self.__getstrtag() \
                              + self.bsdata[self.tagoffset + self.tagsize:]
                self.printstatus()
            self.tagoffset = len(self.bsdata)
            self.bsdata += "".join(["\x00"] * self.tagsize)
            self.printstatus()
            self.currentbit = self.maxbit
            self.tag = 0
            if debug:
                print "}"

        if value:
            if debug:
                print "write b1"
            self.tag |= (1 << self.currentbit)
        else:
            if debug:
                print "write b0"
            pass
        self.printstatus()
        return


    def writebyte(self, byte):
        self.printstatus()
        if type(byte) == int:
            byte = chr(byte)
        if debug:
            print "writebyte '%s' 0x%02X" % (byte, ord(byte))
        self.bsdata += byte
        self.printstatus()
        return

    def writefixednumber(self, value, nbbit):
        if debug:
            print "writefixed", `value`, `nbbit`, "{"
        for i in xrange(nbbit - 1, -1, -1):
            self.writebit( (value >> i) & 1)
        if debug:
            print "}"
        return

    def writevariablenumber(self, value):
        if debug:
            print "writevariable", `value`, "{"
        if value < 2:
            if debug:
                print "error: value < 2"
            return
        # the highest bit is 1
        length = misc.getbinlen(value) - 2
        self.writebit(value & (1 << length))
        for i in xrange(length - 1, -1, -1):
            if debug:
                print "ctrl",
            self.writebit(1)
            self.writebit(value & (1 << i))
        if debug:
            print "ctrl",
        self.writebit(0)
        if debug:
            print "}"
        return


class decompress:
    """decompression bitstream class"""
    def __init__(self, data, tagsize):
        self.currentbit = 0
        self.offset = 0
        self.tag = None
        self.tagsize = tagsize
        self.bsdata = data

    def getoffset(self):
        """return the current byte offset"""
        return self.offset

    def getdata(self):
        return self.bsdata

    def readbit(self):
        """read next bit from the stream"""
        if self.currentbit != 0:
            self.currentbit -= 1
        else:
            self.currentbit = (self.tagsize * 8) - 1
            self.tag = ord(self.readbyte())
            for i in xrange(self.tagsize - 1):
                self.tag += ord(self.readbyte()) << (8 * (i + 1))

        bit = (self.tag  >> ((self.tagsize * 8) - 1)) & 0x01
        self.tag <<= 1
        return bit

    def readbyte(self):
        """read next byte from the stream"""
        if type(self.bsdata) == str:
            result = self.bsdata[self.offset]
        elif type(self.bsdata) == file:
            result = self.bsdata.read(1)
        self.offset += 1
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

    def windowblockcopy(self, offset, length):
        """copies <length> bytes from <offset> (updated backward position)"""
        for i in xrange(length):
            self.decompressed += self.decompressed[-offset]
        return
