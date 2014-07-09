from Crypto.Cipher import AES

AES = AES.new('AngeCryptionKey!', AES.MODE_CBC, 'x\xd0\x02\x81k\xa7\xc3\xde\x88\xdeV\x8fjY\x1d\x06')

with open('angecrypted.png', "rb") as f:
	d = f.read()

d = AES.encrypt(d)

with open("encrypted.png", "wb") as f:
	f.write(d)