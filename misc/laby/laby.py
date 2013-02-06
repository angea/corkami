# a one-solution labyrinth generator

# outputs: text (debug) or bitmap (TGA)
# algorithm: dumb (blind) or smart (maintains a TODO list)

# Ange Albertini, BSD Licence 2013


# output functions #############################################################

def printmap():
    for j in xrange(HEIGHT):
        print "".join(map[WIDTH * j: WIDTH * (j + 1)])

    return

def writeTGA():
    import struct

    ImageIDField = 0
    ColorMap = 1
    ImageType = 1
    PaletteOffset = 0
    ColorCount = 1
    ColorMapSize = 24
    X = 0
    Y = 0

    LenX = WIDTH
    LenY = HEIGHT
    palette = [8, 0, 255, 255, 255]

    r = struct.pack("<BBBHHBHHHH",
        ImageIDField, ColorMap, ImageType, PaletteOffset, ColorCount,
        ColorMapSize, X, Y, LenX, LenY)
    r += struct.pack(("<%iB" % len(palette)), *palette)

    r += "".join(map) # Warning: it's saved UPSIDE DOWN!

    with open("result.tga", "wb") as f:
        f.write(r)

    return


################################################################################

def fill(x, y):
    map[x + WIDTH * y] = FULL
    return


def square(X, Y, SizeX, SizeY):
    assert X % 2 == 0
    assert Y % 2 == 0
    assert SizeX % 2 == 1
    assert SizeY % 2 == 1

    for i in range(SizeX):
        fill(i + X, Y)
        fill(i + X, Y + SizeY - 1)

    for j in range(SizeY):
        fill(X, Y + j)
        fill(X + SizeX - 1, Y + j)
    return


def init():
    square(0, 0, WIDTH, HEIGHT)

    # you can also draw in advance some areas for fancy effects
    square(WIDTH * 1 / 3 - 1, HEIGHT * 1 / 3 - 1, WIDTH * 1 / 3, HEIGHT * 1 / 3)

    fill(1, 2)                  # start
    fill(WIDTH - 2, HEIGHT - 3) # end

    fill(2, 2) # first main point

    return


# algorithms ###################################################################

def brutefill():
    DELTAS = [-1, 1, WIDTH, -WIDTH]

    # how many inter-wall left to draw
    count = (W - 1) * (H - 1) - 1

    while (count > 0):

        # let's take a random 'main' point
        X = random.randrange(0, W - 1)
        Y = random.randrange(0, H - 1)
        loc = (2 * X + 2) + WIDTH * (2 * Y + 2)

        # is it already explored ?
        if map[loc] == FULL:
            delta = DELTAS[random.randrange(0, len(DELTAS))]

            # not explored yet ?
            if map[loc + delta * 2] == EMPTY:

                # let's fill it
                map[loc + delta * 2] = FULL

                # and join both points
                map[loc + delta] = FULL
                count -= 1
    return


def smartfill():
    UP = [-1, 0]
    DOWN = [1, 0]
    LEFT = [0, -1]
    RIGHT = [0, 1]
    DIRS = [UP, DOWN, LEFT, RIGHT]

    todo = [[2, 2, RIGHT], [2, 2, DOWN]]

    while (todo):
            X, Y, [DX, DY] = todo.pop(random.randrange(0, len(todo)))

            # draw the dots
            iX = X +DX
            iY = Y + DY
            fill(iX, iY)

            tX = iX + DX
            tY = iY + DY
            fill(tX, tY)

            # check the directions related to the new dot
            for dx, dy in DIRS:

                # removing any already existing direction pointing to the new dot
                if [tX + 2 * dx, tY + 2 * dy, [-dx, -dy]] in todo:
                    todo.remove([tX + 2 * dx, tY + 2 * dy, [-dx, -dy]])

                # adding any empty pixel to be processed
                if map[tX + dx * 2 + WIDTH * (tY + dy * 2)] == EMPTY:
                        todo += [[tX, tY , [dx, dy]]]
    return


# main #########################################################################

import random

# TGA style
EMPTY, FULL = "\0", "\xFF"

# text style
#EMPTY, FULL = " ", "*"

W = 64
H = 38

WIDTH = 2 * W + 1
HEIGHT = 2 * H + 1

map = [EMPTY] * WIDTH * HEIGHT

init()
smartfill() # brutefill()
writeTGA() # printmap()
