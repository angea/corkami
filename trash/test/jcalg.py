import lz

def lengthdelta(x):
    if x >= 0x10000:
        return  3;
    elif x >= 0x37FF:
        return 2;
    elif x >= 0x27F:
        return 1;
    elif x <= 127:
        return 4;
    return 0

class compress(lz.compress):
    def __init__(self, data, length=None):
        lz.compress.__init__(self, 4)
        self.__in = data
        self.__length = length if length is not None else len(data)
        self.__lastindex = 1
        self.__indexbase = 8
        self.__literalbits = 0
        self.__literaloffset = 0
        self.__offset = 0
        return

    def __literal(self):
        self.writebit(0)
        self.writefixednumber(ord(self.__in[self.__offset]) - self.__literaloffset, self.__literalbits)
        self.__ofset += 1
        return

    def __block(self, offset, length):
        assert offset >= 2
        if offset == self.__lastindex:
            self.writevariablenumber(2)
            self.writevariablenumber(length)
        else:
            #tbc
        self.writebitstr("10")
        return

    def __shortblock(self, offset, length):
        self.writebitstr("110")
        return

    def __nullliteral(self):
        self.writebitstr("110")
        self.writefixednumber(1,4)
        self.__ofset += 1
        return

    def __singlebyte(self, offset):
        assert 0 <= offset < 16
        self.writebitstr("111")
        self.writefixednumber(offset, 4)
        self.__offset += 1
        self.__pair = True
        return

    def __updateindexbase(self, value):
        self.writebitstr("111")
        self.writefixednumber(0,7)
        nb = misc.countbits(value) 
        self.writefixednumber(value, nb - 3)
        
    def __end(self):
        self.writebitstr("111")
        self.writefixednumber(0,7)
        self.writefixednumber(0,2)
        return

    def do(self):
        self.__literal(False)
        while self.__offset < self.__length:
            offset, length = misc.searchdict(self.__in[:self.__offset],
                self.__in[self.__offset:])
            if offset == -1:
                c = self.__in[self.__offset]
                if c == "\x00":
                    self.__windowbyte(0)
                else:
                    self.__literal()
            elif length == 1 and 0 <= offset < 16:
                self.__singlebyte(offset)
            elif 2 <= length <= 3 and 0 < offset <= 127:
                self.__shortblock(offset, length)
            elif 3 <= length and 2 <= offset:
                self.__block(offset, length)
            else:
                self.__literal()
                #raise ValueError("no parsing found", offset, length)
        self.__end()
        return self.getdata()



class decompress(lz.decompress):
    """jcalg decompression class. inherits bitstream"""
    def __init__(self, data):
        lz.decompress.__init__(self, data, tagsize=4)
        self.__lastindex = 1
        self.__indexbase = 8
        self.__literalbits = 0
        self.__literaloffset = 0
        self.__functions = [
            self.__literal,
            self.__normalphrase,
            self.__onebyteorliteralchange,
            self.__shortmatch,
            ]
        return 

    def __literal(self):
        # literal
        self.literal(chr(self.readfixednumber(self.__literalbits)
             + self.__literaloffset))
        return False

    def __normalphrase(self):
        # dictionary copy with same or new offset
        HighIndex = self.readvariablenumber()

        if (HighIndex == 2):
            # use the last index
            length = self.readvariablenumber();
        else:
            self.__lastindex = ((HighIndex - 3) << self.__indexbase) \
                + self.readfixednumber(self.__indexbase);
            length = self.readvariablenumber();
            length += lengthdelta(self.__lastindex)
        self.dictcopy(self.__lastindex, length)
        return False


    def __onebyteorliteralchange(self):
        onebytephrasevalue = self.readfixednumber(4) - 1
        if onebytephrasevalue == 0:

            # null literal
            self.literal("\0x00")
        else:
            if onebytephrasevalue > 0:

                # single byte
                self.dictcopy(onebytephrasevalue)
            else:

                if self.readbit():

                    # 256 * 8 bit blocks until readbit
                    for i in xrange(256):
                        self.out += self.readfixednumber(8)
                    while self.readbit():
                        for i in xrange(256):
                            self.out += self.readfixednumber(8)
                else:

                    # new literal size
                    self.__literalbits = 7 + self.readbit()
                    self.__literaloffset = 0
                    if self.__literalbits != 8:
                        self.__literaloffset = self.readfixednumber(8)
        return False

    def __shortmatch(self):
        # shortmatch, end or indexbase update
        newindex = self.readfixednumber(7)
        matchlength = 2 + self.readfixednumber(2)
        if newindex == 0:
            if matchlength == 2:

                # end
                return True

            #indexbase update
            self.__indexbase = self.readfixednumber(matchlength + 1)
        else:

            #short block
            self.__lastindex = newindex
            self.dictcopy(self.__lastindex, matchlength)
        return False

    def do(self):
        """returns decompressed buffer and consumed bytes counter"""
        while True:
            if self.__functions[self.countbits(3, 0)]():
                break
        return self.out, self.getoffset()


if __name__ == '__main__':
    import test
    test.jcalg_decompress()
