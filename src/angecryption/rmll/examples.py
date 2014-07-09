from Crypto.Cipher import AES

def prnt(m):
    print m
    print " ".join("%02X" % ord(i) for i in m)

for key, block in [
    ["MySecretKey12345", "a block of text."],
    ["MySecretKey12346", "a block of text."],
    ["MySecretKey12345", "a block of text!"],
    ["\x89PNG\r\n\x1a\n\0\0\0\x0dIHDR", "a block of text!"]
    ]:
    prnt(AES.new(key, AES.MODE_ECB).encrypt(block))
print


#decryptions
c = AES.new("MySecretKey12345", AES.MODE_ECB).encrypt("a block of text.")

for key in [
    "MySecretKey12345",
    "MySecretKey12346",
    ]:
    prnt(AES.new(key, AES.MODE_ECB).decrypt(c))
print


#plaintext decryption
key = "MySecretKey12345"
p1 = AES.new(key, AES.MODE_ECB).decrypt("a block of text.")
prnt(p1)
prnt(AES.new(key, AES.MODE_ECB).encrypt(p1))
print


#IV manipulation
key = "IVManipulation!!"
p1 = "\x89PNG\r\n\x1a\n\0\0\0\x0dIHDR"
c1 = "\x89PNG\r\n\x1a\n\0\0\0\x0dIHDR"
dec_c1 = AES.new(key, AES.MODE_ECB).decrypt(c1)
iv = []
for i, p in enumerate(list(p1)):
    c = dec_c1[i]
    iv.append(chr(ord(c) ^ ord(p)))
iv = "".join(iv)

print "IV:", 
prnt(iv)
prnt(AES.new(key, AES.MODE_CBC, iv).encrypt(p1))
prnt(c1)