# Solver for Anansi Maze, step 1
# step 2 = read from the final table. TODO: explore automatically with a dictionary
# step 3 = order pieces like a dictionary, then read the middle (rows)
# http://www.pavelspuzzles.com/2009/08/anansis_maze.html

pieces = [
    " I  M ",
    "   RY ",
    "  A  O",
    " IN   ",
    "  C D ",
    "P  I  ",
    "   A R",
    " R H  ",
    "I   L ",
    " E   D",
    "S D   ",
    "T    R"
    ]

BOARD = [
    "NB    ",
    "   E R",
    "S  D  ",
    "  E  E",
    "  T E ",
    " O  E "] # spider is before the O

poss = [[] for i in xrange(12)]

def checkpiece(board, piece, row):
    for i in xrange(6):
        if board[row][i] != " " and piece[i] != " ":
            return None
    else:
        return 1

def printboard(board):
    for x in range(6):
        print board[x]

def putpiece(board, piece, row):
    row_str = list(board[row])
    for i in xrange(6):
        if piece[i] != " ":
            row_str[i] = piece[i]
    board[row] = "".join(row_str)
    return board


assert checkpiece(BOARD, pieces[0], 1) == 1
assert checkpiece(BOARD, pieces[0], 0) is None

def test(remaining, board, walkthrough):
    if remaining == -1:
        print "finished"
        printboard(board)
        return
    piece = pieces[remaining]
    found = 0
    for i in xrange(6): # poss(remaining)
        if checkpiece(board, piece, i):
            found += 1
            newboard = list(putpiece(list(board), piece, i))
            test(remaining - 1, newboard, walkthrough + [i])
#    if found == 0:
#        print "dead end"
#        print remaining, "[%s]" % pieces[remaining], poss[remaining], walkthrough
#        printboard(board)
#        print
        
for i in xrange(12):
    for j in xrange(6):
        if checkpiece(BOARD, pieces[i], j) is not None:
            poss[i] += [j]

test(11, list(BOARD), list())