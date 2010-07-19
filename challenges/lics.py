"""Little Interactive Cryptogram Solving tool

Ange Albertini, 2010, public domain"""

import sys

from operator import itemgetter


def getCryptogram():
    """return the text content of the file in the 1st argument"""
    f = open(sys.argv[1], "rt")
    s = f.read()
    f.close()
    return s

def getFrequencies(s):
    """return a dictionary of unique letters in s and their frequency"""
    d = {}
    for i in set(list(s)):
        d[i] = 0
    for i in s:
        d[i] += 1
    return d


def findall(s, c):
    """yields all indexes where 'c' is found in 's'"""
    count_ = s.count(c)
    if not count_:
        return
    p = 0
    for _ in xrange(count_):
        p = s.find(c, p) + 1
        yield p - 1


def swap(s, srcs, tgts):
    """generates a list made of underscore and swapped letters"""
    res = ["_"] * len(s)
    for i in xrange(len(srcs)):
        src, tgt = srcs[i], tgts[i]
        for j in findall(s, src):
            res[j] = tgt
    return "".join(res)


def printp(str1,str2):
    """print in parallel 2 strings under each other"""
    len_ = max((len(e) for e in [str1, str2]))
    if not len_:
        print
        return
    PREFIX = "> "
    TRUNCLEN = 80 - len(PREFIX)
    for i in xrange(len_ / TRUNCLEN + 1):
        print PREFIX + str1[i * TRUNCLEN: (i + 1) * TRUNCLEN]
        print PREFIX + str2[i * TRUNCLEN: (i + 1) * TRUNCLEN]
        print

def main():
    srcs = []
    tgts = []
    en_frqs = "etaoinshrdlcumwfgypbvkjxqz"

    cryptogram = getCryptogram()
    cryptogram = cryptogram.replace(" ", "").replace("\n", "")

    freqs = getFrequencies(cryptogram)
    lettersfreq = "".join([e[0] for e in sorted(freqs.items(), key=itemgetter(1), reverse=True)])

    while True:
        current = swap(cryptogram, srcs, tgts)
        print "current cryptogram"
        printp(cryptogram, current)
        print "current swaps"
        printp(*("".join(e) for e in (srcs, tgts)))
        print "remaining: %s" % "".join(e for e in lettersfreq if e not in srcs)
        print "unused   : %s" % "".join(e for e in list(en_frqs) if e not in tgts)
        print
        print "(q)uit, (s)wap<a><b>, (r)emove<a>, (B)ackup, (R)estore"
        print ">",

        cmd = raw_input()
        cmd = cmd.strip()
        print
        if cmd == "q":
            print "exiting"
            break

        elif cmd.startswith("s"):
            cmd = cmd[1:]
            srcs += [cmd[0]]
            tgts += [cmd[1]]

        elif cmd.startswith("r"):
            cmd = cmd[1:]
            a = cmd[0]
            if a not in srcs:
                continue
            i = srcs.index(a)
            del(srcs[i])
            del(tgts[i])

        elif cmd.startswith("B"):
            f = open("backup", "wt")
            f.write("\n".join("".join(e) for e in [srcs, tgts]))
            f.close()

        elif cmd.startswith("R"):
            f = open("backup", "rt")
            r = f.readlines()
            f.close()
            srcs = list(r[0].strip())
            tgts = list(r[1].strip())

if __name__ == "__main__":
    main()