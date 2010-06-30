# extracting labels and user comments from a UDD
# exporting to CSV

import sys

try:
    import udd
except ImportError:
    import os
    sys.path.append(os.path.join(os.getcwd(), '..'))
    import udd

uddfile = sys.argv[1]

# loading the UDD file
#
u = udd.Udd(uddfile)

# getting all labels or comments chunks
#
labcoms = u.FindByTypes(udd.RVAINFO_TYPES)

# collecting the information
#
d = {}
for i in labcoms:
    ct, cd = u.GetChunk(i)
    RVA, text = udd.ReadRVAInfo(cd)
    if RVA not in d:
        d[RVA] = ["",""]
    if ct == udd.CHUNK_TYPES["LABEL"]:
        d[RVA][0] = text
    else: 
        d[RVA][1] = text

# outputting CSV information
#
print "RVA,label,comment"
for i in d:
    print "%08x,%s" % (i, ",".join(d[i]))
