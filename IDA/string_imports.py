# for null-terminated sequence of the following structure:
# api string
# api dword address

# do the following
# - get api string
# - make the string
# - make the dword
# - rename the dword to the API name
# - point all references to the dword directly to the API

Message("start\n")

ea = idaapi.get_screen_ea()
i = 0
while True:
	ea += i
	i = 0
	name = ""
	# determine the Api name and length
	c = _idaapi.get_byte(ea + i)
	while c != 0:
	 name += chr(c)
	 i += 1
	 c = _idaapi.get_byte(ea + i)
	
	#make the string
	i += 1
	idc.MakeStr(ea, ea + i);		

	#make the dword
	idc.MakeDword(ea + i)

	#rename the dword as the API
	idc.MakeName(ea + i, name)

	# change all relative references to this address as pointing directly to the API

	for xref in XrefsTo(ea + i, 0):
	 if idaapi.is_call_insn(xref.frm):
	  idaapi.netnode("$ vmm functions").altset(xref.frm, ea + i + 1)
	  idaapi.analyze_area(xref.frm, xref.frm + 8)
	i += 4

	#end when null byte
	if _idaapi.get_byte(ea + i) == 0:
		break

Message("done\n")

