import lz
import misc

debug = False


class compress(lz.compress):
    def __init__(self, data):
        lz.compress.__init__(self, 2)
        self.data = data
        self.compressed = ""
        self.bzoffset = 0

    def __literal(self, foundoff, foundlen):
        if debug: print "blz: literal {", self.bzoffset, \
            self.data[self.bzoffset:]
        self.writebit(0)
        self.writebyte(self.data[self.bzoffset])
        self.bzoffset += 1
        if debug: print "}"
        return

    def __windowblock(self, foundoff, foundlen):
        if debug: print "blz: windowcopy {", foundoff, foundlen
        self.writebit(1)
        self.writevariablenumber(foundlen - 2)
        self.writevariablenumber(((foundoff >> 8) + 2) & 0xFF)
        self.writebyte((foundoff - 1) & 0xFF)
        self.bzoffset += foundlen
        if debug: print "}"
        return

    def __determine(self, foundoff, foundlen):
        """returns the correct encoding function based on the entry found"""
        if foundoff >= 1 or foundlen >= 3:
            return self.__windowblock
        return self.__literal

    def do(self):
        self.writebyte(self.data[self.bzoffset])
        self.bzoffset += 1
        while self.bzoffset < len(self.data):
            foundoff, foundlen = misc.findlongeststring(self.data[:self.bzoffset],
                self.data[self.bzoffset:])
            self.__determine(foundoff, foundlen)(foundoff, foundlen)
        return self.getdata()


class decompress(lz.decompress):
    def __init__(self, data, length):
        self.data = lz.decompress.__init__(self, data, 2)
        self.decompressed = ""

        # brieflz specific
        self.length = length
        self.functions = [
            self.__literal,
            self.__windowblock
            ]

        self.functionsbits = len(self.functions) - 1
        return

    def do(self):
        """returns decompressed buffer and consumed bytes counter"""
        self.decompressed += self.readbyte()
        while self.offset < self.length:
            if self.functions[self.countbits(self.functionsbits)]():
                print "error"
                break

        return self.decompressed, self.offset

    def __literal(self):
        """copy literally the next byte from the bitstream"""
        self.decompressed += self.readbyte()
        return False

    def __windowblock(self):
        length = self.readvariablenumber() + 2
        offset = self.readvariablenumber() - 2
        offset = (offset << 8) + ord(self.readbyte()) + 1
        if debug:print "block read",offset, length
        try:
            self.windowblockcopy(offset, length)
        except:
            print
            print "error windowblock"
            return True
        return False


if __name__ == '__main__':
    import test
    test.brieflz_decompress()
    test.brieflz_compdec()