from Crypto.Cipher import DES3, AES

with open('mrmcd.jpg', "rb") as f:
	d = f.read()

da =  AES.new('encryptwithAES!!',  AES.MODE_CBC, '\x1a\xfbK\x8em\xcb\xfd\x8cxT\xce\xcd8 1R').encrypt(d)
dd = DES3.new('decryptwithDES3!', DES3.MODE_CBC,               '\x05\xa4\xfbl\xbb\x9b*\xf0').decrypt(d)

with open("encrypted_aes.png", "wb") as fa:
	fa.write(da)

with open("decrypted_des3.pdf", "wb") as fd:
	fd.write(dd)
    