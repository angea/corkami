"""criss cross puzzle solving (bruting) by Ange Albertini, 2008

layout          !  piece
                !
     y          !     j
      0 1 2 3   !  i    0 1 2 3 4
x     ! ! ! !   !    0  0!0!0!0!1
   0 -+-+-+-+-  !       -+-+-+-+-
      ! ! ! !   !    1  0!1!0!1!0
   1 -+-+-+-+-  !
      ! !X! !   !
   2 -+-+-+-+-  !
      ! ! ! !   !
   3 -+-+-+-+-  !
      ! ! ! !   !

for info, the only solution
5 7 6 6 1
8 1 8 1 4
5 8 0 3 3
3 7 2 4 4
2 5 7 6 2
"""

def minus(l,i):
    return l[:i] + l[i + 1:]

def crange(*args):
    """return a cross product of multiple ranges - avoid useless nested loops - should be iterable"""
    result = [[]]
    for arg in args:
        result = [x + [y] for x in result for y in range(arg)]
    return result

# the full set of puzzle pieces

fullset = [
["00001","01010"],
["00200","20002"],
["00033","30000"],
["04040","04000"],
["50000","00505"],
["60006","00006"],
["70070","00007"],
["80800","08000"],
]

# give a piece backward or normal
def getpiece(l, isback):
    return [l[1][::-1], l[0][::-1]] if isback else l

# get matrix coordinate from piece coordinate
def getxy(i,j, rowcol, rot):
    """i = up or down, j = 'char', rowcol = row or column, rot = front or back side"""
    return (4 - j, rowcol + (1 - i)) if rot else (rowcol + i, j)

def printmat(mat):
    for x in range(5):
        for y in range(5):
            print mat[x * 5 + y],
        print
    print
    return

def addpiece(m, piece, rowcol, rot):
    """add a piece : check collision first, add the piece if no collision"""
    for i, j in crange(2,5):
        x,y = getxy(i,j,rowcol, rot)
        if piece[i][j] != "0":
            if m[x * 5 + y] != 0:
                return None
            m[x * 5 + y] = piece[i][j]

    # testing the center position. can be removed for artistic solutions ;)
    if m[2 * 5 + 2] != 0:
        return None
    return m

def solv_rec(curmat, curset):
    """solving the puzzle recursively"""
    l = len(curset)
    rot = l < 5
    rowcol = l % 4
    for p, b in crange(l, 2):
        mat = addpiece(curmat[:], getpiece(curset[p], b), rowcol, rot)
        if mat is None:                      # impossible to add this piece
            continue

        if len(curset) == 1:                     # last piece
            printmat(mat)
        else:
            solv_rec(mat, minus(curset,p))

solv_rec(5 * 5 * [0], fullset)

