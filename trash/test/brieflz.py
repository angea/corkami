import lz
import misc

debug = False


class compress(lz.compress):
    def __init__(self, data, length=None):
        lz.compress.__init__(self, 2)
        self.__in = data
        self.__length = length if length is not None else len(data)
        self.__offset = 0

    def __literal(self):
        self.writebit(0)
        self.writebyte(self.__in[self.__offset])
        self.__offset += 1
        return

    def __dictcopy(self, offset, length):
        assert offset >= 1
        assert length >= 4
        self.writebit(1)
        self.writevariablenumber(length - 2)
        value = offset - 1
        high = ((value >> 8) & 0xFF) + 2    # 2-257
        low = value & 0xFF
        self.writevariablenumber(high)  # 2-
        self.writebyte(chr(low))    # 0-255
        self.__offset += length
        return

    def do(self):
        self.writebyte(self.__in[self.__offset])
        self.__offset += 1
        while self.__offset < self.__length:
            offset, length = misc.searchdict(self.__in[:self.__offset],
                self.__in[self.__offset:])
            if offset >= 1 and length >= 4:
                self.__dictcopy(offset, length)
            else:
                self.__literal()
        return self.getdata()


class decompress(lz.decompress):
    def __init__(self, data, length):
        lz.decompress.__init__(self, data, 2)

        # brieflz specific
        self.length = length
        self.__functions = [
            self.literal,
            self.__dictcopy
            ]
        return

    def __dictcopy(self):
        length = self.readvariablenumber() + 2
        high = self.readvariablenumber() - 2
        low = ord(self.readbyte())
        offset = (high << 8) + low + 1
        self.dictcopy(offset, length)
        return

    def do(self):
        """returns decompressed buffer and consumed bytes counter"""
        self.literal()
        while self.getoffset() < self.length:
            self.__functions[self.countbits(1)]()
        return self.out, self.getoffset()


if __name__ == '__main__':
    import test, md5
    test.brieflz_decompress()
    test.brieflz_compdec()
