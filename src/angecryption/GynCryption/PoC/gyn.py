from Crypto.Cipher import AES

with open('gyncryption.jpg', "rb") as f:
	d = f.read()

d = AES.new('GynCrypt\x00\x00\x00\x01\x10\xe8%\xbe', AES.MODE_ECB).encrypt(d)

with open("dec-" + 'gyncrypted.jpg', "wb") as f:
	f.write(d)