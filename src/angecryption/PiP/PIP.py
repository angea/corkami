#PNG in PNG

#an AngeCryption script that works from PNG to PNG,
#(appends the decrypted target data as PNG level, not file level)

# it decrypts just to prove it also works the other way ;)

# lazy version:
# - only works with [IHDR;IDAT;IEND] PNG

#Ange Albertini 2014, BSD Licence

import struct
import sys
#import os
import binascii

PNGSIG = '\x89PNG\r\n\x1a\n'

# our source file will decrypts as our target file
source_file, target_file, result_file, key = sys.argv[1:6]

from Crypto.Cipher import AES
BS = 16

#pad = lambda s: s + os.urandom(BS - len(s) % BS) # non standard, but better looking ;)
pad = lambda n: "\0" * ((BS - n % BS) % BS) # non standard, but better looking ;)

with open(source_file, "rb") as f:
    s = f.read()

assert s.startswith(PNGSIG)

with open(target_file, "rb") as f:
    t = f.read()

assert t.startswith(PNGSIG)

#we'll first decrypt the source image until the end of its image data

result = s[:-12]

# our dummy chunk type
chunktype = 'aaAa' # 4 letters, first letter should be lowercase to be ignored

n=4+len(t[8:])+len(pad(4+len(t[8:])))
result += struct.pack(">I",len(pad(len(result)+8))+n)
result += chunktype

# we pad that to be able to append 'decrypted' target's content
result += pad(len(result))

# this is the size of info we need to hide in our dummy block
#size = len(s[:-16]) -4
size = len(result) -0x10 + len(pad(4+len(t[8:])))

c = s[:BS] # our first cipher block

# PNG signature, chunk size, our dummy chunk type
p = PNGSIG + struct.pack(">I",size) + chunktype

#let's generate our IV
c = AES.new(key, AES.MODE_ECB).decrypt(c)
IV = "".join([chr(ord(c[i]) ^ ord(p[i])) for i in range(BS)])

result = AES.new(key, AES.MODE_CBC, IV).decrypt(result)

result += pad(4+len(t[8:]))
#not fixing the CRC on the decrypted file - lazy :D
result += struct.pack(">I", binascii.crc32(result[0xc:]) % 0x100000000)
#we append the whole target image
result += t[8:]

result += pad(len(result))

result = AES.new(key, AES.MODE_CBC, IV).encrypt(result)
#write the CRC of the remaining of s at the end of our dummy block

result += struct.pack(">I", binascii.crc32(result[len(s)-8:]) % 0x100000000)
result += s[-12:] # our IEND chunk

#we have our result, key and IV

#generate the result file
with open(result_file, "wb") as f:
    f.write(result)

#generate the script
with open("decrypt-PIP.py", "wb") as f:
    f.write("""from Crypto.Cipher import AES

with open(%(source)s, "rb") as f:
	d = f.read()

d = AES.new(%(key)s, AES.MODE_CBC, %(IV)s).decrypt(d)

with open("dec-" + "%(target)s", "wb") as f:
	f.write(d)""" % {
        'key':`key`,
        'IV':`IV`,
        'source':`result_file`,
        'target':target_file.split("\\")[-1]})
