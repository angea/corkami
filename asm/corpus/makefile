all: tls.exe

clean:
	del tls.exe
    
test:
	tls.exe

tls.exe: tls.asm ..\consts.inc
	yasm -o tls.exe tls.asm
