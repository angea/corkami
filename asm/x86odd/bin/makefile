all: common XP W7 64b

common: bswap.exe nop.exe oldpath.exe pushret.exe

XP: gs.exe smsw.exe

W7: 

64b: movsxd64.exe

%.exe: ..\%.asm
	yasm -o $@ $<

%.dll: ..\%.asm
	yasm -o $@ $<
