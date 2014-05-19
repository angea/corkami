#Gyn(vael)Cryption
#generating a valid file via bruteforcing + ECB mode
#as suggested by Gynvael Coldwind

#Ange Albertini 2014, BSD Licence

from Crypto.Cipher import AES

JPGSIG = "\xff\xd8"

source_file, target_file, result_file = "gynvael.jpg", "gyncrypted.jpg", "gyncryption.jpg"

BS = 16
pad = lambda s: s + (BS - len(s) % BS) * chr(BS - len(s) % BS)

with open(source_file, "rb") as f:
    s = pad(f.read())

with open(target_file, "rb") as f:
    t = pad(f.read())


def brute():
    import struct
    import atexit
    import marshal
    p = s[:BS]
    c = t[:BS]
    try:
        with open("key", "rb") as f:
            i = marshal.load(f)
    except:
        i = 0
    print "starting at key %x" % i


    @atexit.register
    def hook():
        print("last counter 0x%x" % i)
        with open("key", "wb") as f:
            marshal.dump(i,f)

    while (1):
        key = "GynCrypt" + struct.pack(">Q", i)
        i += 1
        c = AES.new(key, AES.MODE_ECB).encrypt(p)
        if c.startswith(JPGSIG + "\xFF\xFE"):
            print `key`, `c`
            
#brute() # last iteration 0x2afb56fcd

key = 'GynCrypt\x00\x00\x00\x01\x10\xe8%\xbe'

# will our P1 as "\xff\xd8\xff\xfe\\\x9c\xc33\xe8/X'r\r7\xd9"
offset = 0x5c9c 

result = AES.new(key, AES.MODE_ECB).encrypt(s)

result = result + "\0" * (offset - len(result) + 4)

result = result + t[2:] # skipping the sig
result = pad(result)

result = AES.new(key, AES.MODE_ECB).decrypt(result)

with open(result_file, "wb") as f:
    f.write(result)

with open("gyn.py", "wb") as f:
    f.write("""from Crypto.Cipher import %(AES)s

with open(%(source)s, "rb") as f:
	d = f.read()

d = AES.new(%(key)s, AES.MODE_ECB).encrypt(d)

with open("dec-" + %(target)s, "wb") as f:
	f.write(d)""" % {
        'AES': AES.__name__.split(".")[-1],
        'key':`key`,
        'source':`result_file`,
        'target':`target_file`}
    )