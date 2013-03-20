all: compiled.elf simple.elf simple64.elf tiny.elf regdump.elf standard.elf simpleARM.elf

clean:
	del *.elf

%.elf: %.asm consts.inc
	yasm -o $@ $<
