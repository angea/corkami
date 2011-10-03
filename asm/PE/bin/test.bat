@echo off
echo normal.exe:& normal.exe
echo PE with many sections:
echo 96emptysections.exe:& 96emptysections.exe
echo 96workingsections.exe:& 96workingsections.exe
echo TLS:
echo tls.exe:& tls.exe
echo tls_import.exe:& tls_import.exe
echo tls_onthefly.exe:& tls_onthefly.exe
echo tls_obfuscation.exe:& tls_obfuscation.exe
echo exportobf.exe:& exportobf.exe
echo Imports loading:
echo imports.exe:& imports.exe
echo imports_noint.exe:& imports_noint.exe
echo imports_noext.exe:& imports_noext.exe
echo imports_mixed.exe:& imports_mixed.exe
echo DLL loading:
echo  * statically loaded DLL and export call
echo dll-ld.exe:& dll-ld.exe
echo dll-dynld.exe:& dll-dynld.exe
echo dll-dynunicld.exe:& dll-dynunicld.exe
echo dllweirdexp-ld.exe:& dllweirdexp-ld.exe
echo dllemptyexp-ld.exe:& dllemptyexp-ld.exe
echo dllord-ld.exe:& dllord-ld.exe
echo dllnoreloc-ld.exe:& dllnoreloc-ld.exe
echo dllnoexp-dynld.exe:& dllnoexp-dynld.exe
echo export forwarding:
echo dllfw-ld.exe:& dllfw-ld.exe
echo dllfwloop-ld.exe:& dllfwloop-ld.exe
echo bound imports:
echo dllbound-ld.exe:& dllbound-ld.exe
echo dllbound-redirld.exe:& dllbound-redirld.exe
echo dllbound-redirld2.exe:& dllbound-redirld2.exe
echo tiny PE
echo tiny.exe:& tiny.exe
echo ImageBase:
echo ibnull.exe:& ibnull.exe
echo ibkernel.exe:& ibkernel.exe
echo reloccrypt.exe:& reloccrypt.exe
echo EntryPoint:
echo nullEP.exe:& nullEP.exe
echo virtEP.exe:& virtEP.exe
echo dllextep-ld.exe:& dllextep-ld.exe
echo sections:
echo bigsec.exe:& bigsec.exe
echo dupsec.exe:& dupsec.exe
echo appendedsecttbl.exe:& appendedsecttbl.exe
echo appendedhdr.exe:& appendedhdr.exe
echo footer.exe:& footer.exe
echo bottomsecttbl.exe:& bottomsecttbl.exe
echo truncatedlast.exe:& truncatedlast.exe
echo shuffledsect.exe:& shuffledsect.exe
rem duphead.exe (broken ATM)
rem slackspace.exe (broken ATM)
rem dll-webdavld.exe disabled until found a suitable host
rem pdf.exe disabled because of the non-console output
rem delayimports broken ATM
