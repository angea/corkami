import sys, zlib, os
from Crypto.Cipher import AES
import png

with open("logo11w.png", "rb") as f:
    c = png.read(f)

#a PNG with appended data
contents = png.make(c) + os.urandom(64 * 1024)
with open("appendeddata.png", "wb") as f:
    f.write(contents)

#a PNG with a standard text chunk
c1 = list(c)
c1.insert(1, ["tEXt", "sans commentaire!"])

with open("text-chunk.png", "wb") as f:
    f.write(png.make(c1))

#a PNG with a custom chunk
c2 = list(c)
c2.insert(1, ["bing", "extra chunk"])

with open("custom-chunk.png", "wb") as f:
    f.write(png.make(c2))

#a PNG with a custom chunk FIRST
c2 = list(c)
c2.insert(0, ["brin", "Do no evil, Sergey ;)"])

with open("custom-first.png", "wb") as f:
    f.write(png.make(c2))

#a PNG with uncompressed image data
c2 = list(c)
assert c2[1][0] == "IDAT"
original_data = c2[1][1]
c2[1][1] = zlib.compress(zlib.decompress(original_data), 0)

with open("uncompressed.png", "wb") as f:
    f.write(png.make(c2))

#making a PNG with split image data
c3 = list(c)
del c3[1]
data1, data2 = original_data[:len(original_data) / 2], original_data[len(original_data) / 2:]
c3.insert(1, ["IDAT", data1])
c3.insert(2, ["IDAT", data2])

with open("splitdata.png", "wb") as f:
    f.write(png.make(c3))

with open("logo11w.raw", "rb") as f:
    raw = f.read()
raw += "\0" * (16 - (len(raw) % 16))
with open("crypted.raw", "wb") as f:
    f.write(AES.new("MySecretKey12345", AES.MODE_ECB).encrypt(raw))

with open("google-cbc.raw", "wb") as f:
    f.write(AES.new("MySecretKey12345", AES.MODE_CBC, "\0" * 16).encrypt(raw))

with open("duckduckgo.raw", "rb") as f:
    raw = f.read()
raw += "\0" * (16 - (len(raw) % 16))

with open("ddg-cbc.raw", "wb") as f:
    f.write(AES.new("MySecretKey12345", AES.MODE_CBC, "\0" * 16).encrypt(raw))

with open("logo11w.png", "rb") as f:
    c = png.read(f)
c.insert(1, ["true", "\0" * (299008 - 0x29)]) # 299008 = size of TC container
with open("truecrypt-holder.png", "wb") as f:
    f.write(png.make(c))
