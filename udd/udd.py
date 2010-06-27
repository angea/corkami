# Ange Albertini 2010
# Public domain

import struct

def ReadNextChunk(f):
    cn = f.read(4)
    size = struct.unpack("<I", f.read(4))[0]
    cd = f.read(size)
    return cn, cd

def WriteChunk(f, cn, cd):
    f.write(cn + struct.pack("<I", len(cd)) + cd)
    return

class Udd():
    def __init__(self, filename = None):
        self.__data = {}
        self.__chunks = []
        if filename is not None:
            self.load(filename)
        return

    def load(self, filename):
        try:
            f = open(filename, "rb")
            cn, cd =  ReadNextChunk(f)

            if (cn,cd) != ("Mod\x00",  "Module info file v1.1\x00"):
                raise Exception("Invalid Mod chunk")
            self.__chunks.append([cn, cd])
            while (True):
                cn, cd = ReadNextChunk(f)

                if (cn, cd) == ("\x0aEnd", ""):
                    self.__chunks.append([cn, cd])
                    break

                elif cn == "\x0aFil":
                    self.__data["FileName"] = cd

                elif cn == "\x0aVer":
                    if len(cd) != 4 * 4:
                        raise Exception("Invalid Version chunk length - expected 16")
                    # repr = "%i.%i.%i.%i" % struct.unpack("<4I", cd)
                    self.__data["version"] = cd

                elif cn == "\x0aSiz":
                    if len(cd) != 4:
                        raise Exception("Invalid filesize chunk length - expected 4")
                    # repr = struct.unpack("<I", cd)[0]
                    self.__data["filesize"] = cd

                elif cn == "\x0aCcr":
                    if len(cd) != 4:
                        raise Exception("Invalid Ccr chunk length - expected 4")
                    # repr = struct.unpack("<I", cd)[0]
                    self.__data["crc"] = cd

                elif cn == "\x0aTst":
                    if len(cd) != 8:
                        raise Exception("Invalid Timestamp chunk length - expected 8")

                    self.__data["timestamp"] = cd

                elif cn == "\x0aUs6":   # comment
                    print struct.unpack("<I", cd[:4])[0], cd[4:]
                    pass

                elif cn == "\x0aUs1":   # label
                    print struct.unpack("<I", cd[:4])[0], cd[4:]
                    pass

                elif cn.startswith("\x0aUs"): # other user stuff
                    pass

                elif cn in [
                    "\x0aAnc", "\x0aCfa", "\x0aCfm", "\x0aJdt",
                    "\x0aPat", "\x0aCml", "\x0aSwi", "\x0aCfi",
                    "\x0aPrc", "\x0aHbr", "\x0aBpc", "\x0aSva"]:
                    pass
                else:
                    raise Exception("Unknown chunk name: %s" % cn)

                self.__chunks.append([cn, cd])

        finally:
            f.close()

    def AppendChunk(self, name, data):
        self.__chunks.insert(-2, [name, data])

    def save(self, filename):
        f = open(filename, "wb")
        for cn, cd in self.__chunks:
            WriteChunk(f, cn, cd)
        f.close()

if __name__ == "__main__":
    import sys, glob
    for fn in glob.glob(sys.argv[1]):
        u = Udd(fn)
        u.save(fn + 'goin')