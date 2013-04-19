all: hello.exe hello.elf hello.macho nops.exe nops.elf nops.macho

clean:
	del *.elf *.exe *.macho

%.elf: %.asm elf.inc common.inc
	yasm -o $@ $< -DELF

%.exe: %.asm pe.inc common.inc
	yasm -o $@ $< -DPE

%.macho: %.asm macho.inc common.inc
	yasm -o $@ $< -DMACHO
