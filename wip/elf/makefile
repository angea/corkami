all: compiled.elf simple.elf simple64.elf tiny.elf regdump.elf standard.elf \
	simpleARM.elf simpleARM2.elf no_sections.elf no_sechdr.elf \
	dummy_secnames.elf dummy_shnum.elf dummy_secvals.elf

clean:
	rm *.elf

simpleARM2.elf: simpleARM.asm consts.inc
	yasm -o simpleARM2.elf -D ABIR7 simpleARM.asm

%.elf: %.asm consts.inc
	yasm -o $@ $<
#	chmod +x ./$@
