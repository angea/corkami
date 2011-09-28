all: XP w7 common

common: tls.exe tls_obfuscation.exe 96emptysections.exe 96workingsections.exe 

XP: tinyXP.exe XP.exe XP-appendeddata.exe XP-nosection.exe XP-nullOH.exe XP-virtualsections.exe 

W7: tinyW7.exe tinyW7x64.exe W7.exe W7-nosection.exe 8Kworkingsections.exe

%.exe: %.asm
	yasm -o $@ $<

%.dll: %.asm
	yasm -o $@ $<

testxp: 
	$(XP)