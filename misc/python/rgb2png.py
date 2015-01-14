# a (minimal) python script to make a (24BPP) PNG out of RGB data
# only with standard dependencies

# Ange Albertini BSD Licence 2015

import struct, sys, zlib, binascii

DEPTH8 = 8
MODE_TRUECOLOR = 2
COMPRESSION_DEFLATE = 0
NO_FILTER = 0
NO_INTERLACING = 0

rawfilename, width, height = sys.argv[1:4]
width, height = int(width), int(height)

with open(rawfilename, "rb") as source:
    rawdata = source.read()

image_data = []
for i in range(0, len(rawdata), width * 3):
    # each line starts with an extra filter byte, that we don't use here
    image_data.append("\0")
    image_data.append(rawdata[i:i+width * 3])

#chunks [type (4 letters), chunk data]
chunks = [
    ["IHDR", struct.pack(">IIBBBBB",
        width, height,
        DEPTH8, MODE_TRUECOLOR, COMPRESSION_DEFLATE, NO_FILTER, NO_INTERLACING
        )],
    #the Image Data chunk is just Zlib-ed filter+pixels lines
    ["IDAT", zlib.compress("".join(image_data), 9)],
    ["IEND", ""]
]

with open("%s.png" % rawfilename, "wb") as target:
    # the magic sig
    target.write("\x89PNG\x0d\x0a\x1a\x0a")

    # a sequence of chunk
    for type, data in chunks:

        target.write("".join([
            # Length, Type, Data, CRC32
            struct.pack(">I", len(data)),
            type,
            data,
            struct.pack(">I", binascii.crc32(type + data) & 0xffffffff)
            ]))
