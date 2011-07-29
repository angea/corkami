all: undoc1.bin undoc2.exe oldpath.exe ret.exe

ret.exe: ret.asm
	c:\python26\python ..\makepe.py ret.asm

oldpath.exe: oldpath.asm
	c:\python26\python ..\makepe.py oldpath.asm

undoc2.exe: undoc2.asm
	c:\python26\python ..\makepe.py undoc2.asm

undoc1.bin: undoc1.asm
	yasm -o undoc1.bin undoc1.asm