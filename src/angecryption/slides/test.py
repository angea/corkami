from Crypto.Cipher import AES

print "multiple encryption"
l = [
    ["MySecretKey12345", "a block of text."],
    ["MySecretKey12346", "a block of text."],
    ["MySecretKey12345", "a block of text!"],
    ]
h = lambda s: " ".join("%02X" % ord(c) for c in s)
for k, p in l:
    print `k`
    print `p`
    print ((AES.new(k, AES.MODE_ECB).encrypt(p)))
    print


print "encryption then decryption"

k, p = "MySecretKey12345", "a block of text."
c = AES.new(k, AES.MODE_ECB).encrypt(p)
print c
print h(c)

p = AES.new(k, AES.MODE_ECB).decrypt(c)
print "with key %s"% k, 
print p

k = "MySecretKey12346"
p = AES.new(k, AES.MODE_ECB).decrypt(c)
print "with key %s"% k, 
print p

print "decrypting a plaintext"
    
k, p = "MySecretKey12345", "a block of text."
c = AES.new(k, AES.MODE_ECB).decrypt(p)
print c

print AES.new(k, AES.MODE_ECB).encrypt(c)
