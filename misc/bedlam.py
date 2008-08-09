import sys
from pprint import pprint

debug = None
valtotal = 0

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

"""
pieces_tags = "0123456789ABCDEF"
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

[[0,0,0],[0,1,0],[1,0,0],[1,0,1]]  # xx
                                   # X
#
]

def testpieceset():
    for i in range(len(pieces)):
        range2 = range(len(pieces))
        range2.remove(i)
        for i1 in range2:
            for x,y,z,xx,yy,zz in crange(3,3,3,3,3,3):
                p1 = getpiece(i, x, y ,z)
                p2 = getpiece(i1, xx, yy, zz)
                if p1 == p2:
                    print " collision !" , p1, p2, i, x, y ,z, i1, xx, yy, zz


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


def addpiece(matrix, l, x,y,z, tag="1"):
    for i in l:
        xx,yy, zz = i
        if ((xx + x )>3) or ((yy + y )>3) or ((xx + x )> 3):
            return None
        if ((xx + x )<0) or ((yy + y )<0) or ((xx + x )< 0):
            return None
        if getmatvalue(matrix, xx + x, yy + y, zz + z) is not None:
            return None
        setmatvalue(matrix, xx + x, yy + y, zz + z, tag)
    for x,y,z in crange(4,4,4):
        if getmatvalue(matrix, x,y,z) is None:
            l = [[x-1,y,z], [x+1,y,z],[x,y-1,z],[x,y+1,z],[x,y,z-1],[x,y,z+1]]
            l = filter(lambda(x,y,z): 0<x<3 and 0<y<3 and 0<z<3, l[:])
            if l != []:
                r = filter(lambda(x,y,z):getmatvalue(matrix, x,y,z) is None, l)
                if r == []:
                    return None
    debug = None
    return matrix

def getemptyslots(matrix):
    results = []
    for i,j,k in crange(4,4,4):
        if getmatvalue(matrix,i,j,k) is None:
            results += [[i,j,k]]
    return results


mymax = 14
def solve(matrix, curset, cursol):
#    print cursol
    global mymax , valtotal
    if len(curset) < mymax:
        mymax = len(curset)
        
        print
        print mymax
        printmat(matrix)
    slots = getemptyslots(matrix)
    for x,y,z in slots:
        for p in curset[0:1]:
            for rx,ry,rz in crange(3,3,3):
                l = getpiece(p,rx,ry,rz)
                valtotal += 1
                if (valtotal % 10000) == 0:
                    print
                    print valtotal
                    printmat(matrix)
                m = addpiece(matrix[:], l, x,y,z,pieces_tags[p])
                if m is None:
                    continue;
                if len(curset) == 1:
                    print
                    print "success"
                    pprint(m)
                else:
                    c = curset[:]
                    c.remove(p)
                    solve(m, c, cursol + [[p,rx,ry,rz]])

solve(base[:], range(13), [])
print valtotal