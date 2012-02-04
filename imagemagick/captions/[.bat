@echo off
if exist _ex*.gif del _ex*.gif
..\convert %1 +adjoin _ex%%02d.gif
dir /b _ex*.gif
echo ..\tse last "<end>"
echo green+title, ..., last event, last even with no caption, (red+end)x2