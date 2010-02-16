python = c:\Python26\python.exe
masmdir = c:\masm32\bin
ml = $(masmdir)\ml /c /Zi /coff
mlink = $(masmdir)\Link /SUBSYSTEM:WINDOWS
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
	no_exports.dll no_exports_loader.exe \
	driver.exe driver-noimports.exe ntoskrnl.exe \
	exceptions.exe tls_zeroes.exe waitable.exe

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
	$(ml) ..\..\fibo\fibonacci.asm
	$(mlink) fibonacci.obj /SECTION:smc,ERW
x86.exe: ..\..\fibo\x86.asm
	$(ml) ..\..\fibo\x86.asm
	$(mlink) x86.obj /SECTION:smc,ERW
stack.exe: ..\..\fibo\stack.asm
	$(ml) ..\..\fibo\stack.asm
	$(mlink) stack.obj /SECTION:smc,ERW
tta.exe: ..\..\fibo\tta.asm
	$(ml) ..\..\fibo\tta.asm
	$(mlink) tta.obj /SECTION:smc,ERW
subleq.exe: ..\..\fibo\subleq.asm
	$(ml) ..\..\fibo\subleq.asm
	$(mlink) subleq.obj /SECTION:smc,ERW

#when CPUs have too many opcodes...
opcodes32: ../../opcodes32.asm
	yasm ../../opcodes32.asm
opcodes32pe.exe: opcodes32pe.asm ../../opcodes32.asm
	$(makepe) opcodes32pe.asm

#You'll stumble in my footsteps
piotr.exe: piotr.asm
	$(makepe) piotr.asm

#Useless but original
block.exe: block.asm
	$(makepe) block.asm

#Storm warning, but there's no fear
self_generating.exe: self_generating.asm
	$(makepe) self_generating.asm

#They say jump, you say how high
jumps.exe: jumps.asm
	$(makepe) jumps.asm

#Hey, hey, hey, what's in your head?
collapsed.exe: ../consts.asm collapsed.asm
	$(makepe) collapsed.asm
helloworld.exe: helloworld.asm
	$(makepe) helloworld.asm

#With a rebel yell! more, more, more!
compiled.exe: compiled.asm ../consts.asm
	$(makepe) compiled.asm
helloworld-masm.exe: helloworld-masm.asm
	$(ml) helloworld-masm.asm
	$(mlink) helloworld-masm.obj

#If you got the money honey, we got your disease
no_relocs.dll: no_relocs.asm
	$(makepe) no_relocs.asm
no_relocs_loader.exe: no_relocs_loader.asm
	$(makepe) no_relocs_loader.asm
# not in the post ?
no_relocs_tls_loader.exe: no_relocs_tls_loader.asm
	$(makepe) no_relocs_tls_loader.asm

#Sail to the edge and I'd be there
tls_standard.exe: tls_standard.asm
	$(makepe) tls_standard.asm
tls_fake.exe: tls_fake.asm
	$(makepe) tls_fake.asm
tls_on_the_fly.exe: tls_on_the_fly.asm
	$(makepe) tls_on_the_fly.asm
tls_no_user32.exe: tls_no_user32.asm
	$(makepe) tls_no_user32.asm

#You can rock this land, baby
console.exe: console.asm
	$(makepe) console.asm
driver.sys: driver.asm
	$(makepe) driver.asm

#The hen never laid and the corn never growed
gs.exe: gs.asm
	$(makepe) gs.asm

#Policeman got no gun, U don't have 2 run
smsw.exe: smsw.asm
	$(makepe) smsw.asm

#On aura plus de pain sur la planche, parce que la planche aura brûlé
duplicate_section.exe: duplicate_section.asm
	$(makepe) duplicate_section.asm
whole_pe_section.exe: whole_pe_section.asm
	$(makepe) whole_pe_section.asm

#It's just a flesh wound
sectionless.exe: sectionless.asm
	$(makepe) sectionless.asm

#Et puis celles qu'on doit pas...
undoc.exe: undoc.asm
	$(makepe) undoc.asm

#If you want to strike me down in anger
loops.exe: loops.asm
	$(makepe) loops.asm

#Militant quotidien de l'inhumanité
tls_import.exe: tls_import.asm
	$(makepe) tls_import.asm
mz.exe: compiled.exe
	copy compiled.exe mz.exe

seh_dll.dll: seh_dll.asm
	$(makepe) seh_dll.asm
seh_loader.exe: seh_loader.asm
	$(makepe) seh_loader.asm

com.com: com.asm
	yasm -o com.com com.asm

exehw.exe: exehw.asm
	yasm -o exehw.exe exehw.asm
exetiny.exe: exetiny.asm
	yasm -o exetiny.exe exetiny.asm

tinype.exe: tinype.asm
	yasm -o tinype.exe tinype.asm

forwarder.dll: forwarder.asm
	$(makepe) forwarder.asm
forwarded.exe: forwarded.asm
	$(makepe) forwarded.asm

own_exports.exe: own_exports.asm
	$(makepe) own_exports.asm

no_exports.dll: no_exports.asm
	$(makepe) no_exports.asm
no_exports_loader.exe: no_exports_loader.asm
	$(makepe) no_exports_loader.asm

driver.exe: driver.sys
	$(python) sys2exe.py driver.sys
driver-noimports.exe: driver.sys
	$(python) sys2exe.py driver.sys
ntoskrnl.exe: ntoskrnl.asm
	$(makepe) ntoskrnl.asm

exceptions.exe: exceptions.asm
	$(makepe) exceptions.asm

tls_zeroes.exe: tls_zeroes.asm
	$(makepe) tls_zeroes.asm

waitable.exe: waitable.asm
	$(makepe) waitable.asm

clean:
	rm $(examples) $(objects)