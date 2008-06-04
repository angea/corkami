import lz
import misc


class compress(lz.compress):
    def __init__(self, data, length=None):
        lz.compress.__init__(self, 1)
        self.__in = data
        self.__length = length if length is not None else len(data)
        self.__offset = 0
        return

    def __literal(self, marker=True):
        if marker:
            self.writebit(0)
        self.writebyte(self.__in[self.__offset])
        self.__offset += 1
        return

    def __farwindowblock(self):
        self.writebitstr("10")
        return

    def __shortwindowblock(self, offset, length):
        assert 2 <= length <= 3
        assert 0 < offset <= 127
        self.writebitstr("110")
        b = (offset << 1 ) + (length - 2)
        self.writebyte(b)
        self.__offset += length
        return

    def __windowbyte(self, offset):
        assert 0 <= offset < 16
        self.writebitstr("111")
        self.writefixednumber(offset, 4)
        self.__offset += 1
        return

    def __end(self):
        self.writebitstr("110")
        self.writebyte(chr(0))
        return

    def do(self):
        self.__literal(False)
        while self.__offset < self.__length:
           # print self.__offset, self.__length
            offset, length = misc.searchdict(self.__in[:self.__offset],
                self.__in[self.__offset:])
            if offset == -1:
                c = self.__in[self.__offset]
                if c == "\x00":
                    self.__windowbyte(0)
                else:
                    self.__literal()
            elif 0 < offset <= 127 and 2 <= length <= 3:
                self.__shortwindowblock(offset, length)
            elif 0 <= offset < 16 and length == 1:
                self.__windowbyte(offset)
            else:
                self.__literal()
        self.__end()
        return self.getdata()

class decompress(lz.decompress):
    def __init__(self, data):
        lz.decompress.__init__(self, data, tagsize=1)
        self.__pair = True    # paired sequence
        self.__lastcopyoffset = 0
        self.__functions = [
            self.__literal,
            self.__farwindowblock,
            self.__shortwindowblock,
            self.__windowbyte]
        return

    def __literal(self):
        """copy literally the next byte from the bitstream"""
        self.literal()
        self.__pair = True
        return False

    def __farwindowblock(self):
        """copy a block from the sliding window."""
        b = self.readvariablenumber()    # 2-
        if b == 2 and self.__pair :    # reuse the same offset
            offset = self.__lastoffset
            length = self.readvariablenumber()    # 2-
        else:
            high = b - 2    # 0-
            if self.__pair:
                high -= 1
            offset = (high << 8) + ord(self.readbyte())
            length = self.readvariablenumber()    # 2-
            if offset < 0x80:
                length += 2
            else:
                if offset >= 0x7D00:
                    length += 1
                if offset >= 0x500:
                    length += 1
        self.__lastoffset = offset
        self.dictcopy(offset, length)
        self.__pair = False
        return False

    def __shortwindowblock(self):
        """copy a short block from the sliding window"""
        b = ord(self.readbyte())
        if b <= 1:    # likely 0
            return True
        length = 2 + (b & 0x01)    # 2-3
        offset = b >> 1    # 1-127 (if 0 then return True already)
        self.dictcopy(offset, length)
        self.__lastoffset = offset
        self.__pair = False
        return False

    def __windowbyte(self):
        """copy a single byte from the sliding window, or a null byte"""
        offset = self.readfixednumber(4) # 0-15
        if offset:
            self.dictcopy(offset)
        else:
            self.literal('\x00')
        self.__pair = True
        return False

    def do(self):
        """starts. returns decompressed buffer and consumed bytes counter"""
        self.literal()
        while True:
            if self.__functions[self.countbits(3)]():
                break
        return self.out, self.getoffset()


if __name__ == '__main__':
    import test, md5
    test.aplib_decompress()
    test.aplib_compdec()
