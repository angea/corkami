@echo off
echo PE with many sections:
96emptysections.exe
96workingsections.exe
echo TLS:
tls.exe
tls_obfuscation.exe
exportobf.exe
echo Imports loading:
imports.exe
imports_noint.exe
imports_noext.exe
imports_mixed.exe
echo DLL loading:
echo  * statically loaded DLL and export call
dll-ld.exe
dll-dynld.exe
dll-dynunicld.exe

rem disabled until found a suitable host
rem dll-webdavld.exe

rem disabled because of the non-console output
rem pdf.exe

dllweirdexp-ld.exe
dllemptyexp-ld.exe
dllord-ld.exe
dllnoreloc-ld.exe
dllnoexp-dynld.exe
echo export forwarding:
dllfw-ld.exe
dllfwloop-ld.exe
echo bound imports:
dllbound-ld.exe
dllbound-redirld.exe
echo tiny PE
tiny.exe
echo ImageBase:
ibnull.exe
ibkernel.exe
reloccrypt.exe
echo EntryPoint:
virtEP.exe
