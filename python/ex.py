# a simple file extractor

# TODO:
#  classify or clean
#  PNG TIFF JPG BMP
#  Aplib'ed-EXE
#  xor-ed information 

import os
import sys
import struct
import zlib

def extract(file, data, offset, size, type):
    print "found a %s file @ offset %i, size %i" % (file, offset, size)
    with open("%s-%s(%04x-%i)" % (file, type, offset, offset + size), "wb") as f:
        f.write(data)
    return

for root, dirs, files in os.walk('.'):
    for file_ in files[:]:
        fn = root + '\\' + file_
        print fn
        with open(fn, "rb") as f:
            r = f.read()
        fullsize = len(r)

        # FWS
        off = 1
        MAGIC = "FWS"
        MIN_SIZE = 8
        i = r.find(MAGIC, off)
        while (i > -1):
            if i + MIN_SIZE >= fullsize:
                break
            o2 = i + len(MAGIC)

            version = ord(r[o2])
            if version >= 0x0a:
                break
            o2 += 1

            size_ = struct.unpack("<I", r[o2:o2 + 4])[0]
            o2 += 4

            extract(file_, r[i:i + size_], i, size_ - i, "FWS")

            off = o2
            i = r.find(MAGIC, off)

        # CWS
        off = 1
        MAGIC = "CWS"
        MIN_SIZE = 8

        i = r.find(MAGIC, off)
        while (i > -1):
            if i + MIN_SIZE >= fullsize:
                break
            o2 = i + len(MAGIC)

            version = ord(r[o2])
            if version >= 0x0a:
                break
            o2 += 1

            theosize_ = struct.unpack("<I", r[o2:o2 + 4])[0]
            o2 += 4

            extract(file_, r[i:i + fullsize - i ], i, size_, "CWS") # unknown real size for now

            dec = zlib.decompress(r[o2:])
            decfile = "".join(
                    ["FWS",
                    chr(version),
                    struct.pack("<I", theosize_),
                    dec,
                    ])

            # if len(dec) + 8 != theosize_: Warning "unexpected length"
            extract(file_, decfile, i, size_, "FWS")

            #TODO: compression relation
            off = o2
            i = r.find(MAGIC, off)

        # PE
        off = 1
        MAGIC = "MZ"
        MIN_SIZE = 90
        i = r.find(MAGIC, off)
        while (i > -1):
            if i + MIN_SIZE >= fullsize:
                break
            o2 = i + len(MAGIC)
            
            temp = i + ord(r[i + 0x3c])
            if r[temp:temp + 2] != "PE":
                off = o2
                i = r.find(MAGIC, off)
                continue

            extract(file_, r[i:i + fullsize - i ], i, size_, "PE") # unknown real size for now

            off = o2 # a bigger gap would be better, however it would be possible to 'interlace' 2 PE signatures
            i = r.find(MAGIC, off)

template = """
        off = 1
        MAGIC = "MZ"
        MIN_SIZE = 90
        i = r.find(MAGIC, off)
        while (i > -1):
            if i + MIN_SIZE >= fullsize:
                break
            o2 = i + len(MAGIC)

            off = o2
            i = r.find(MAGIC, off)
            """