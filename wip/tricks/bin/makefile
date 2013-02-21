all: common XP W7 64b olly

olly: ollyexp.exe ollyres.exe

common: opengl.exe

XP: 

W7: 

64b: 

%.exe: ..\%.asm
	yasm -o $@ $<

%.dll: ..\%.asm
	yasm -o $@ $<
