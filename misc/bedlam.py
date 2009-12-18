import sys, psyco
from pprint import pprint
import md5,random

debug = None
valtotal = 0
sols = {}
"""bedlam cube solution solving, Ange Albertini 2008

   z
   |
   |
   |
   0-----y
  /
 /
x

#Rotation Z: Y = x,  X = -y
#Rotation Y: Z = x,  X = -z
#Rotation X: Z = y,  Y = -z


best found so far:
2
2133 288_ 227_ 777_
1113 9184 _284 AA7_
6663 99C3 _A84 _AA4
96CC 96C5 _555 __54

  x    0 xXx    1 xxx    2  xxX   3  xx    4  xx    5  xxx   6  Xxx   7  xX`   8  xxX   9  xX`   A  xX    B  xx    C
 xxx      x         X       x         xx       xx       X       x        x         x        x        ``      X
  x                                    x       x


"""
pieces_tags = "0123456789ABC"
pieces = [
[[0,1,0],[1,0,0],[1,1,0],[1,2,0],[2,1,0]], #  x    0
                                           # xxx
                                           #  x

[[0,0,0],[0,1,0],[0,1,1],[0,2,0],[1,1,0]], #xXx    1
                                           # x

[[0,0,0],[0,1,0],[0,2,0],[1,2,0],[1,2,1]], #xxx    2
                                           #  X

[[0,0,0],[1,0,0],[0,1,0],[0,2,0],[0,2,1]], # xxX   3
                                           # x

[[0,0,0],[0,1,0],[1,1,0],[1,2,0],[2,2,0]], # xx    4
                                           #  xx
                                           #   x

[[0,0,0],[0,1,0],[1,1,0],[1,2,0],[2,1,0]], # xx    5
                                           #  xx
                                           #  x

[[0,0,0],[0,1,0],[0,2,0],[1,1,0],[1,1,1]], # xxx   6
                                           #  X

[[0,0,0],[0,1,0],[0,2,0],[1,0,0],[0,0,1]], # Xxx   7
                                           # x

[[0,0,0],[0,1,0],[0,1,1],[0,2,1],[1,0,0]], # xX`   8
                                           # x

[[0,0,0],[0,1,0],[0,2,0],[0,2,1],[1,1,0]], # xxX   9
                                           #  x

[[0,0,0],[0,1,0],[0,1,1],[0,2,1],[1,1,0]], # xX`   A
                                           #  x

[[0,0,0],[0,1,0],[0,1,1],[1,1,1],[1,2,1]], # xX    B
                                           #  ``

[[0,0,0],[0,1,0],[1,0,0],[1,0,1]]          # xx    C
                                           # X
#
]

psize = len(pieces)

def getpieceoffset(p):
    """"""
    miny = [5,5]
    for i in p:
        if i[1] == 0:
            miny = min(miny, [i[0], i[2]])
    return miny
    
def testpieceset():
    rotations = [0 for i in range(psize)]
    for i in range(psize):
        rotations[i] = []
        for x,y,z in crange(5,5,5):
            p = getpiece(i, x, y ,z)
            p.sort()
            p = [p, getpieceoffset(p)]
            if p not in rotations[i]:
                rotations[i].append(p)

#    for i in rotations:
#        print
#        for j in i:
#            print j
    return rotations


def rotate_x(l):return [ l[0], -l[2], l[1]]
def rotate_y(l):return [-l[2],  l[1], l[0]]
def rotate_z(l):return [-l[1],  l[0], l[2]]

def adjust(l):
    m = [5 for i in range(3)]
    ll = []
    for i in l:
        for j in range(3):
            m[j] = min(i[j], m[j])

    for j in range(3):
        if m[j] < 0:
            m[j] = -m[j]
    for i in l:
        l2 = []
        for j in range(3):
            l2 += [i[j] + m[j]]
        ll += [l2]
    return ll

def printmat(m):
    for x in range(4):
        l = ""
        for z in range(4):

            for y in range(4):
                v = getmatvalue(m, x,y,z)
                l += v if v is not None else "_"
            l += " "
        print l

def rotatem_x(m):
    matrix = [None for i in range(64)]
    for x,y,z in crange(4,4,4):
        matrix[x + 4 * ( y + 4 *z)] = m[x + 4 * ( 3-z + 4 * y)]
    return matrix
    
def rotatem_y(m):
    matrix = [None for i in range(64)]
    for x,y,z in crange(4,4,4):
        matrix[x + 4 * ( y + 4 *z)] = m[3-z + 4 * ( y + 4 * x)]
    return matrix

def rotatem_z(m):
    matrix = [None for i in range(64)]
    for x,y,z in crange(4,4,4):
        matrix[x + 4 * ( y + 4 *z)] = m[3-y + 4 * ( x + 4 * z)]
    return matrix

def rotatematrix(m, x, y ,z):
    """rotates the complete matrix according to x,y,z"""
    for i in xrange(x):
        m = rotatem_x(m)
    for i in xrange(y):
        m = rotatem_y(m)
    for i in xrange(z):
        m = rotatem_z(m)
    return m

