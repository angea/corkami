all: simple.exe

%.exe: %.asm consts.inc
	yasm -o $@ $<
