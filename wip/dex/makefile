all: compiled.dex

clean:
	del *.dex

%.dex: %.de
	c:\python27\python fixdex.py $<

%.de: %.asm
	yasm -o $@ $<
