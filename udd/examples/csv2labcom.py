# importing labels and comments from CSV file
# to an UDD file

import sys

try:
    import udd
except ImportError:
    import os
    sys.path.append(os.path.join(os.getcwd(), '..'))
    import udd

csvfile, uddfile = sys.argv[1], sys.argv[2]

# loading the UDD file
#
f = open(csvfile, "rt")
u = udd.Udd(uddfile)
for l in f:

    # skip the header
    #
    if l.startswith("RVA"):
        continue

    # extract information
    #
    d = l.strip().split(",")
    RVA, label, comment  = int(d[0],16), d[1], d[2]

    # save new information
    #
    if label != "":
        u.AppendChunk(udd.MakeLabelChunk(RVA, label))
    if comment != "":
        u.AppendChunk(udd.MakeCommentChunk(RVA, comment))

f.close()
u.Save(uddfile)
