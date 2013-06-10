all: bmpjs.bmp gifjs.gif

clean:
	del bmpjs.bmp gifjs.gif

bmpjs.bmp: bmpjs.asm
	yasm -o $@ $<

gifjs.gif: gifjs.asm
	yasm -o $@ $<

