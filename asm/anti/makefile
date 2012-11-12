all: isdebuggerpresent2.exe isdebuggerpresent.exe BeingDebugged.exe

%.exe: %.c
	gcc -O1 $< -s -nostartfiles -luser32 -fomit-frame-pointer -o $@
