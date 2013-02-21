#whitespace-length codec

def enc(fn):
    f = open(fn, "rb")
    r = f.read()
    f.close()

    s = []
    for c in r:
        s += [ " " * (ord(c) + 1)]  # +1 to avoid stupid extra lines by outlook
    w = open(fn + ".enc", "wt")
    w.write("\n".join(s))
    w.close()

def dec(fn):
    f = open(fn, "rt")
    r = f.readlines()
    f.close()

    w = open(fn + ".dec", "wb")

    for c in r:
        if len(c) > 1:
            w.write(chr(len(c) - 2))
    w.close()
