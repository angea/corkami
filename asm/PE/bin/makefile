all: common XP W7

beta:

common: imports dll gaps tls bound entrypoint down many misc resource delay

many: 96emptysections.exe 96workingsections.exe bigSoRD.exe

dll: dll.dll dll-ld.exe dll-dynld.exe dllweirdexp.dll dllweirdexp-ld.exe dllemptyexp.dll \
    dllemptyexp-ld.exe dllord.dll dllord-ld.exe dll-dynunicld.exe dllnoreloc.dll dllnoreloc-ld.exe \
    dllnoexp.dll dllnoexp-dynld.exe dllfw.dll dllfw-ld.exe dllfwloop.dll dllfwloop-ld.exe \
    dll-webdavld.exe dupsec.exe ibkernel.exe reloccrypt.exe exportobf.exe importshint.exe \
    secinsec.exe bigib.exe

misc: normal.exe truncatedlast.exe pdf.exe tiny.exe bigsec.exe shuffledsect.exe truncsectbl.exe \
    quine.exe ownexports.exe bigalign.exe exportsdata.exe foldedhdr.exe compiled.exe duphead.exe

down: appendedsecttbl.exe appendedhdr.exe footer.exe bottomsecttbl.exe

entrypoint: virtEP.exe dllextep.dll dllextep-ld.exe nullEP.exe

bound: dllbound.dll dllbound-ld.exe dllbound-redirld.exe

tls: tls.exe tls_obfuscation.exe tls_import.exe mz.exe tls_onthefly.exe tls_aoi.exe tls_aoiOSDET.exe

delay: delayimports.exe delaycorrupt.exe

gaps: appendeddata.exe hiddenappdata1.exe hiddenappdata2.exe slackspace.exe virtgap.exe

resource: resource.exe resource2.exe reshdr.exe namedresource.exe resourceloop.exe

imports: imports.exe imports_noint.exe imports_noext.exe imports_mixed.exe impbyord.exe \
    imports_badterm.exe manyimportsW7.exe

XP: tinyXP.exe maxsecXP.exe nosectionXP.exe nullSOH-XP.exe virtsectblXP.exe tinydllXP.dll \
    tinydllXP-ld.exe ibnullXP.exe dllbound-redirldXP.exe dllbound2.dll reloccryptXP.exe \
    dosZMXP.exe driver.sys

W7: tinyW7.exe tinyW7x64.exe tinyW7_3264.exe maxsec_lowaligW7.exe nosectionW7.exe maxsecW7.exe \
    appsectableW7.exe apphdrW7.exe foldedhdrW7.exe normal64.exe 65535sects.exe

65535sects.exe: ..\mkpe.py
	c:\python26\python ..\mkpe.py 65535

%.exe: ..\%.asm
	yasm -o $@ $<

%.dll: ..\%.asm
	yasm -o $@ $<

%.sys: ..\%.asm
	yasm -o $@ $<
