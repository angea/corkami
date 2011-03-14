include paths.inc

ml = $(masmdir)\ml /c /Zi /coff
mlink = $(masmdir)\Link /SUBSYSTEM:WINDOWS
makepe = $(python) ..\makepe.py

examples = pe\compiled.exe pe\tls_import.exe pe\mz.exe \
	pe\helloworld-masm.exe pe\console.exe \
	anti\smsw.exe anti\gs.exe anti\misc.exe \
	pe\driver.sys pe\tinype.exe \
	pe\seh_dll.dll pe\seh_loader.exe pe\tls_standard.exe pe\tls_fake.exe \
	pe\tls_no_user32.exe pe\tls_on_the_fly.exe \
	pe\helloworld.exe pe\sectionless.exe pe\collapsed.exe \
	pe\duplicate_section.exe pe\whole_pe_section.exe \
	asm\piotr.exe asm\self_generating.exe asm\loops.exe asm\jumps.exe asm\block.exe \
	asm\opcodes32.bin asm\opcodes32pe.exe asm\undoc.exe \
	asm\seh_triggers.exe asm\getip.exe \
	asm\inline_strings.exe asm\stack_strings.exe \
	pe\no_relocs.dll pe\no_relocs_loader.exe \
	pe\no_relocs_tls_loader.exe \
	pe\forwarder.dll pe\forwarded.exe pe\own_exports.exe \
	pe\no_exports.dll pe\no_exports_loader.exe \
	pe\driver.exe pe\driver-ni.ex pe\ntoskrnl.exe \
	pe\tls_zeroesSEH.exe pe\tls_zeroesmemnull.exe \
	pe\dll.dll pe\loader.exe pe\manual_loader.exe \
	VMs\stack.exe VMs\standard.exe VMs\subleq.exe VMs\tta.exe VMs\x86.exe \
	format\com.com format\exehw.exe format\exetiny.exe \
	imports\imports_manual.exe imports\imports_custom.exe imports\imports_fsg.exe \
	imports\imports_junk.exe imports\imports_checksum.exe imports\imports_stolen.exe \
	imports\imports_hooks.exe imports\imports_paramdp.exe imports\imports_ipdp.exe \
	imports\imports_buffer.exe \
	algo\prng.exe algo\xor.exe algo\rc4.exe \
	funnyseh.exe \
	packer\packed_loader.exe packer\packed_dll.dll \
	packer\packed_driver.sys packer\packed_driver.exe packer\packed_driver-ni.ex \
	packer\bundled_before.exe packer\bundled_after.exe \
	packer\thread_host.exe packer\remote_thread.exe \
	packer\eppatched.exe packer\mutated.exe packer\protected.exe packer\virtualized.exe packer\crypted.exe \
	packer\dropper.exe packer\suspended_process.exe packer\resource_dropper.exe \
	asm\opcodes_desc.exe \
	asm\crypted_strings.exe \
	anti\int2a_loop.exe \
	pe\hal.dll \
	pe\classpnp.sys \
	pe\resource_loop.exe \
	pe\resource_fail7.exe \
	pe\resource_shuffled.exe \
	anti\flow.exe \
	imports\kernel31.dll \
	imports\kernel31.asm \
	imports\kernel31_test.exe \
	asm\rel_ip.exe \
	imports\imports_doublesum.exe \
	pe\helloworld64.exe pe\max_sec.exe pe\max_secXP.exe \
	pe\delayimports.exe pe\shelload.exe \
	asm\mmx.exe asm\sse.exe asm\fpu.exe anti\fastpeblock.exe asm\small_sc.bin \
	asm\memscan.exe anti\lowlevel.exe anti\exception_skip.exe anti\exception_overwrite.exe \
    anti\hwbp.exe anti\tf_step.exe asm\vmware.exe anti\ollydbg.exe \
	pe\sect_phys_order.exe pe\imagebase_null.exe anti\dump.exe asm\apiloop.exe 

