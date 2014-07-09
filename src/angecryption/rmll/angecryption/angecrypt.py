#mini-AngeCryption

#Ange Albertini 2014, BSD Licence - with the help of Jean-Philippe Aumasson

import struct
import sys
import binascii

source_file, target_file, result_file, key = "logo11w.png", "duckduckgo.png", "angecrypted.png", "AngeCryptionKey!"

from Crypto.Cipher import AES
BS = 16

pad = lambda s: s if (len(s) % 16) == 0 else s + (16 - len(s) % 16) * "\0"

with open(source_file, "rb") as f:
    s = pad(f.read())

with open(target_file, "rb") as f:
    t = pad(f.read())

p = s[:BS] # our first plaintext block
ecb_dec = AES.new(key, AES.MODE_ECB)


assert BS >= 16
size = len(s) - BS

# our dummy chunk type
# 4 letters, first letter should be lowercase to be ignored
chunktype = 'rmll'

# PNG signature, chunk size, our dummy chunk type
c = PNGSIG = '\x89PNG\r\n\x1a\n' + struct.pack(">I",size) + chunktype

c = ecb_dec.decrypt(c)
IV = "".join([chr(ord(c[i]) ^ ord(p[i])) for i in range(BS)])
cbc_enc = AES.new(key, AES.MODE_CBC, IV)
result = cbc_enc.encrypt(s)

#write the CRC of the remaining of s at the end of our dummy block
result = result + struct.pack(">I", binascii.crc32(result[12:]) % 0x100000000)
#and append the actual data of t, skipping the sig
result = result + t[8:]


#we have our result, key and IV

#generate the result file
cbc_dec = AES.new(key, AES.MODE_CBC, IV)
with open(result_file, "wb") as f:
    f.write(cbc_dec.decrypt(pad(result)))

print " ".join("%02X" % ord(i) for i in IV)
#generate the script
with open("crypt.py", "wb") as f:
    f.write("""from Crypto.Cipher import %(AES)s

AES = %(AES)s.new(%(key)s, %(AES)s.MODE_CBC, %(IV)s)

with open(%(source)s, "rb") as f:
	d = f.read()

d = AES.encrypt(d)

with open("encrypted.png", "wb") as f:
	f.write(d)""" % {
        'AES': AES.__name__.split(".")[-1],
        'key':`key`,
        'IV':`IV`,
        'source':`result_file`,
        'target':`target_file`}
    )