"""Kabopan project, 2008,

written by Ange Albertini - not to be distributed

"""
import lz
import misc

debug = False
class compress(lz.compress):
    def __init__(self, data):
        lz.compress.__init__(self,cmdsize = 2)
        self.data = data
        self.compressed = ""
        self.bzoffset = 0

    def do(self):
        self.writebyte(self.data[self.bzoffset])
        self.bzoffset += 1
        while self.bzoffset < len(self.data):
            foundoff, foundlen = misc.findlongeststring(self.data[:self.bzoffset],
                self.data[self.bzoffset:])
            if foundoff < 1 or foundlen < 4:
                if debug: print "blz: literal {", self.bzoffset, \
                        self.data[self.bzoffset:]
                self.writebit(0)
                self.writebyte(self.data[self.bzoffset])
                self.bzoffset += 1
                if debug: print "}"
            else:
                if debug: print "blz: windowcopy {", foundoff, foundlen
                self.writebit(1)
                self.writevariablenumber(foundlen - 2)
                self.writevariablenumber(((foundoff >> 8) + 2) & 0xFF)
                self.writebyte((foundoff - 1) & 0xFF)
                self.bzoffset += foundlen
                if debug: print "}"
        return self.getdata()


class decompress(lz.decompress):
    def __init__(self, data, length):
        self.data = lz.decompress.__init__(self, data, cmdsize=2)
        self.decompressed = ""

        # brieflz specific
        self.length = length
        self.functions = [
            self.__nextbyte,
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

    def __nextbyte(self):
        """copy literally the next byte from the bitstream"""
        self.decompressed += self.readbyte()
        return False

    def __windowblock(self):
        """
        """
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
