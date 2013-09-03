@echo off
del PE /q /s
rd PE
set today=%date:~-4%%date:~-10,2%%date:~-7,2%
svn export http://corkami.googlecode.com/svn/trunk/src/PE PE --force
svn export http://corkami.googlecode.com/svn/wiki/PE.wiki PE\PE.wiki
wget "https://code.google.com/p/corkami/wiki/PE?show=content"
move "PE@show=content" PE\PE.html
svn info http://corkami.googlecode.com/svn/trunk/src/PE > PE\info
cd PE\bin
call make
:call test > test.txt
:bin.sha
cd ..
"c:\program files\winrar\rar.exe" a ..\CPC-%today%-r.rar -r -m5 -s
cd ..
svn info http://corkami.googlecode.com/svn/trunk/src/PE
echo CPC-%today%-r
