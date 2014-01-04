#stupid reverse parser to check validity

fn = 'simple.wav'
with open(fn, 'rb') as f:
	r = f.read()
r = r[0x2c:]
r = r.replace("\x80\xD9\xFF\xD9\x80\x26\x01\x26" * 80, "\xdb")
r = r.replace("\x80\x80\x80\x80\x80\x80\x80\x80" * 80, " ")
print r
