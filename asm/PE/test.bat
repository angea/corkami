@echo off
echo PE with many sections:
96emptysections.exe
96workingsections.exe
echo TLS:
tls.exe
tls_obfuscation.exe
echo Imports loading:
imports.exe
imports_noint.exe
imports_noext.exe
imports_mixed.exe
echo DLL loading:
echo  * statically loaded DLL and export call
dll-ld.exe
dll-dynld.exe
dllweirdexp-ld.exe
dllemptyexp-ld.exe
dllord-ld.exe
dll-dynunicld.exe
dllnoreloc-ld.exe