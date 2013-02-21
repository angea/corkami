all: simple.exe simple64.exe

%.exe: %.asm consts.inc
	yasm -o $@ $<
