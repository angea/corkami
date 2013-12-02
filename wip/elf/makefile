all: compiled.elf simple.elf simple64.elf tiny.elf regdump.elf standard.elf \
	simpleARM.elf simpleARM-Android.elf no_sections.elf no_sechdr.elf \
	dummy_secnames.elf dummy_shnum.elf dummy_secvals.elf

clean:
	rm *.elf

simpleARM-Android.elf: simpleARM.asm consts.inc
	yasm -o simpleARM-Android.elf -D ANDROID simpleARM.asm

%.elf: %.asm consts.inc
	yasm -o $@ $<
#	chmod +x ./$@
