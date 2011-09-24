@for %%i in (*.asm) do @yasm -o %%~ni.exe %%i
@move /y dll.exe dll.dll