all: compiled.elf simple.elf simple64.elf tiny.elf regdump.elf standard.elf simpleARM.elf simpleARM-Android.elf

clean:
	del *.elf

simpleARM-Android.elf: simpleARM.asm consts.inc
	yasm -o simpleARM-Android.elf -D ANDROID simpleARM.asm

%.elf: %.asm consts.inc
	yasm -o $@ $<
