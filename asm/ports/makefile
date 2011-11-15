all: schost64.exe sc64host32.exe

schost64.exe: schost64.asm mcdermott64.bin
	c:\python26\python ..\makepe.py schost64.asm
sc64host32.exe: sc64host32.asm mcdermott64.bin
	c:\python26\python ..\makepe.py sc64host32.asm
mcdermott64.bin: mcdermott64.asm
	yasm -o mcdermott64.bin mcdermott64.asm
