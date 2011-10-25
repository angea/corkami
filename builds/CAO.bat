@echo off
del x86odd /q /s
rd x86odd
set today=%date:~-4%%date:~-10,2%%date:~-7,2%
svn export http://corkami.googlecode.com/svn/trunk/asm/x86odd x86odd --force
cd x86odd\bin
call make
:call test > test.txt
:bin.sha
cd ..
"c:\program files\winrar\rar.exe" a ..\CAO-%today%-r.rar -r -m5 -s
cd ..
svn info http://corkami.googlecode.com/svn/trunk/asm/x86odd
echo CAO-%today%-r
