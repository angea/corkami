# tiny structure parser engine

# Ange Albertini, BSD Licence, 2011

import struct

class struc():
    def __init__(self, f):
        self.__f = f
        self.__level = 0

    def GetValue(self, s):
        type_, name = s.split(",")
        size = struct.calcsize(type_)
        offset = self.__f.tell()
        data = self.__f.read(size)
        v = struct.unpack(type_, data)[0]
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