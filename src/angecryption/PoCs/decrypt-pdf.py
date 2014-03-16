from Crypto.Cipher import AES

aes = AES.new("IsAESbrokenYET ?", AES.MODE_CBC, ')\x97\x89\xf9p\xf7\x15\xb9$\xe0TC\xd7\xbc\x10\xab')

with open("poc.pdf", "rb") as f:
	d = f.read()

d = aes.encrypt(d)

with open("angecrypted.pdf", "wb") as f:
	f.write(d)