notworking = asm\memcopy.exe waitable.exe test.exe vms\binary.exe pe\multisub.exe asm\trampo1.exe 

# packer\compressed.exe needs Kabopan, not enabled by default
# eicar.com # removed to prevent your AV from acting

objects = helloworld-masm.obj

all: $(examples)

allp: $(examples) $(notworking)

#This is not a pipe
eicar.com: ../../eicar.asm
	yasm -o eicar.com ../../eicar.asm

#when VMs have only one opcode...
VMs\standard.exe: VMs\standard.asm
	$(makepe) VMs\standard.asm
VMs\x86.exe: VMs\x86.asm
	$(makepe) VMs\x86.asm
VMs\stack.exe: VMs\stack.asm
	$(makepe) VMs\stack.asm
VMs\tta.exe: VMs\tta.asm
	$(makepe) VMs\tta.asm
VMs\subleq.exe: VMs\subleq.asm
	$(makepe) VMs\subleq.asm

#when CPUs have too many opcodes...
asm\opcodes32.bin: asm\opcodes32.asm
	yasm asm\opcodes32.asm -o asm\opcodes32.bin
asm\opcodes32pe.exe: asm\opcodes32pe.asm asm\opcodes32.asm
	$(makepe) asm\opcodes32pe.asm

#You'll stumble in my footsteps
asm\piotr.exe: asm\piotr.asm
	$(makepe) asm\piotr.asm

#Useless but original
asm\block.exe: asm\block.asm
	$(makepe) asm\block.asm

#Storm warning, but there's no fear
asm\self_generating.exe: asm\self_generating.asm
	$(makepe) asm\self_generating.asm

#They say jump, you say how high
asm\jumps.exe: asm\jumps.asm
	$(makepe) asm\jumps.asm

#Hey, hey, hey, what's in your head?
pe\collapsed.exe: pe\collapsed.asm
	$(makepe) pe\collapsed.asm
pe\helloworld.exe: pe\helloworld.asm
	$(makepe) pe\helloworld.asm

#With a rebel yell! more, more, more!
pe\compiled.exe: pe\compiled.asm
	$(makepe) pe\compiled.asm
pe\helloworld-masm.exe: pe\helloworld-masm.asm
	$(ml) pe\helloworld-masm.asm
	$(mlink) helloworld-masm.obj
	mv helloworld-masm.exe pe\helloworld-masm.exe

#If you got the money honey, we got your disease
pe\no_relocs.dll: pe\no_relocs.asm
	$(makepe) pe\no_relocs.asm
pe\no_relocs_loader.exe: pe\no_relocs_loader.asm
	$(makepe) pe\no_relocs_loader.asm
# not in the post ?
pe\no_relocs_tls_loader.exe: pe\no_relocs_tls_loader.asm
	$(makepe) pe\no_relocs_tls_loader.asm

#Sail to the edge and I'd be there
pe\tls_standard.exe: pe\tls_standard.asm
	$(makepe) pe\tls_standard.asm
pe\tls_fake.exe: pe\tls_fake.asm
	$(makepe) pe\tls_fake.asm
pe\tls_on_the_fly.exe: pe\tls_on_the_fly.asm
	$(makepe) pe\tls_on_the_fly.asm
pe\tls_no_user32.exe: pe\tls_no_user32.asm
	$(makepe) pe\tls_no_user32.asm

#You can rock this land, baby
pe\console.exe: pe\console.asm
	$(makepe) pe\console.asm
pe\driver.sys: pe\driver.asm
	$(makepe) pe\driver.asm

#The hen never laid and the corn never growed
anti\gs.exe: anti\gs.asm
	$(makepe) anti\gs.asm

#Policeman got no gun, U don't have 2 run
anti\smsw.exe: anti\smsw.asm
	$(makepe) anti\smsw.asm

#On aura plus de pain sur la planche, parce que la planche aura brûlé
pe\duplicate_section.exe: pe\duplicate_section.asm
	$(makepe) pe\duplicate_section.asm
