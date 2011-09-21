all: tls.exe 96emptysections.exe

clean:
	del tls.exe
    
test:
	@tls.exe && 96emptysections.exe

tls.exe: tls.asm ..\consts.inc
	yasm -o tls.exe tls.asm

96emptysections.exe: 96emptysections.asm ..\consts.inc
	yasm -o 96emptysections.exe 96emptysections.asm
