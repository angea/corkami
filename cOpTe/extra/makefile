all: undoc1.bin undoc2.exe oldpath.exe ret.exe regs.exe bswap64.exe bswap_trap.exe

bswap_trap.exe: bswap_trap.asm
	c:\python26\python ..\makepe.py bswap_trap.asm

bswap64.exe: bswap64.asm
	c:\python26\python ..\makepe.py bswap64.asm

regs.exe: regs.asm
	c:\python26\python ..\makepe.py regs.asm

ret.exe: ret.asm
	c:\python26\python ..\makepe.py ret.asm

oldpath.exe: oldpath.asm
	c:\python26\python ..\makepe.py oldpath.asm

undoc2.exe: undoc2.asm
	c:\python26\python ..\makepe.py undoc2.asm

undoc1.bin: undoc1.asm
	yasm -o undoc1.bin undoc1.asm