pe\whole_pe_section.exe: pe\whole_pe_section.asm
	$(makepe) pe\whole_pe_section.asm

#It's just a flesh wound
pe\sectionless.exe: pe\sectionless.asm
	$(makepe) pe\sectionless.asm

#Et puis celles qu'on doit pas...
asm\undoc.exe: asm\undoc.asm
	$(makepe) asm\undoc.asm

#If you want to strike me down in anger
asm\loops.exe: asm\loops.asm
	$(makepe) asm\loops.asm

#Militant quotidien de l'inhumanité
pe\tls_import.exe: pe\tls_import.asm
	$(makepe) pe\tls_import.asm
pe\mz.exe: pe\compiled.exe
	copy pe\compiled.exe pe\mz.exe

#Happa ichimai areba ii
pe\driver.exe: pe\driver.sys
	$(python) pe\sys2exe.py pe\driver.sys
pe\driver-ni.ex: pe\driver.sys
	$(python) pe\sys2exe.py pe\driver.sys
pe\ntoskrnl.exe: pe\ntoskrnl.asm
	$(makepe) pe\ntoskrnl.asm
	mv pe\ntoskrnl.dll pe\ntoskrnl.exe

#and when i start to come undone stitch me together
asm\seh_triggers.exe: asm\seh_triggers.asm
	$(makepe) asm\seh_triggers.asm

#si c'est ton corps qui bouge, c'est ton coeur qui fait tout
asm\getip.exe: asm\getip.asm
	$(makepe) asm\getip.asm

#You can't hide nowhere, with the torchlight on
pe\tinype.exe: pe\tinype.asm
	yasm -o pe\tinype.exe pe\tinype.asm

#Lutte contre les mots faciles, lutte contre la haine des ...
asm\opcodes_desc.exe: asm\opcodes_desc.asm
	$(makepe) asm\opcodes_desc.asm

pe\seh_dll.dll: pe\seh_dll.asm
	$(makepe) pe\seh_dll.asm
pe\seh_loader.exe: pe\seh_loader.asm
	$(makepe) pe\seh_loader.asm

format\com.com: format\com.asm
	yasm -o format\com.com format\com.asm

format\exehw.exe: format\exehw.asm
	yasm -o format\exehw.exe format\exehw.asm
format\exetiny.exe: format\exetiny.asm
	yasm -o format\exetiny.exe format\exetiny.asm

pe\forwarder.dll: pe\forwarder.asm
	$(makepe) pe\forwarder.asm
pe\forwarded.exe: pe\forwarded.asm
	$(makepe) pe\forwarded.asm

pe\own_exports.exe: pe\own_exports.asm
	$(makepe) pe\own_exports.asm

pe\no_exports.dll: pe\no_exports.asm
	$(makepe) pe\no_exports.asm
pe\no_exports_loader.exe: pe\no_exports_loader.asm
	$(makepe) pe\no_exports_loader.asm

pe\tls_zeroesSEH.exe: pe\tls_zeroesSEH.asm
	$(makepe) pe\tls_zeroesSEH.asm
pe\tls_zeroesmemnull.exe: pe\tls_zeroesmemnull.asm
	$(makepe) pe\tls_zeroesmemnull.asm

waitable.exe: waitable.asm
	$(makepe) waitable.asm

asm\vmware.exe: asm\vmware.asm
	$(makepe) asm\vmware.asm

packer\packed_driver.sys: packer\packed_driver.asm
	$(makepe) packer\packed_driver.asm
packer\packed_driver.exe: packer\packed_driver.sys
	$(python) pe\sys2exe.py packer\packed_driver.sys
packer\packed_driver-ni.ex: packer\packed_driver.sys
	$(python) pe\sys2exe.py packer\packed_driver.sys

imports\imports_buffer.exe: imports\imports_buffer.asm
	$(makepe) imports\imports_buffer.asm
imports\imports_checksum.exe: imports\imports_checksum.asm
	$(makepe) imports\imports_checksum.asm
