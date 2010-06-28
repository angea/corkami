# a python script to manage OllyDbg .UDD files
#
# Ange Albertini 2010
# Public domain

import struct

chunk_types = [
        ("HEADER",      "Mod\x00"),
        ("END",         "\nEnd"),
        ("FILENAME",    "\nFil"),
        ("VERSION",     "\nVer"),
        ("SIZE",        "\nSiz"),
        ("TIMESTAMP",   "\nTst"),
        ("CRC",         "\nCcr"),
        ("PATCH",       "\nPat"),
        ("BP",          "\nBpc"),
        ("HWBP",        "\nHbr"),
        ("SAVE",        "\nSva"),


        ("LABEL",       "\nUs1"),
        ("EXPORT",      "\nUs2"),
        ("IMPORT",      "\nUs3"),
        ("LIBRARY",     "\nUs4"),
        ("USERCOMMENT", "\nUs6"),
        ("ARG",         "\nUs9"),
        ("INSPECT",     "\nUs@"),
        ("WATCH",       "\nUsA"),
        ("ASM",         "\nUsB"),
        ("FIND",        "\nUsC"),


        ("USh",         "\nUsH"), #?
        ("US;",         "\nUs;"), #?
        ("USq",         "\nUsq"), #?
        ("USv",         "\nUsv"), #?
        ("US=",         "\nUs="), #?
        ("ANC",         "\nAnc"), #?

        ("CFA",         "\nCfa"), #?
        ("CFM",         "\nCfm"), #?
        ("CFI",         "\nCfi"), #?
        ("CML",         "\nCml"), #?
        ("JDT",         "\nJdt"), #?
        ("SWI",         "\nSwi"), #?
        ("PRC",         "\nPrc"), #?

        #OllyDbg 2
        ("FCR",         "\nFcr"), #?
        ("NAME",        "\nNam"), #?
        ("DATA",        "\nDat"), #?
        ("CBR",         "\nCbr"), #?
        ("LBR",         "\nLbr"), #?
        ("ANA",         "\nAna"), #?
        ("CAS",         "\nCas"), #?
        ("MBA",         "\nMba"), #?
        ("PRD",         "\nPrd"), #?
        ("SAV",         "\nSav"), #?
        ("RTC",         "\nRtc"), #?
        ("RTP",         "\nRtp"), #?

       ]

CHUNK_TYPES = dict([(e[1], e[0]) for e in chunk_types] + chunk_types)

RVAINFO_TYPES = [CHUNK_TYPES[e] for e in "LABEL", "USERCOMMENT"]


def ReadNextChunk(f):
    ct = f.read(4)
    size = struct.unpack("<I", f.read(4))[0]
    cd = f.read(size)

    return ct, cd


def WriteChunk(f, ct, cd):
    f.write(ct + struct.pack("<I", len(cd)) + cd)

    return


def MakeChunk(ct, cd):
    if len(ct) != 4:
        raise Exception("invalid chunk name length")
    if len(cd) > 255:
        raise Exception("invalid chunk data length")

    return [ct, cd]


def MakeRVAInfo(RVA, comment):
    return struct.pack("<I", RVA) + comment + "\x00"


def ReadRVAInfo(data):
    return struct.unpack("<I", data[:4])[0], data[4:].strip("\x00")


def MakeCommentChunk(RVA, comment):
    return MakeChunk(CHUNK_TYPES["USERCOMMENT"], MakeRVAInfo(RVA, comment))


def MakeLabelChunk(RVA, comment):
    return MakeChunk(CHUNK_TYPES["LABEL"], MakeRVAInfo(RVA, comment))


def MakeDDInfo(dd):
    return struct.pack("<I", dd)


def ReadDDInfo(data):
    return struct.unpack("<I", data)[0]


class Udd():

    def __init__(self, filename = None):
        self.__data = {}
        self.__chunks = []
        if filename is not None:
            self.load(filename)
        return

    def Load(self, filename):
        try:
            f = open(filename, "rb")
            ct, cd =  ReadNextChunk(f)

