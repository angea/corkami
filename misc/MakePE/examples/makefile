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
	no_relocs_tls_loader.exe \
	fibo\stack.exe fibo\standard.exe fibo\subleq.exe fibo\tta.exe fibo\x86.exe \
	com.com \
	forwarder.dll forwarded.exe own_exports.exe \
	no_exports.dll no_exports_loader.exe \
	driver.exe driver-ni.ex ntoskrnl.exe \
	exceptions.exe tls_zeroes.exe waitable.exe vmware.exe \
	packed_driver.sys packed_driver.exe packed_driver-ni.ex \
	imports_manual.exe imports_custom.exe imports_fsg.exe \
	imports_junk.exe imports_checksum.exe imports_stolen.exe \
	imports_hooks.exe imports_paramdp.exe imports_ipdp.exe \
	bundled_before.exe bundled_after.exe \
	thread_host.exe remote_thread.exe \
	funnyseh.exe getip.exe \
	prng.exe xor.exe rc4.exe \
	dll.dll loader.exe manual_loader.exe packed_loader.exe packed_dll.dll \
	packer\eppatched.exe packer\mutated.exe packer\protected.exe packer\virtualized.exe packer\crypted.exe

; packer\compressed.exe needs Kabopan

# eicar.com # removed to prevent your AV from acting

objects = helloworld-masm.obj

all: $(examples)

standard.asm: ../consts.asm

#This is not a pipe
eicar.com: ../../eicar.asm
	yasm -o eicar.com ../../eicar.asm

#when VMs have only one opcode...
fibo\standard.exe: fibo\standard.asm
	$(makepe) fibo\standard.asm
fibo\x86.exe: fibo\x86.asm
	$(makepe) fibo\x86.asm
fibo\stack.exe: fibo\stack.asm
	$(makepe) fibo\stack.asm
fibo\tta.exe: fibo\tta.asm
	$(makepe) fibo\tta.asm
fibo\subleq.exe: fibo\subleq.asm
	$(makepe) fibo\subleq.asm

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

#Happa ichimai areba ii
driver.exe: driver.sys
	$(python) sys2exe.py driver.sys
driver-ni.ex: driver.sys
	$(python) sys2exe.py driver.sys
ntoskrnl.exe: ntoskrnl.asm
	$(makepe) ntoskrnl.asm
	ren ntoskrnl.dll ntoskrnl.exe

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

exceptions.exe: exceptions.asm
	$(makepe) exceptions.asm

tls_zeroes.exe: tls_zeroes.asm
	$(makepe) tls_zeroes.asm

waitable.exe: waitable.asm
	$(makepe) waitable.asm

vmware.exe: vmware.asm
	$(makepe) vmware.asm

packed_driver.sys: packed_driver.asm
	$(makepe) packed_driver.asm
packed_driver.exe: packed_driver.sys
	$(python) sys2exe.py packed_driver.sys
packed_driver-ni.ex: packed_driver.sys
	$(python) sys2exe.py packed_driver.sys

imports_checksum.exe: imports_checksum.asm
	$(makepe) imports_checksum.asm
imports_custom.exe: imports_custom.asm
	$(makepe) imports_custom.asm
imports_fsg.exe: imports_fsg.asm
	$(makepe) imports_fsg.asm
imports_hooks.exe: imports_hooks.asm
	$(makepe) imports_hooks.asm
imports_ipdp.exe: imports_ipdp.asm
	$(makepe) imports_ipdp.asm
imports_junk.exe: imports_junk.asm
	$(makepe) imports_junk.asm
imports_manual.exe: imports_manual.asm
	$(makepe) imports_manual.asm
imports_paramdp.exe: imports_paramdp.asm
	$(makepe) imports_paramdp.asm
imports_stolen.exe: imports_stolen.asm
	$(makepe) imports_stolen.asm

bundled_before.exe: bundled_before.asm
	$(makepe) bundled_before.asm
bundled_after.exe: bundled_after.asm
	$(makepe) bundled_after.asm

remote_thread.exe: remote_thread.asm
	$(makepe) remote_thread.asm
thread_host.exe: thread_host.asm
	$(makepe) thread_host.asm

funnyseh.exe: funnyseh.asm
	$(makepe) funnyseh.asm

getip.exe: getip.asm
	$(makepe) getip.asm

prng.exe: prng.asm
	$(makepe) prng.asm
rc4.exe: rc4.asm
	$(makepe) rc4.asm
xor.exe: xor.asm
	$(makepe) xor.asm

dll.dll: dll.asm
	$(makepe) dll.asm
packed_dll.dll: packed_dll.asm
	$(makepe) packed_dll.asm
loader.exe: loader.asm
	$(makepe) loader.asm
packed_loader.exe: packed_loader.asm
	$(makepe) packed_loader.asm
manual_loader.exe: manual_loader.asm
	$(makepe) manual_loader.asm

packer\eppatched.exe: compiled.exe packer\eppatcher.py
	cd packer & $(python) eppatcher.py
packer\crypted.exe: compiled.exe packer\crypter.py
	cd packer & $(python) crypter.py
packer\compressed.exe: compiled.exe packer\compressed.py
	cd packer & $(python) compresser.py
packer\protected.exe: compiled.exe packer\protecter.py
	cd packer & $(python) protecter.py
packer\mutated.exe: compiled.exe packer\mutater.py
	cd packer & $(python) mutater.py
packer\virtualized.exe: compiled.exe packer\virtualizer.py
	cd packer & $(python) virtualizer.py

clean:
	rm $(examples) $(objects)