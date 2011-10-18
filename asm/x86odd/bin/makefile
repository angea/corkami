all: common XP W7 64b

common: bswap.exe nop.exe

XP: 

W7: 

64b: movsxd64.exe

%.exe: ..\%.asm
	yasm -o $@ $<

%.dll: ..\%.asm
	yasm -o $@ $<
