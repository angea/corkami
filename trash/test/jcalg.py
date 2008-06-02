import lz


class decompress(lz.decompress):
    """brieflz decompression class. inherits bitstream"""
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

        self.__functionsbits = len(self.__functions) - 1
        return

    def __literal(self):
        # literal
        self.out += chr(self.readfixednumber(self.__literalbits)
             + self.__literaloffset)
        return False

    def __normalphrase(self):
        """
        """

        HighIndex = self.readvariablenumber()

        if (HighIndex == 2):
            # use the last index
            length = self.readvariablenumber();
            self.copywindow(self.__lastindex, length)
        else:
            self.__lastindex = ((HighIndex - 3) << self.__indexbase) \
                + self.readfixednumber(self.__indexbase);
            length = self.readvariablenumber();
            if self.__lastindex >= 0x10000:
                length += 3;
            elif self.__lastindex >= 0x37FF:
                length += 2;
            elif self.__lastindex >= 0x27F:
                length += 1;
            elif self.__lastindex <= 127:
                length += 4;
            try:
                self.copywindow(self.__lastindex, length)
            except:
                print "error"
                return True
        return False


    def __onebyteorliteralchange(self):
        # one byte phrase or literal size change 100
        onebytephrasevalue = self.readfixednumber(4) - 1
        if onebytephrasevalue == 0:
            self.out += "\0x00"
        else:
            if onebytephrasevalue > 0:
                try:
                    self.copywindow(onebytephrasevalue)
                except:
                    print "error onebyte"
                    return True
            else:
                if self.readbit():
                    # next block
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
        # shortmatch
        newindex = self.readfixednumber(7)
        matchlength = 2 + self.readfixednumber(2)
        if newindex == 0:
            # extended short
            if matchlength == 2:
                # end of decompression
                return True
            self.__indexbase = self.readfixednumber(matchlength + 1)
        else:
            self.__lastindex = newindex
            try:
                self.copywindow(self.__lastindex, matchlength)
            except:
                return True
        return False

    def do(self):
        """returns decompressed buffer and consumed bytes counter"""
        while True:
            if self.__functions[self.countbits(max=self.__functionsbits, set=0)]():
                break
        return self.out, self.getoffset()


if __name__ == '__main__':
    import test, md5
    test.jcalg_decompress()
