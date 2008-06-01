"""Kabopan project, 2008,

written by Ange Albertini - not to be distributed

"""
import lz

class decompress(lz.decompress):
    """aplib decompression class. inherits bitstream"""
    def __init__(self, data):
        self.data = lz.decompress.__init__(self, data, cmdsize=1)
        self.decompressed = ""

        # aplib specific
        self.iscopylast = False
        self.lastcopyoffset = 0
        self.functions = [
            self.__nextbyte,
            self.__farwindowblock,
            self.__shortwindowblock,
            self.__windowbyte]

        self.functionsbits = len(self.functions) - 1
        return

    def __nextbyte(self):
        """copy literally the next byte from the bitstream"""
        self.decompressed += self.readbyte()
        self.iscopylast = False
        return False

    def do(self):
        """starts. returns decompressed buffer and consumed bytes counter"""
        self.decompressed += self.readbyte()
        while True:
            if self.functions[self.countbits(self.functionsbits)]():
                break
        return self.decompressed, self.offset

    def __windowbyte(self):
        """copy a single byte from the sliding window, or a null byte"""
        offset = self.readfixednumber(4)
        if offset:
            self.decompressed += self.decompressed[-offset]
        else:
            self.decompressed += '\x00'
        self.iscopylast = False
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
            self.windowblockcopy(offset, length)
        else:
            return True
        self.lastcopyoffset = offset
        self.iscopylast = True
        return False

    def __farwindowblock(self):
        """copy a block from the sliding window.

        Offset and length are variable-length numbers

        """
        offset = self.readvariablenumber()
        if not self.iscopylast and offset == 2:
            offset = self.lastcopyoffset
            length = self.readvariablenumber()
            self.windowblockcopy(offset, length)
        else:
            if not self.iscopylast:
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
            self.windowblockcopy(offset, length)
            self.lastcopyoffset = offset
        self.iscopylast = True
        return False
