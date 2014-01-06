#stupid reverse parser to check validity
TONE = "\x80\xD9\xFF\xD9\x80\x26\x01\x26" * 80
SILENCE = "\x80\x80\x80\x80\x80\x80\x80\x80" * 80

fn = 'simple.wav'
with open(fn, 'rb') as f:
	r = f.read()
s = r[0x2c:]
s = s.replace(TONE, "\xdb")
s = s.replace(SILENCE, " ")
print s

