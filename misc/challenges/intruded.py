#intruded.net IC wargame http://intruded.net/ic/level1.html

IClv1 = """10010110
10010001
10001011
10001101
10001010
10011011
10011010
10011011
11010001
10010001
10011010
10001011
11111111""".splitlines()

string = []
for bits in IClv1:
    byte = 0
    bits = bits.split()[0]
    offset = 1
    for bit in bits.strip()[::-1]:
        byte = byte + (0 if bit == "1" else offset)
        offset *= 2
    string.append(chr(byte))

print "level 1: %s" % "".join(string)