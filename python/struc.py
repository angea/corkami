# tiny structure parser engine

# Ange Albertini, BSD Licence, 2011

import struct

class struc():
    def __init__(self, f):
        self.__f = f
        # _level should be understood by the structures themselves
        self.__level = 0

    def GetValue(self, s):
        type_, name = s.split(",")
        size = struct.calcsize(type_)
        offset = self.__f.tell()
        data = self.__f.read(size)
        v = struct.unpack(type_, data)[0]
        # printing shouldn't be here
        print "%04X:(+%i) %s%s: %x" % (offset, size, " " * self.__level, name, v)
        return v

    def handle(self, typact):
        type_, action = typact
        v = self.GetValue(type_)
        if action is not None:
            action(v)
        return v

    def handles(self, l):
        for i in l:
            self.handle(i)

    def setoffset(self, v):
        self.__f.seek(v)

    def levelup(self):
        self.__level += 1

    def leveldown(self):
        self.__level -= 1

class el():
    def __init__(self, ):
        self.__offset = 0
        self.__size = 0
        self.__name = 0
        self.__value = 0
        self.__parent = 0
        self.__level = 0
        self.__children = list()

    def read(self, f):
        pass

    def setparent(self, p):
        self.__parent = p

    def setlevel(self, p):
        self.__level = p

    def add(self, c):
        self.__children(append(c))
        c.setparent(self)
        c.setlevel(self.__level + 1)

    def info(self, ):
        return "0x%08x:(+%i) %s%s: " % (offset, size, " " * self.__level, name)

class hexbyte(el):
    def __init__(self, ):
        self.__size = 1

    def __repr__(self):
        return "0x%02x" % self.__value


class hexword(el):
    def __init__(self, ):
        self.__size = 2

    def __repr__(self):
        return "0x%04x" % self.__value


class hexdword(el):
    def __init__(self, ):
        self.__size = 4

    def __repr__(self):
        return "0x%08x" % self.__value

class datafile():
    """a class that make a string being used like a file"""
    def __init__(self, d):
        self.__data = d
        self.__offset = 0

    def tell(self):
        return self.__offset

    def seek(self, offset):
        # todo: add position parameter
        self.offset = offset

    def read(self, nb):
        d = self.__data[offset: offset + nb + 1]
        self.__offset += nb
        return d
