# brutal apisecschema parser
# as documented by deroko @ http://xchg.info/wiki/index.php?title=ApiMapSet

# Ange Albertini BSD Licence 2011

import sys, struct
fn = sys.argv[1] if len(sys.argv) > 1 else r"c:\windows\system32\apisetschema.dll"
with open(fn, "rb") as f:
	r = f.read()
SECTIONTABLESTART = 0x1b8
if r[SECTIONTABLESTART: SECTIONTABLESTART + 8] != ".apiset\0":
	sys.exit(42)
SECTIONSTART = 0x400
SECTIONSIZE = 0xe00
buf = r[SECTIONSTART: SECTIONSTART + SECTIONSIZE]
off = 0
dwVersion, dwNumberOfEntries = struct.unpack("<2L", buf[off: off + 2 * 4])
off += 2 * 4
if dwVersion != 2:
    print "ERROR: unexpected version"
    sys.exit(42)
print "found %i redirection thunks" % dwNumberOfEntries
for i in xrange(dwNumberOfEntries):
    NameOffset, Length, RealDllOffset = struct.unpack("<3L", buf[off: off + 3 * 4])
    off += 3 * 4
    print "api-%s" % "".join(buf[NameOffset: NameOffset + Length]).decode("utf-16")

    offreal = RealDllOffset
    dwCount = struct.unpack("<L", buf[offreal:offreal + 1 * 4])[0]
    offreal += 1 * 4
    for j in xrange(dwCount):
        NameOffsetRealName, LengthRealName, NameOffset, Length = struct.unpack("<4L", buf[offreal: offreal + 4 * 4])
        offreal += 4 * 4
        if LengthRealName > 0:
            print u"\t=> %s (real name)" % "".join(buf[NameOffsetRealName: NameOffsetRealName + LengthRealName]).decode("utf-16")
        if Length > 0:
            print u"\t=> %s" % "".join(buf[NameOffset: NameOffset + Length]).decode("utf-16")