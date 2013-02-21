all: common XP W7 64b

common: bswap.exe nop.exe oldpath.exe pushret.exe initvals.exe overdasm.exe fpu.exe demo32.exe

XP: gs.exe smsw.exe privileged.sys

W7: 96bits.exe

64b: movsxd64.exe demo64.exe

%.exe: ..\%.asm
	yasm -o $@ $<

%.dll: ..\%.asm
	yasm -o $@ $<

%.sys: ..\%.asm
	yasm -o $@ $<
