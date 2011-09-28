all: XP w7 common

common: tls.exe tls_obfuscation.exe 96emptysections.exe 96workingsections.exe 

XP: tinyXP.exe XP.exe nosectionXP.exe nullSOH-XP.exe virtsectblXP.exe 

W7: tinyW7.exe tinyW7x64.exe maxsec_lowaligW7.exe nosectionW7.exe maxsecW7.exe

%.exe: %.asm
	yasm -o $@ $<

%.dll: %.asm
	yasm -o $@ $<

testxp: 
	$(XP)