def getpiece(index, x,y,z):
    global debug
    if [index, x, y, z] == [3,0,1,1]:
        #debug = 1
        pass
    if debug: print

    p = pieces[index][:]
    if debug: print p
    for i in range(x):
        p = adjust(map(rotate_x, p[:]))
        if debug: print p
    for i in range(y):
        p = adjust(map(rotate_y, p[:]))
        if debug: print p
    for i in range(z):
        p = adjust(map(rotate_z, p[:]))
        if debug: print p
    debug = None
    return p

def crange(*args):
    """return a cross product of multiple ranges - avoid useless nested loops - should be iterable"""
    result = [[]]
    for arg in args:
        result = [x + [y] for x in result for y in range(arg)]
    return result


base = [ None for i in range(64)]

def getmatvalue(matrix, x,y,z):
    try:
        return matrix[x + 4 * ( y + 4 *z)]
    except:
        return "1"


def setmatvalue(matrix, x,y,z, value):
    matrix[x + 4 * ( y + 4 *z)] = value


def isclose(l1,l2):
    x1,y1,z1 = l1
    x2,y2,z2 = l2
    return (abs(x1-x2) + abs(y1-y2) + abs(z1-z2)) == 1

def addpiece(matrix, l, x,y,z, slots, tag, curset, offset):
    for i in l:
        xx,yy, zz = i
        if ((xx + x ) >3) or ((yy + y ) >3) or ((zz + z ) > 3) or ((xx + x - offset[0] )<0) or ((yy + y )<0) or ((zz + z - offset[1]  )< 0) or \
            getmatvalue(matrix, xx + x, yy + y, zz + z) is not None:
            return None, None
        setmatvalue(matrix, xx + x, yy + y, zz + z, tag)
        try:
            slots.remove([xx + x, yy + y, zz + z])
        except:
            print slots
            print [xx + x - offset[0], yy + y, zz + z - offset[1]]
            sys.exit()
    slotgroups = []
    for s1 in slots:
        foundgroup = False
        for slotgroup in slotgroups:
            for slot in slotgroup:
                if isclose(s1,slot):
                    slotgroup.append(s1)
                    foundgroup = True
                    break
            if foundgroup == True:
                break
        else:
            slotgroups.append([s1])
    #print slotgroups
    limit3 = True if 13 in curset else False
    for slotgroup in slotgroups:
        if len(slotgroup) < 3:
            return None, None
        if len(slotgroup) == 3:
            if limit3:
                limit3 = False
            else:
                return None, None

        #if getmatvalue(matrix, x,y,z) is None:
        #    l = [[x-1,y,z], [x+1,y,z],[x,y-1,z],[x,y+1,z],[x,y,z-1],[x,y,z+1]]
        #    l = filter(lambda(x,y,z): 0<=x<=3 and 0<=y<=3 and 0<=z<=3, l[:])
        #    if l != []:
        #        r = filter(lambda(x,y,z):getmatvalue(matrix, x,y,z) is None, l)
        #        if r == []:
        #            return None, None
    debug = None
    return matrix, slots

def getemptyslots(matrix):
    results = []
    for i,j,k in crange(4,4,4):
        if getmatvalue(matrix,i,j,k) is None:
            results += [[i,j,k]]
    return results

def getmatchecksum(matrix, curset): #curset should be sorted
    return md5.new("".join(map(lambda(x): "_" if x is None else "1", matrix)) + "".join(map(str, curset))).digest()

mymax = 4
def solve(matrix, curset, slots):
#    print cursol
    global mymax , valtotal
    if len(curset) < mymax:
        mymax = len(curset)

        print
        print mymax
        printmat(matrix)
    slots = getemptyslots(matrix)
    for x,y,z in slots:
        #random.shuffle(curset)
        for p in curset:
            for pos, l in enumerate(rotations[p]):
                #l = getpiece(p,rx,ry,rz)
                valtotal += 1
                if (valtotal % 100000) == 0:
                    print "_",
                newmat,s = addpiece(matrix[:], l[0], x - l[1][0],y,z - l[1][1], slots[:], pieces_tags[p], curset, l[1])
                if newmat is None:
                    continue;
                if len(curset) == 1:
                    print
                    print "success"
                    pprint(newmat)
                else:
#                    check = getmatchecksum(newmat, curset)
#                    if check in sols:
#                        continue
#                    for rx,ry,rz in crange(4,4,4):
#                        m = rotatematrix(newmat[:],rx,ry,rz)
#                        sols[getmatchecksum(m, curset)] = None
                    #sols[check] = None
#                    print len(sols)
                    newset = curset[:]
                    newset.remove(p)
                    solve(newmat, newset, s)

rotations = testpieceset()
total = 0
for i in rotations:
#    pprint(i)
    total += len(i)
total *= 6227020800 # 13!
total *= 64
print total
solve(base[:], range(13), [[x,y,z] for x,y,z in crange(4,4,4)])
print valtotal