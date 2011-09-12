all: regdump.exe regdumplib.dll

regdump.exe: regdump.asm ..\consts.inc ..\templates.py
	c:\python26\python ..\makepe.py regdump.asm
regdumplib.dll: regdumplib.asm ..\consts.inc ..\templates.py
	c:\python26\python ..\makepe.py regdumplib.asm
