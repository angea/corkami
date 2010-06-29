# extracting labels and user comments from a UDD
# exporting to CSV

import udd, sys

# loading the UDD file
#
u = udd.Udd(sys.argv[1])

# getting all labels or comments chunks
#
labcoms = u.FindByTypes(udd.RVAINFO_TYPES)

d = {}

# collecting the information
#
for i in labcoms:
    c = u.GetChunk(i)
    RVA, text = udd.ReadRVAInfo(c[1])
    if RVA not in d:
        d[RVA] = ["",""]
    if c[0] == udd.CHUNK_TYPES["LABEL"]:
        d[RVA][0] = text
    else: 
        d[RVA][1] = text

# outputting CSV information
#
print "RVA,label,comment"
for i in d:
    print "%08x,%s" % (i, ",".join(d[i]))
