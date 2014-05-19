from Crypto.Cipher import AES

with open('PIP.png', "rb") as f:
	d = f.read()

d = d + "\0" * (16 - len(d) % 16)

d = AES.new('PNGviaAESinPNG!!', AES.MODE_CBC, '\xa4\xe3\xe5Jm\xe9Up}q\xb5\xdb\xabi\xd9\x1e').decrypt(d)

with open("dec-" + "bearodactyl.png", "wb") as f:
	f.write(d)