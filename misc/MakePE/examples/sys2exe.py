# turns a driver into a GUI version + GUI with imports removed

import pefile, sys
fn = sys.argv[1]
p = pefile.PE(fn)

p.OPTIONAL_HEADER.Subsystem = 2 # pefile.SUBSYSTEM_TYPE['IMAGE_SUBSYSTEM_WINDOWS_GUI']
p.write(fn.replace(".sys",".exe"))

p.OPTIONAL_HEADER.DATA_DIRECTORY[1].VirtualAddress = 0
p.write(fn.replace(".sys","-noimports.exe"))