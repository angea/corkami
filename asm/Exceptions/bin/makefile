all: common XP W7

beta: set_ss.exe

common: triggers veh.exe set

triggers: trig_invalidmem.exe trig_divzero.exe trig_intov1.exe trig_intov2.exe trig_invalidins.exe \
    trig_privins.exe trig_bound.exe trig_bpint3.exe trig_bpint_3.exe trig_ssflags.exe \
    trig_ssicebp.exe trig_privinsvmw.exe

set: set_tibself.exe set_gs.exe set_hardcoded.exe

XP:

W7:

%.exe: ..\%.asm
	yasm -o $@ $<
