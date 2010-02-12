python = c:\Python26\python.exe
masmdir = c:\masm32\bin
makepe = $(python) ..\makepe.py

examples = compiled.exe tls_import.exe mz.exe \
	undoc.exe helloworld-masm.exe gs.exe console.exe \
	driver.sys smsw.exe exehw.exe exetiny.exe tinype.exe \
	seh_dll.dll seh_loader.exe tls_standard.exe tls_fake.exe \
	tls_no_user32.exe tls_on_the_fly.exe block.exe \
	helloworld.exe sectionless.exe collapsed.exe \
	duplicate_section.exe whole_pe_section.exe jumps.exe \
	piotr.exe self_generating.exe opcodes32pe.exe loops.exe \
	opcodes32 no_relocs.dll no_relocs_loader.exe \
	no_relocs_tls_loader.exe stack.exe fibonacci.exe \
	subleq.exe tta.exe x86.exe com.com \
	forwarder.dll forwarded.exe own_exports.exe \
	no_exports.dll no_exports_loader.exe

# eicar.com # removed to prevent your AV from acting

objects = fibonacci.obj stack.obj subleq.obj tta.obj x86.obj \
	helloworld-masm.obj

all: $(examples)

standard.asm: ../consts.asm

#This is not a pipe
eicar.com: ../../eicar.asm
	yasm -o eicar.com ../../eicar.asm

#when VMs have only one opcode...
fibonacci.exe: ..\..\fibo\fibonacci.asm
	$(masmdir)\ml /c /Zi /coff ..\..\fibo\fibonacci.asm
	$(masmdir)\Link /SUBSYSTEM:WINDOWS fibonacci.obj /SECTION:smc,ERW
x86.exe: ..\..\fibo\x86.asm
	$(masmdir)\ml /c /Zi /coff ..\..\fibo\x86.asm
	$(masmdir)\Link /SUBSYSTEM:WINDOWS x86.obj /SECTION:smc,ERW
stack.exe: ..\..\fibo\stack.asm
	$(masmdir)\ml /c /Zi /coff ..\..\fibo\stack.asm
	$(masmdir)\Link /SUBSYSTEM:WINDOWS stack.obj /SECTION:smc,ERW
tta.exe: ..\..\fibo\tta.asm
	$(masmdir)\ml /c /Zi /coff ..\..\fibo\tta.asm
	$(masmdir)\Link /SUBSYSTEM:WINDOWS tta.obj /SECTION:smc,ERW
subleq.exe: ..\..\fibo\subleq.asm
	$(masmdir)\ml /c /Zi /coff ..\..\fibo\subleq.asm
	$(masmdir)\Link /SUBSYSTEM:WINDOWS subleq.obj /SECTION:smc,ERW

#when CPUs have too many opcodes...
opcodes32: ../makepe.py ../onesec.hdr ../../opcodes32.asm
	yasm ../../opcodes32.asm
opcodes32pe.exe: ../makepe.py ../onesec.hdr opcodes32pe.asm ../../opcodes32.asm
	$(python) ../makepe.py opcodes32pe.asm

#You'll stumble in my footsteps
piotr.exe: ../makepe.py ../onesec.hdr piotr.asm
	$(python) ../makepe.py piotr.asm

#Useless but original
block.exe: ../makepe.py ../onesec.hdr block.asm
	$(python) ../makepe.py block.asm

#Storm warning, but there's no fear
self_generating.exe: ../makepe.py ../onesec.hdr self_generating.asm
	$(python) ../makepe.py self_generating.asm

#They say jump, you say how high
jumps.exe: ../makepe.py ../onesec.hdr jumps.asm
	$(python) ../makepe.py jumps.asm

#Hey, hey, hey, what's in your head?
collapsed.exe: ../makepe.py ../consts.asm collapsed.asm
	$(python) ../makepe.py collapsed.asm
helloworld.exe: ../makepe.py ../onesec.hdr helloworld.asm
	$(python) ../makepe.py helloworld.asm

#With a rebel yell! more, more, more!
compiled.exe: compiled.asm ../makepe.py ../consts.asm ../makepe.py
	$(makepe) compiled.asm
helloworld-masm.exe: helloworld-masm.asm
	$(masmdir)\ml /c /Zi /coff helloworld-masm.asm
	$(masmdir)\Link /SUBSYSTEM:WINDOWS helloworld-masm.obj

#If you got the money honey, we got your disease
no_relocs.dll: ../standard_ftr.asm ../standard_hdr.asm ../makepe.py no_relocs.asm
	$(makepe) no_relocs.asm