imports\imports_custom.exe: imports\imports_custom.asm
	$(makepe) imports\imports_custom.asm
imports\imports_fsg.exe: imports\imports_fsg.asm
	$(makepe) imports\imports_fsg.asm
imports\imports_hooks.exe: imports\imports_hooks.asm
	$(makepe) imports\imports_hooks.asm
imports\imports_ipdp.exe: imports\imports_ipdp.asm
	$(makepe) imports\imports_ipdp.asm
imports\imports_junk.exe: imports\imports_junk.asm
	$(makepe) imports\imports_junk.asm
imports\imports_manual.exe: imports\imports_manual.asm
	$(makepe) imports\imports_manual.asm
imports\imports_paramdp.exe: imports\imports_paramdp.asm
	$(makepe) imports\imports_paramdp.asm
imports\imports_stolen.exe: imports\imports_stolen.asm
	$(makepe) imports\imports_stolen.asm

packer\remote_thread.exe: packer\remote_thread.asm
	$(makepe) packer\remote_thread.asm
packer\thread_host.exe: packer\thread_host.asm
	$(makepe) packer\thread_host.asm

funnyseh.exe: funnyseh.asm
	$(makepe) funnyseh.asm

algo\prng.exe: algo\prng.asm
	$(makepe) algo\prng.asm & cd algo & crypt.py prng.exe & cd ..
algo\rc4.exe: algo\rc4.asm
	$(makepe) algo\rc4.asm & cd algo & crypt.py rc4.exe & cd ..
algo\xor.exe: algo\xor.asm
	$(makepe) algo\xor.asm & cd algo & crypt.py xor.exe & cd ..

pe\dll.dll: pe\dll.asm
	$(makepe) pe\dll.asm
pe\loader.exe: pe\loader.asm
	$(makepe) pe\loader.asm
pe\manual_loader.exe: pe\manual_loader.asm
	$(makepe) pe\manual_loader.asm
packer\packed_loader.exe: packer\packed_loader.asm
	$(makepe) packer\packed_loader.asm
packer\packed_dll.dll: packer\packed_dll.asm
	$(makepe) packer\packed_dll.asm

packer\eppatched.exe: pe\compiled.exe packer\eppatcher.py
	cd packer & $(python) eppatcher.py
packer\crypted.exe: pe\compiled.exe packer\crypter.py
	cd packer & $(python) crypter.py
packer\compressed.exe: pe\compiled.exe packer\compresser.py
	cd packer & $(python) compresser.py
packer\protected.exe: pe\compiled.exe packer\protecter.py
	cd packer & $(python) protecter.py
packer\mutated.exe: pe\compiled.exe packer\mutater.py
	cd packer & $(python) mutater.py
packer\virtualized.exe: pe\compiled.exe packer\virtualizer.py
	cd packer & $(python) virtualizer.py

packer\bundled_before.exe: packer\bundled_before.asm
	$(makepe) packer\bundled_before.asm
packer\bundled_after.exe: packer\bundled_after.asm
	$(makepe) packer\bundled_after.asm

packer\dropper.exe: packer\dropper.asm
	$(makepe) packer\dropper.asm
packer\suspended_process.exe: packer\suspended_process.asm
	$(makepe) packer\suspended_process.asm
packer\resource_dropper.exe: packer\resource_dropper.asm
	$(makepe) packer\resource_dropper.asm

asm\memcopy.exe: asm\memcopy.asm
	$(makepe) asm\memcopy.asm

asm\inline_strings.exe : asm\inline_strings.asm
	$(makepe) asm\inline_strings.asm
asm\stack_strings.exe : asm\stack_strings.asm
	$(makepe) asm\stack_strings.asm

anti\misc.exe: anti\misc.asm
	$(makepe) anti\misc.asm
anti\ollydbg.exe: anti\ollydbg.asm
	$(makepe) anti\ollydbg.asm
anti\exception_skip.exe: anti\exception_skip.asm
	$(makepe) anti\exception_skip.asm
