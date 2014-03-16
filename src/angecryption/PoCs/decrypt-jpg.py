from Crypto.Cipher import AES

aes = AES.new("tooEASY@miaubiz!", AES.MODE_CBC, 'f\x9d\xcfV\xb09O\x86\xbf\x1e\x9e_]\xbeX\xbe')

with open("poc.jpg", "rb") as f:
	d = f.read()

d = aes.encrypt(d)

with open("angecrypted.jpg", "wb") as f:
	f.write(d)
