from Crypto.Cipher import AES

algo = AES.new('MySecretKey01234', AES.MODE_CBC, '\xbeP\x02\xb6P\xa5\xbd\xa8:\x9e$\xeeP\x1b\x80)')

with open('test.bin', "rb") as f:
        d = f.read()

d = algo.encrypt(d)

with open("dec-" + 'laby.png', "wb") as f:
        f.write(d)