#            if (ct,cd) != (CHUNK_TYPES["HEADER"],  "Module info file v1.1\x00"):
#                raise Exception("Invalid Mod chunk")
            self.__chunks.append([ct, cd])
            while (True):
                ct, cd = ReadNextChunk(f)
                if ct not in CHUNK_TYPES:
#                if (ct, cd) == (CHUNK_TYPES["END"] , ""):
#                    self.__chunks.append([ct, cd])
#                    break
#
#                elif ct == CHUNK_TYPES["FILENAME"]:
#                    self.__data["FileName"] = cd
#
#                elif ct == CHUNK_TYPES["VERSION"]:
#                    if len(cd) != 4 * 4:
#                        raise Exception("Invalid Version chunk length - expected 16")
#                    # repr = "%i.%i.%i.%i" % struct.unpack("<4I", cd)
#                    self.__data["version"] = cd
#
#                elif ct == CHUNK_TYPES["SIZE"]:
#                    if len(cd) != 4:
#                        raise Exception("Invalid filesize chunk length - expected 4")
#                    # repr = struct.unpack("<I", cd)[0]
#                    self.__data["filesize"] = cd
#
#                elif ct == CHUNK_TYPES["CRC"]:
#                    if len(cd) != 4:
#                        raise Exception("Invalid Ccr chunk length - expected 4")
#                    # repr = struct.unpack("<I", cd)[0]
#                    self.__data["crc"] = cd
#
#                elif ct == CHUNK_TYPES["TIMESTAMP"]:
#                    if len(cd) != 8:
#                        raise Exception("Invalid Timestamp chunk length - expected 8")
#
#                    self.__data["timestamp"] = cd
#
#                elif ct == "\nUs6":   # comment
#                    pass
#
#                elif ct == "\nUs1":   # label
#                    pass
#
#                elif ct.startswith("\nUs"): # other user stuff
#                    pass
#
#                elif ct in [
#                    "\nAnc", "\nCfa", "\nCfm", "\nJdt",
#                    "\nPat", "\nCml", "\nSwi", "\nCfi",
#                    "\nPrc", "\nHbr", "\nBpc", "\nSva"]:
#                    pass
#                else:
                    raise Exception("Unknown chunk name: %s" % ct)

                self.__chunks.append([ct, cd])
                if (ct, cd) == (CHUNK_TYPES["END"] , ""):
                    break

        finally:
            f.close()
        return

    def Save(self, filename):
        f = open(filename, "wb")
        for ct, cd in self.__chunks:
            WriteChunk(f, ct, cd)
        f.close()
        return


    def SetChunk(self, pos, chunk):
        self.__chunks[pos] = chunk
        return


    def GetChunk(self, pos):
        return self.__chunks[pos]


    def AppendChunk(self, chunk):
        if not self.Find(chunk):
            self.__chunks.insert(-1, chunk)
        return


    def FindByType(self, type):
        found = []

        for i, c in enumerate(self.__chunks):
            if c[0] == type:
                found += i

        return found


    def FindByTypes(self, types):
        found = []

        for i, c in enumerate(self.__chunks):
            if c[0] in types:
                found += [i]

        return found


    def Find(self, chunk):
        found = []

        for i, c in enumerate(self.__chunks):
            if c == chunk:
                found += [i]

        return found if len(found) > 0 else None


    def FindByRVA(self, RVA):
        found = self.FindByTypes(RVAINFO_TYPES)

        result = []
        for i in found:
            foundRVA, data = ReadRVAInfo(self.__chunks[i][1])
            if foundRVA == RVA:
                type = CHUNK_TYPES[self.__chunks[i][0]]
                result += type, data

        return result


# Examples
#

#def ExportLabelsComments(udd):
#    import sys
#
#    found = self.FindByTypes(RVAINFO_TYPES)

if __name__ == "__main__":
    import sys, glob
    u = Udd()
    for fn in glob.glob(sys.argv[1]):
        u.Load(fn)
        print u.FindByRVA(0x162)
        u.AppendChunk(MakeLabelChunk(0x162, "label"))
        u.Save(fn)