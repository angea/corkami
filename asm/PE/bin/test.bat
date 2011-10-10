@echo off
echo normal.exe:& normal.exe
echo compiled.exe:& compiled.exe
echo truncsectbl.exe:& truncsectbl.exe
echo bigalign.exe
echo.
echo PE with many sections:
echo 96emptysections.exe:& 96emptysections.exe
echo 96workingsections.exe:& 96workingsections.exe
echo.
echo TLS:
echo tls.exe:& tls.exe
rem echo tls_import.exe:& tls_import.exe displayed afterwards, but working
echo tls_onthefly.exe:& tls_onthefly.exe
echo tls_obfuscation.exe:& tls_obfuscation.exe
echo exportobf.exe:& exportobf.exe
echo exportsdata.exe:& exportsdata.exe
echo.
echo Imports loading:
echo imports.exe:& imports.exe
echo imports_noint.exe:& imports_noint.exe
echo imports_noext.exe:& imports_noext.exe
echo imports_mixed.exe:& imports_mixed.exe
echo importshint.exe:& importshint.exe
echo impbyord.exe:& impbyord.exe
echo.
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
echo ownexports.exe:& ownexports.exe
echo.
echo export forwarding:
echo dllfw-ld.exe:& dllfw-ld.exe
echo dllfwloop-ld.exe:& dllfwloop-ld.exe
echo.
echo bound imports:
echo dllbound-ld.exe:& dllbound-ld.exe
echo dllbound-redirld.exe:& dllbound-redirld.exe
echo.
echo tiny PE
echo tiny.exe:& tiny.exe
echo.
echo ImageBase:
echo ibkernel.exe:& ibkernel.exe
echo bigib.exe:& bigib.exe
echo reloccrypt.exe:& reloccrypt.exe
echo.
echo EntryPoint:
echo nullEP.exe:& nullEP.exe
echo virtEP.exe:& virtEP.exe
echo dllextep-ld.exe:& dllextep-ld.exe
echo.
echo sections:
echo bigsec.exe:& bigsec.exe
echo dupsec.exe:& dupsec.exe
echo duphead.exe:& duphead.exe
echo secinsec:& secinsec.exe
echo appendedsecttbl.exe:& appendedsecttbl.exe
echo appendedhdr.exe:& appendedhdr.exe
echo footer.exe:& footer.exe
echo bottomsecttbl.exe:& bottomsecttbl.exe
echo truncatedlast.exe:& truncatedlast.exe
echo shuffledsect.exe:& shuffledsect.exe
echo.
echo gaps:
echo slackspace.exe:& slackspace.exe
echo appendeddata.exe:& appendeddata.exe
echo hiddenappdata1.exe:& hiddenappdata1.exe
echo hiddenappdata2.exe:& hiddenappdata2.exe
echo virtgap.exe:& virtgap.exe
echo foldedhdr.exe:& foldedhdr.exe
echo.
echo resources:
echo resource.exe:& resource.exe
echo resource2.exe:& resource2.exe
echo namedresource.exe:& namedresource.exe
echo reshdr.exe:& reshdr.exe
echo resourceloop.exe:& resourceloop.exe
rem dll-webdavld.exe disabled until found a suitable host
rem pdf.exe disabled because of the non-console output
rem delayimports broken ATM
rem quine.exe disabled because creates an extra window
