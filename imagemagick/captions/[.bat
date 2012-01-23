@echo off
if exist _ex*.gif del _ex*.gif
..\convert %1 +adjoin _ex%%01d.gif
call tse.bat 0 "<start>"
echo tse last "<end>"
dir /b _ex*.gif