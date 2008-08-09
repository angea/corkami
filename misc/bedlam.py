import sys

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
[[0,1,0],[1,0,0],[1,1,0],[1,2,0],[2,1,0]], #  x
                                           # xxx
                                           #  x

[[0,0,0],[0,1,0],[0,1,1],[0,2,0],[1,1,0]], #xXx
                                           # x

[[0,0,0],[0,1,0],[0,2,0],[1,2,0],[1,2,1]], #xxx
                                           #  X

[[0,0,0],[1,0,0],[0,1,0],[0,2,0],[0,2,1]], # xxX
                                           # x

[[0,0,0],[0,1,0],[1,1,0],[1,2,0],[2,2,0]], # xx
                                           #  xx
                                           #   x

[[0,0,0],[0,1,0],[1,1,0],[1,2,0],[2,1,0]], # xx
                                           #  xx
                                           #  x

[[0,0,0],[0,1,0],[0,2,0],[1,1,0],[1,1,1]], # xxx
                                           #  X

[[0,0,0],[0,1,0],[0,2,0],[1,0,0],[0,0,1]], # Xxx
                                           # x

[[0,0,0],[0,1,0],[0,1,1],[0,2,1],[1,0,0]], # xX`
                                           # x

[[0,0,0],[0,1,0],[0,2,0],[0,2,1],[1,1,0]], # xxX
                                           #  x

[[0,0,0],[0,1,0],[0,1,1],[0,2,1],[1,1,0]], # xX`
                                           #  x

[[0,0,0],[0,1,0],[0,1,1],[1,1,1],[1,2,1]], # xX
                                           #  ``

[[0,0,0],[0,1,0],[1,0,0],[1,0,1]]
]

def rotate_x(l):return [ l[0], -l[2], l[1]]
def rotate_y(l):return [-l[2],  l[1], l[0]]
def rotate_z(l):return [-l[1],  l[0], l[2]]

def adjust(l):
    m = [5]*3
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

#print pieces[1]
#print map(rotate_x,pieces[1])
#print adjust(map(rotate_x,pieces[1]))

def getpiece(index, x,y,z):
    p = pieces[index][:]
    for i in range(x):
        p = map(rotate_x, p[:])
    for i in range(y):
        p = map(rotate_y, p[:])
    for i in range(z):
        p = map(rotate_z, p[:])
    return adjust(p)

def crange(*args):
    """return a cross product of multiple ranges - avoid useless nested loops - should be iterable"""
    result = [[]]
    for arg in args:
        result = [x + [y] for x in result for y in range(arg)]
    return result


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

base = [ [None] * 64]

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
        if (xx + x >3) or (yy + y >3) or (xx + x > 3):
            return None
        if getmatvalue(matrix, xx + x, yy + y, zz + z) is not None:
            return None
        setmatvalue(matrix, xx + x, yy + y, zz + z, tag)
    return matrix

def getemptyslots(matrix):
    results = []
    for i,j,k in crange(4,4,4):
        if getmatvalue(matrix,i,j,k) is None:
            results += [[i,j,k]]
    return results

def solve(matrix, curset, mini):
    if len(curset) < len(mini):
        mini = curset[:]
        print mini
    slots = getemptyslots(matrix)
    print matrix
    for x,y,z in slots:
        for p in curset:
            for rx,ry,rz in crange(3,3,3):
                l = getpiece(p,rx,ry,rz)
                m = addpiece(matrix[:], l, x,y,z,pieces_tags[p])
                if m is None:
                    continue;
                if len(curset) == 1:
                    print m
                else:
                    c = curset[:]
                    c.remove(p)
                    solve(m, c, mini)

solve(base, range(13), range(14))
