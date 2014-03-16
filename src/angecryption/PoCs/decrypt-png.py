from Crypto.Cipher import AES

aes = AES.new("stillNOTbroken ?", AES.MODE_CBC, 'K\x81\xac*<~.\xdc\xadk\x12\xd7\x10\xdd@\xfb')

with open("poc.png", "rb") as f:
	d = f.read()

d = aes.encrypt(d)

with open("angecrypted.png", "wb") as f:
	f.write(d)
