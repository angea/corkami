import pefile, sys
fn = sys.argv[1]
p = pefile.PE(fn)
p.OPTIONAL_HEADER.Subsystem = 2
p.write(fn.replace(".sys",".exe"))
p.OPTIONAL_HEADER.DATA_DIRECTORY[1].VirtualAddress = 0
p.write(fn.replace(".sys","-noimports.exe"))