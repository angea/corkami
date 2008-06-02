import lz
import misc

debug = False


class compress(lz.compress):
    def __init__(self, data, length = 0):
        lz.compress.__init__(self, 2)
        self.__in = data
        self.__length = length if length != 0 else len(data)
        self.__offset = 0

    def __literal(self):
        self.writebit(0)
        self.writebyte(self.__in[self.__offset])
        self.__offset += 1
        return

    def __windowblock(self, offset, length):
        assert offset >= 1
        assert length >= 4
        self.writebit(1)
        self.writevariablenumber(length - 2)
        offset -= 1
        high = ((offset >> 8) + 2) & 0xFF
        low = offset & 0xFF
        self.writevariablenumber(high)
        self.writebyte(chr(low))
        self.__offset += length
        return

    def do(self):
        self.writebyte(self.__in[self.__offset])
        self.__offset += 1
        while self.__offset < self.__length:
            offset, length = misc.findlongeststring(self.__in[:self.__offset],
                self.__in[self.__offset:])
            if offset >= 1 and length >= 4:
                self.__windowblock(offset, length)
            else:
                self.__literal()
        return self.getdata()


class decompress(lz.decompress):
    def __init__(self, data, length):
        lz.decompress.__init__(self, data, 2)

        # brieflz specific
        self.length = length
        self.__functions = [
            self.copyliteral,
            self.__windowblock
            ]

        self.__functionsbits = len(self.__functions) - 1
        return

    def __windowblock(self):
        length = self.readvariablenumber() + 2
        high = self.readvariablenumber() - 2
        low = ord(self.readbyte())
        offset = (high << 8) + low + 1
        if debug:print "block read",offset, length
        try:
            self.copywindow(offset, length)
        except:
            print "error windowblock"
            return True
        return False

    def do(self):
        """returns decompressed buffer and consumed bytes counter"""
        self.copyliteral()
        while self.getoffset() < self.length:
            if self.__functions[self.countbits(self.__functionsbits)]():
                print "error"
                break

        return self.out, self.getoffset()



if __name__ == '__main__':
    import test, md5
    test.brieflz_decompress()
    test.brieflz_compdec()
