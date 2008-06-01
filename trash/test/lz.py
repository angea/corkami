"""Kabopan project, 2008,

written by Ange Albertini - not to be distributed

"""
import misc

debug = False

class compress:
    def __init__(self, cmdsize):
        self.bsdata = ""
        self.status = ""
        self.cmdsize = cmdsize
        self.cmd = 0
        self.cmdoffset = -1
        self.maxbit = (self.cmdsize * 8) - 1
        self.currentbit = 0
        self.isfirstcmd = True

    def getunkbinstr(self, value):
        """returns a binary string representation of the command/tag

        including unset bits, according to currentbit: ex : 11010xxx"

        """
        s = getpadbinstr(value, self.maxbit + 1)\
            [:self.maxbit - self.currentbit + 1]
        mod = countmissing(len(s), self.maxbit + 1)
        return s + "x" * mod

    def __getstrcmd(self):
        """returns the current tag as binary value, little-endian"""
        result = ""
        for i in xrange(self.cmdsize):
            result  = result + chr((self.cmd >> (8 * i)) & 0xFF )
        return result

    def getstatus(self):
        return "status " + " / ".join([
            gethyphenstr(gethexstr(self.bsdata[:self.cmdoffset])) ,
            self.getunkbinstr(self.cmd) + " %0X" % (self.cmd),
            gethexstr(self.bsdata[self.cmdoffset + self.cmdsize:])]).strip(" /")

    def printstatus(self):
        if not debug:
            return
        newstatus = self.getstatus()
        if newstatus != self.status:
            self.status = newstatus
            print newstatus

    def getdata(self):
        return self.bsdata[:self.cmdoffset] + self.__getstrcmd() \
               + self.bsdata[self.cmdoffset + self.cmdsize:]

    def writebit(self, value):
        self.printstatus()
        if self.currentbit != 0:
            self.currentbit -= 1
        else:
            # write the cmd to the string
            if debug:
                print "cmd full {"

            if self.isfirstcmd:
                if debug:
                    print "first"
                self.isfirstcmd = False
            else:
                self.printstatus()
                self.bsdata = self.bsdata[:self.cmdoffset] \
                              + self.__getstrcmd() \
                              + self.bsdata[self.cmdoffset + self.cmdsize:]
                self.printstatus()
            self.cmdoffset = len(self.bsdata)
            self.bsdata += "".join(["\x00"] * self.cmdsize)
            self.printstatus()
            self.currentbit = self.maxbit
            self.cmd = 0
            if debug:
                print "}"

        if value:
            if debug:
                print "write b1"
            self.cmd |= (1 << self.currentbit)
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
    def __init__(self, data, cmdsize):
        self.currentbit = 0
        self.offset = 0
        self.cmd = None
        self.cmdsize = cmdsize
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
            self.currentbit = (self.cmdsize * 8) - 1
            self.cmd = ord(self.readbyte())
            for i in xrange(self.cmdsize - 1):
                self.cmd += ord(self.readbyte()) << (8 * (i + 1))

        bit = (self.cmd  >> ((self.cmdsize * 8) - 1)) & 0x01
        self.cmd <<= 1
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
        """return a variable bit-length number x, x <= 2

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
