"""Kabopan project, 2008,

written by Ange Albertini - not to be distributed

"""
import lz


class decompress(lz.decompress):
    """brieflz decompression class. inherits bitstream"""
    def __init__(self, data):
        self.data = lz.decompress.__init__(self, data, cmdsize=4)
        self.decompressed = ""

        # jcalg specific
        self.lastindex = 1
        self.indexbase = 8
        self.literalbits = 0
        self.literaloffset = 0
        self.functions = [
            self.__nextbyte,
            self.__normalphrase,
            self.__onebyteorliteralchange,
            self.__shortmatch,
            ]

        self.functionsbits = len(self.functions) - 1
        return

    def do(self):
        """returns decompressed buffer and consumed bytes counter"""
        while True:
            if self.functions[self.countbits(max=self.functionsbits, set=0)]():
                break
        return self.decompressed, self.offset

    def __nextbyte(self):
        # literal
        self.decompressed += chr(self.readfixednumber(self.literalbits)
             + self.literaloffset)
        return False

    def __normalphrase(self):
        """
        """

        HighIndex = self.readvariablenumber()

        if (HighIndex == 2):
            # use the last index
            length = self.readvariablenumber();
            self.windowblockcopy(self.lastindex, length)
        else:
            self.lastindex = ((HighIndex - 3) << self.indexbase) \
                + self.readfixednumber(self.indexbase);
            length = self.readvariablenumber();
            if self.lastindex >= 0x10000:
                length += 3;
            elif self.lastindex >= 0x37FF:
                length += 2;
            elif self.lastindex >= 0x27F:
                length += 1;
            elif self.lastindex <= 127:
                length += 4;
            try:
                self.windowblockcopy(self.lastindex, length)
            except:
                print "error"
                return True
        return False


    def __onebyteorliteralchange(self):
        # one byte phrase or literal size change 100
        onebytephrasevalue = self.readfixednumber(4) - 1
        if onebytephrasevalue == 0:
            self.decompressed += "\0x00"
        else:
            if onebytephrasevalue > 0:
                try:
                    self.windowblockcopy(onebytephrasevalue, 1)
                except:
                    print "error onebyte"
                    return True
            else:
                if self.readbit():
                    # next block
                    for i in xrange(256):
                        self.decompressed += self.readfixednumber(8)
                    while self.readbit():
                        for i in xrange(256):
                            self.decompressed += self.readfixednumber(8)
                else:
                    # new literal size
                    self.literalbits = 7 + self.readbit()
                    self.literaloffset = 0
                    if self.literalbits != 8:
                        self.literaloffset = self.readfixednumber(8)
        return False

    def __shortmatch(self):
        # shortmatch
        newindex = self.readfixednumber(7)
        matchlength = 2 + self.readfixednumber(2)
        if newindex == 0:
            # extended short
            if matchlength == 2:
                # end of decompression
                return True
            self.indexbase = self.readfixednumber(matchlength + 1)
        else:
            self.lastindex = newindex
            try:
                self.windowblockcopy(self.lastindex, matchlength)
            except:
                return True
        return False
