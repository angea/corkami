all: common XP W7 64b

common: opengl.exe

XP: 

W7: 

64b: 

%.exe: ..\%.asm
	yasm -o $@ $<

%.dll: ..\%.asm
	yasm -o $@ $<
