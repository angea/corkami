"""vm dumper for Eset Crackme 2010"""

import struct

def extract_vop():
    """extract virtual opcodes from dumped EXE"""
    SIZE = 391090 / 2

    f = open("esetcrackme-dump.exe", "rb")
    f.seek(0x305C)
    data = f.read(SIZE* 2)
    f.close()
    return struct.unpack("<%iH" % SIZE, data)

def se_(i,j):
    """standard serial bit representation"""
    return "s%s%s" % (chr(ord('a') + i), chr(ord('A') + j))

def cleanNOT(L):
    """clean not-based expressions"""
    if L[1] == [1]:
        return [0]

    if L[1] == [0]:
        return [1]

    if L[1][0] == "!":
        return L[1][1] # wrong ?

    if L[1][0] == "&":
        return ["!&"] + sorted(L[1][1:])

    if L[1][0] == "!&":
        return ["&"] + sorted(L[1][1:])

    if L[1][0] == "|":
        return ["!|"] + sorted(L[1][1:])

    #not (A XOR B) <=> A == B
    if L[1][0] == "^":
        return ["=="] + sorted(L[1][1:])

    return None


def cleanNAND(L):
    if [0] in L[1:]:
        return [1]

    if L[1] == [1]:
        return ["!", L[2]]

    if L[1] == L[2]:
        return ["!", L[1]]

    if L[1][0] == "!&" and \
        L[2][0] == "!&" and \
        L[1][1][0] == "!" and \
        L[2][1][0] == "!" and \
        str(L[1][1][1][0]) == str(L[2][2][0]) and \
        str(L[1][2][0]) == str(L[2][1][1][0]):

        A = min(L[1][1], L[2][1])
        B = max(L[1][1], L[2][1])

        return ["!&", A, B]

    if L[1][0] == "!" and L[2][0] == "!":
        A = min(L[1][1], L[2][1])
        B = max(L[1][1], L[2][1])

        return ["|", A, B]

    #(A nor B) nand (A and B) = True
    if L[1][0] == "!|" and L[2][0] == "&" and \
        L[1][1] == L[2][1] and L[1][2] == L[2][2]:

        return [1]

    return None

def cleanAND(L):
    if [0] in L[1:]:
        return [0]

    if L[1] == [1]:
        return L[2]

    if L[1][0] == "!&" and \
        L[2][0] == "!&" and \
        L[1][1][0] == "!" and \
        L[2][1][0] == "!" and \
        str(L[1][1][1][0]) == str(L[2][2][0]) and \
        str(L[1][2][0]) == str(L[2][1][1][0]):

        return ["&", list(L[1][1][1]), list(L[1][2])]

    if L[1] == L[2]:
        return L[1]

#(A OR B) AND (A NAND B) == XOR
    if L[1][0] == "!&" and L[2][0] == "|" and \
        L[1][1] == L[2][1] and L[1][2] == L[2][2]:
            return ["^", L[1][1], L[1][2]]

    if L[1][0] == "|" and L[2][0] == "!&" and \
        L[1][1] == L[2][1] and L[1][2] == L[2][2]:
            return ["^", L[1][1], L[1][2]]
    return None


def cleanOR(L):
    if L[1] == L[2]:
        return L[1]

    if L[1] == [0]:
        return L[2]

    if 1 in L[1:]:
        return [1]

    return None

def clean(L):
    if isinstance(L, int):
        return [L]
    temp = 0
    while temp is not None:
        try:
            if L[0] == "!":
                temp = cleanNOT(L)
            elif L[0] == "&":
                temp = cleanAND(L)
            elif L[0] == "!&":
                temp = cleanNAND(L)
            elif L[0] == "|":
                temp = cleanOR(L)
            else:
                temp = None

            if temp is None:
                return L
            else:
                L = temp
        except:
            raise Exception("shouldn't be here", L)

def test():
    assert clean(["!", [1]]) == [0]
    assert clean(["!", [0]]) == [1]
    assert clean(["!", ["!", [0]]]) == [0]
    assert clean(["&", [0], ["A"]]) == [0]
    
    assert clean(["!", ["&", ["A"], ["B"]]]) == ["!&", ["A"], ["B"]]
    assert clean(["!&", [0], ["B"]]) == [1]
    assert clean(["|", ["A"], ["A"]]) == ["A"]
    assert clean(["!&", ["!", ["A"]], ["!", ["B"]]]) == ["|", ["A"], ["B"]]
    assert clean(["|", [0], ["A"]]) == ["A"]

def print_(L):
    """mathematical output of expressions"""
    if L[0] == "&":
        return "(%s) AND (%s)" % (print_(L[1]), print_(L[2]))
    if L[0] == "|":
        return "(%s) OR (%s)" % (print_(L[1]), print_(L[2]))
    if L[0] == "!&":
        return "(%s) NAND (%s)" % (print_(L[1]), print_(L[2]))
    if L[0] == "!|":
        return "(%s) NOR (%s)" % (print_(L[1]), print_(L[2]))
    if L[0] == "^":
        return "(%s) XOR (%s)" % (print_(L[1]), print_(L[2]))
    if L[0] == "==":
        return "NOT((%s) XOR (%s))" % (print_(L[1]), print_(L[2]))
    if L[0] == "!":
        return "NOT (%s)" % print_(L[1])
    return L[0]


test()
r = extract_vop()
EIP = 0 # + 0x40305C

blocks = [0] # blocks' start adresses
code = {}

curf = dict([[i, 0] for i in range(10)])
for i in range(32):
    for j in range(32):
        s = se_(i,j)
        curf[s] = str(s)


for i, eax in enumerate(r):
    edx = eax >> 0xd
    ecx = eax & 7
    if EIP in blocks:
        #print "%05X:" % (EIP)
        code[EIP] = []
        curblock = EIP
    #print "    ",

    if edx == 0:
        code[curblock] += [["ret"]]
        #print "ret"

    elif edx == 1:
        try:
            address = i + (r[i:]).index(0) + 1
            blocks += [address]
        except:
            print r[i:]
            break

#        print "j!%i %X" % (ecx, address)
        code[curblock] += [["jxx", ecx, address]]

    # NOT
    elif edx == 2:
        code[curblock] += [["not", ecx]]
        curf[ecx] = ["!", curf[ecx]]

#        print "mov1 f%i" % ecx

    elif edx in [4, 5]:
        eax = (eax & 0x1c0) >> 6

        # AND
        if edx == 4:


            A = min(curf[eax], curf[ecx])
            B = max(curf[eax], curf[ecx])

            code[curblock] += [["&", eax, ecx]]

            curf[eax] = ["&" , list(A), list(B)]
#            print "and f%i, f%i" % (eax, ecx)

        # MOV
        elif edx == 5:
            code[curblock] += [["mov", eax, ecx]]
            curf[eax] = list(curf[ecx])
#           print "mov f%i, f%i" % (eax, ecx)

    elif edx in [6, 7]:
        ebx = (eax & 0x1f00) >> 8
        eax = (eax & 0x0f8) >> 3

        if edx == 6:
            code[curblock] += [["movfs", ecx, ebx, eax]]
            #curf[ecx] = [se_(ebx, eax)]  # [curf[]]
            curf[ecx] = [curf[se_(ebx, eax)]]
#            print "f%i = s[%i, %i]" % (ecx, ebx, eax)

        elif edx == 7:
            code[curblock] += [["movsf", ebx, eax, ecx]]

            print "%s = %s" % (se_(ebx, eax), print_(curf[ecx]))

            curf[se_(ebx, eax)] == curf[ecx]
    #curf[ecx] = clean(curf[ecx])
    EIP += 1