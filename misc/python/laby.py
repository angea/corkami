# small labyrinth generator
# brutal algorithm, but generates a random one-solution maze

# Ange Albertini, BSD Licence 2013
# inspired by a long lost GWBasic one-liner - merci PJ!

import random

W = 20
H = 20

def fill(x, y):
        map[x + (2 * W + 1) * y] = "*"

map = [" "] * (2 * W + 1) * (2 * H + 1)

# top and bottom walls
for i in xrange(2 * W + 1):
    fill(i, 0)
    fill(i, 2 * H)

# left and right walls
for j in xrange(2*H + 1):
    fill(0, j)
    fill(2 * W, j)

#start
fill(1,2)
#end
fill(2 * W - 1, 2 * H - 2)

# how many inter-wall left to draw
count = (W - 1) * (H - 1) - 1

fill(2,2) # let's draw the start

while (count > 0):

    # let's take a random 'main' point
    loc = 2 * random.randrange(0, W - 1) + 2 + \
        (2 * W + 1) * (2 * random.randrange(0, H - 1) + 2)

    # is it already explored ?
    if map[loc] == "*":
        # left/right or up/down direction ?
        delta = 1 if random.randrange(2) == 1 else 2 * W + 1
        # negative or positive progression ?
        delta = delta if random.randrange(2) == 1 else - delta
        # not explored yet ?
        if map[loc + delta * 2] == " ":
            # let's fill it
            map[loc + delta * 2] = "*"
            # and join both points
            map[loc + delta] = "*"
            count -= 1

for j in xrange(2 * H + 1):
    print "".join(map[(2 * W + 1) * j: (2 * W + 1) * (j + 1)])
