all: tls.exe tls_obfuscation.exe 96emptysections.exe 96workingsections.exe 8Kworkingsections.exe

clean:
	del tls.exe
    
test:
	@tls.exe && tls_obfuscation.exe && 96emptysections.exe && 96workingsections.exe && 8Kworkingsections.exe

tls.exe: tls.asm ..\consts.inc
	yasm -o tls.exe tls.asm
tls_obfuscation.exe: tls_obfuscation.asm ..\consts.inc
	yasm -o tls_obfuscation.exe tls_obfuscation.asm

96emptysections.exe: 96emptysections.asm ..\consts.inc
	yasm -o 96emptysections.exe 96emptysections.asm
96workingsections.exe: 96workingsections.asm ..\consts.inc
	yasm -o 96workingsections.exe 96workingsections.asm
8Kworkingsections.exe: 8Kworkingsections.asm ..\consts.inc
	yasm -o 8Kworkingsections.exe 8Kworkingsections.asm