anti\exception_overwrite.exe: anti\exception_overwrite.asm
	$(makepe) anti\exception_overwrite.asm
anti\hwbp.exe: anti\hwbp.asm
	$(makepe) anti\hwbp.asm
anti\tf_step.exe: anti\tf_step.asm
	$(makepe) anti\tf_step.asm
anti\dump.exe: anti\dump.asm
	$(makepe) anti\dump.asm

asm\apiloop.exe: asm\apiloop.asm
	$(makepe) asm\apiloop.asm

pe\sect_phys_order.exe: pe\sect_phys_order.asm
	$(makepe) pe\sect_phys_order.asm
pe\imagebase_null.exe: pe\imagebase_null.asm
	$(makepe) pe\imagebase_null.asm

asm\crypted_strings.exe: asm\crypted_strings.asm
	$(makepe) asm\crypted_strings.asm

anti\int2a_loop.exe: anti\int2a_loop.asm
	$(makepe) anti\int2a_loop.asm

VMs\binary.exe: VMs\binary.asm
	$(makepe) VMs\binary.asm

test.exe: test.asm
	$(makepe) test.asm

pe\hal.dll: pe\hal.asm
	$(makepe) pe\hal.asm
pe\classpnp.sys: pe\classpnp.asm
	$(makepe) pe\classpnp.asm
	mv pe\classpnp.dll pe\classpnp.sys

pe\resource_loop.exe: pe\resource_loop.asm
	$(makepe) pe\resource_loop.asm
pe\resource_fail7.exe: pe\resource_fail7.asm
	$(makepe) pe\resource_fail7.asm
pe\resource_shuffled.exe: pe\resource_shuffled.asm
	$(makepe) pe\resource_shuffled.asm

anti\flow.exe: anti\flow.asm
	$(makepe) anti\flow.asm

imports\kernel31.asm: imports\kernel31.py
	cd imports & $(python) kernel31.py & cd ..\..
imports\kernel31.dll: imports\kernel31.asm
	$(makepe) imports\kernel31.asm
imports\kernel31_test.exe: imports\kernel31_test.asm
	$(makepe) imports\kernel31_test.asm

asm\rel_ip.exe: asm\rel_ip.asm
	$(makepe) $<

imports\imports_doublesum.exe: imports\imports_doublesum.asm
	$(makepe) $<

pe\helloworld64.exe: pe\helloworld64.asm
	$(makepe) pe\helloworld64.asm

pe\max_sec.exe: pe\max_sec.asm
	$(makepe) pe\max_sec.asm
pe\max_sec.asm: pe\max_sec.py
	cd PE & $(python) max_sec.py & cd ..

pe\max_secXP.exe: pe\max_secXP.asm
	$(makepe) pe\max_secXP.asm
pe\max_secXP.asm: pe\max_secXP.py
	cd PE & $(python) max_secXP.py & cd ..

pe\delayimports.exe: pe\delayimports.asm
	$(makepe) pe\delayimports.asm

pe\shelload.exe: pe\shelload.asm
	$(makepe) pe\shelload.asm

asm\mmx.exe: asm\mmx.asm
	$(makepe) asm\mmx.asm
asm\sse.exe: asm\sse.asm
	$(makepe) asm\sse.asm
asm\fpu.exe: asm\fpu.asm
	$(makepe) asm\fpu.asm

anti\fastpeblock.exe: anti\fastpeblock.asm
	$(makepe) anti\fastpeblock.asm
anti\lowlevel.exe: anti\lowlevel.asm
	$(makepe) anti\lowlevel.asm

asm\small_sc.bin: asm\small_sc.asm
	yasm -o asm\small_sc.bin asm\small_sc.asm

asm\memscan.exe: asm\memscan.asm
	$(makepe) asm\memscan.asm
asm\trampo1.exe: asm\trampo1.asm
	$(makepe) asm\trampo1.asm

pe\multisub.exe: pe\multisub.asm
	$(makepe) pe\multisub.asm

clean:
	rm $(examples) $(objects) $(notworking)
