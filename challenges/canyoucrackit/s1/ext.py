import base64

with open("cyber.png", "rb") as f:
	r = base64.b64decode(f.read()[0x6a:0xbb])
with open("enc.rc4", "wb") as f:
    f.write(r)