no_relocs_loader.exe: ../standard_ftr.asm ../standard_hdr.asm ../makepe.py no_relocs_loader.asm
	$(makepe) no_relocs_loader.asm
# not in the post ?
no_relocs_tls_loader.exe: ../standard_ftr.asm ../standard_hdr.asm ../makepe.py no_relocs_tls_loader.asm
	$(makepe) no_relocs_tls_loader.asm

#Sail to the edge and I'd be there
tls_standard.exe: ../standard_ftr.asm ../standard_hdr.asm ../makepe.py tls_standard.asm
	$(makepe) tls_standard.asm
tls_fake.exe: ../standard_ftr.asm ../standard_hdr.asm ../makepe.py tls_fake.asm
	$(makepe) tls_fake.asm
tls_on_the_fly.exe: ../standard_ftr.asm ../standard_hdr.asm ../makepe.py tls_on_the_fly.asm
	$(makepe) tls_on_the_fly.asm
tls_no_user32.exe: ../standard_ftr.asm ../standard_hdr.asm ../makepe.py tls_no_user32.asm
	$(makepe) tls_no_user32.asm

#You can rock this land, baby
console.exe: console.asm ../standard_ftr.asm ../standard_hdr.asm ../makepe.py
	$(makepe) console.asm
driver.sys: driver.asm ../standard_ftr.asm ../standard_hdr.asm ../makepe.py
	$(makepe) driver.asm

#The hen never laid and the corn never growed
gs.exe: ../makepe.py ../onesec.hdr gs.asm
	$(python) ../makepe.py gs.asm

#Policeman got no gun, U don't have 2 run
smsw.exe: smsw.asm ../standard_ftr.asm ../standard_hdr.asm ../makepe.py
	$(makepe) smsw.asm

#On aura plus de pain sur la planche, parce que la planche aura brûlé
duplicate_section.exe: ../makepe.py ../consts.asm duplicate_section.asm
	$(python) ../makepe.py duplicate_section.asm
whole_pe_section.exe: ../makepe.py ../consts.asm whole_pe_section.asm
	$(python) ../makepe.py whole_pe_section.asm

#It's just a flesh wound
sectionless.exe: ../makepe.py ../consts.asm sectionless.asm
	$(python) ../makepe.py sectionless.asm

#Et puis celles qu'on doit pas...
undoc.exe: ../makepe.py ../onesec.hdr undoc.asm
	$(makepe) undoc.asm

#If you want to strike me down in anger
loops.exe: ../makepe.py ../onesec.hdr loops.asm
	$(python) ../makepe.py loops.asm

#Militant quotidien de l'inhumanité
tls_import.exe: tls_import.asm ..\makepe.py ..\consts.asm ../standard_ftr.asm ../makepe.py
	$(makepe) tls_import.asm
mz.exe: compiled.exe
	copy compiled.exe mz.exe

seh_dll.dll: ../standard_ftr.asm ../standard_hdr.asm ../makepe.py seh_dll.asm
	$(makepe) seh_dll.asm
seh_loader.exe: ../standard_ftr.asm ../standard_hdr.asm ../makepe.py seh_loader.asm
	$(makepe) seh_loader.asm

com.com: ../consts.asm com.asm
	yasm -o com.com com.asm

exehw.exe: ../makepe.py ../consts.asm exehw.asm
	yasm -o exehw.exe exehw.asm
exetiny.exe: ../makepe.py ../consts.asm exetiny.asm
	yasm -o exetiny.exe exetiny.asm

tinype.exe: ../makepe.py ../consts.asm tinype.asm
	yasm -o tinype.exe tinype.asm

forwarder.dll: ../standard_ftr.asm ../standard_hdr.asm ../makepe.py forwarder.asm
	$(makepe) forwarder.asm
forwarded.exe: ../standard_ftr.asm ../standard_hdr.asm ../makepe.py forwarded.asm
	$(makepe) forwarded.asm

own_exports.exe: ../standard_ftr.asm ../standard_hdr.asm ../makepe.py own_exports.asm
	$(makepe) own_exports.asm

no_exports.dll: ../standard_ftr.asm ../standard_hdr.asm ../makepe.py no_exports.asm
	$(makepe) no_exports.asm
no_exports_loader.exe: ../standard_ftr.asm ../standard_hdr.asm ../makepe.py no_exports_loader.asm
	$(makepe) no_exports_loader.asm

clean:
	rm $(examples) $(objects)