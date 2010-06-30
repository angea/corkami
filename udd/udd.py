# a python module to manage OllyDbg .UDD files
#
# Ange Albertini 2010
# Public domain

__author__ = 'Ange Albertini'
__revision__ = "$LastChangedRevision$"
__version__ = '1.0 r%d' % int(__revision__[21:-2])
__contact__ = 'ange@corkami.com' 

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
    f.write(ct)
    f.write(struct.pack("<I", len(cd)))
    f.write(cd)
    return


def MakeChunk(ct, cd):
    if len(ct) != 4:
        raise Exception("invalid chunk name length")
    if len(cd) > 255:
        raise Exception("invalid chunk data length")

    return [ct, cd]


def MakeRVAInfo(RVA, comment):
    return "%s%s\x00" % (struct.pack("<I", RVA), comment)


def ReadRVAInfo(data):
    RVA, text = struct.unpack("<I", data[:4])[0], data[4:].strip("\x00")
    return RVA, text


def MakeCommentChunk(RVA, comment):
    return MakeChunk(CHUNK_TYPES["USERCOMMENT"], MakeRVAInfo(RVA, comment))


def MakeLabelChunk(RVA, comment):
    return MakeChunk(CHUNK_TYPES["LABEL"], MakeRVAInfo(RVA, comment))


def MakeDDInfo(dd):
    return struct.pack("<I", dd)


def ReadDDInfo(data):
    return struct.unpack("<I", data)[0]


class Udd(object):

    def __init__(self, filename=None):
        self.__data = {}
        self.__chunks = []
        self.__format = None
        if filename is not None:
            self.Load(filename)
        return

    def Load(self, filename):
        try:
            f = open(filename, "rb")
            ct, cd =  ReadNextChunk(f)

            if not (ct == CHUNK_TYPES["HEADER"] and
                cd in [
                    "Module info file v1.1\x00",
                    "Module info file v2.0\x00"]):
                raise Exception("Invalid HEADER chunk")
            self.__chunks.append([ct, cd])
            self.__format = 1 if cd == "Module info file v1.1\x00" else 2
            while (True):
                ct, cd = ReadNextChunk(f)
                if ct not in CHUNK_TYPES:
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
