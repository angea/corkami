all: common XP W7

common: tls.exe tls_obfuscation.exe 96emptysections.exe 96workingsections.exe dll.dll imports.exe imports_noint.exe imports_noext.exe dll.dll dll-ld.exe

XP: tinyXP.exe maxsecXP.exe nosectionXP.exe nullSOH-XP.exe virtsectblXP.exe 

W7: tinyW7.exe tinyW7x64.exe tinyW7_3264.exe maxsec_lowaligW7.exe nosectionW7.exe maxsecW7.exe

%.exe: %.asm
	yasm -o $@ $<

%.dll: %.asm
	yasm -o $@ $<
