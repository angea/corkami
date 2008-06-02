import lz


class compress(lz.compress):
    def __init__(self, data):
        lz.compress.__init__(self, 1)
        self.__in = data
        return

    def __literal(self):
        self.writebit(0)
        return
        
    def __farwindowblock(self):
        self.writebitstr("10")
        return

    def __shortwindowblock(self):
        self.writebitstr("110")
        return

    def __windowbyte(self):
        self.writebitstr("1110")
        return

    def do(self):
        self.writebyte(self.__in[0])
        for char in self.__in[1:]:
            self.writebit(0)
            self.writebyte(char)
        self.writebitstr("110")
        self.writebyte(chr(0))
        return self.getdata()

class decompress(lz.decompress):
    def __init__(self, data):
        lz.decompress.__init__(self, data, tagsize=1)
        self.__iscopylast = False
        self.__lastcopyoffset = 0
        self.__functions = [
            self.__literal,
            self.__farwindowblock,
            self.__shortwindowblock,
            self.__windowbyte]

        self.__functionsbits = len(self.__functions) - 1
        return

    def __literal(self):
        """copy literally the next byte from the bitstream"""
        self.copyliteral()
        self.__iscopylast = False
        return False

    def __windowbyte(self):
        """copy a single byte from the sliding window, or a null byte"""
        offset = self.readfixednumber(4)
        if offset:
            self.copywindow(offset)
        else:
            self.out += '\x00'
        self.__iscopylast = False
        return False

    def __shortwindowblock(self):
        """copy a short block from the sliding window

        offset and length are stored on a single byte.
        source block size range is 2-3, offset range is 2-510

        if offset is null, finishes decompression.

        """
        offset = ord(self.readbyte())
        length = 2 + (offset & 0x0001)
        offset >>= 1
        if offset:
            self.copywindow(offset, length)
        else:
            return True
        self.__lastcopyoffset = offset
        self.__iscopylast = True
        return False

    def __farwindowblock(self):
        """copy a block from the sliding window.

        Offset and length are variable-length numbers

        """
        offset = self.readvariablenumber()
        if not self.__iscopylast and offset == 2:
            offset = self.__lastcopyoffset
            length = self.readvariablenumber()
            self.copywindow(offset, length)
        else:
            if not self.__iscopylast:
                offset -= 3
            else:
                offset -= 2
            offset <<= 8
            offset += ord(self.readbyte())
            length = self.readvariablenumber()
            if offset >= 32000:
                length += 1
            if offset >= 1280:
                length += 1
            if offset < 128:
                length += 2
            self.copywindow(offset, length)
            self.__lastcopyoffset = offset
        self.__iscopylast = True
        return False


    def do(self):
        """starts. returns decompressed buffer and consumed bytes counter"""
        self.copyliteral()
        while True:
            if self.__functions[self.countbits(self.__functionsbits)]():
                break
        return self.out, self.getoffset()


if __name__ == '__main__':
    import test, md5
    test.aplib_decompress()
    test.aplib_compdec()
