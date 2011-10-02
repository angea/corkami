all: common XP W7

common: tls.exe tls_obfuscation.exe 96emptysections.exe 96workingsections.exe imports dll

dll: dll.dll dll-ld.exe dll-dynld.exe dllweirdexp.dll dllweirdexp-ld.exe dllemptyexp.dll dllemptyexp-ld.exe \
    dllord.dll dllord-ld.exe dll-dynunicld.exe dllnoreloc.dll dllnoreloc-ld.exe dllnoexp.dll dllnoexp-dynld.exe \
    dllfw.dll dllfw-ld.exe dllfwloop.dll dllfwloop-ld.exe dllbound.dll dllbound-ld.exe dllbound-redirld.exe \
    dll-webdavld.exe virtEP.exe pdf.exe tiny.exe ibnull.exe ibkernel.exe reloccrypt.exe exportobf.exe bigsec.exe \
    normal.exe truncatedlast.exe dupsec.exe appendedsecttbl.exe appendedhdr.exe footer.exe bottomsecttbl.exe duphead.exe \
    dllbound2.dll dllbound-redirld2.exe slackspace.exe dllextep.dll dllextep-ld.exe nullEP.exe delayimports.exe

imports: imports.exe imports_noint.exe imports_noext.exe imports_mixed.exe

XP: tinyXP.exe maxsecXP.exe nosectionXP.exe nullSOH-XP.exe virtsectblXP.exe tinydllXP.dll tinydllXP-ld.exe

W7: tinyW7.exe tinyW7x64.exe tinyW7_3264.exe maxsec_lowaligW7.exe nosectionW7.exe maxsecW7.exe

%.exe: ..\%.asm
	yasm -o $@ $<

%.dll: ..\%.asm
	yasm -o $@ $<
