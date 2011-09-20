all: schost64.exe

schost64.exe: schost64.asm mcdermott64.bin
	c:\python26\python ..\makepe.py schost64.asm
mcdermott64.bin: mcdermott64.asm
	yasm -o mcdermott64.bin mcdermott64.asm
