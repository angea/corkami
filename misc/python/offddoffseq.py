# takes the following situation:  offset_xxxx dd offset kernel32_Process32Next
# extracts api name, rename location, redirects references to this offset directly to the API
# stops until NULL dword

Message("start\n")

ea = idaapi.get_screen_ea()
while True:
    idc.MakeDword(ea)
    add = idc.Dword(ea)
    if add == 0:
        break
    name = idc.Name(add)
    api = name.split("_")[-1] # careful with ws2_32_sendto...
    if idc.MakeName(ea, api) == True:
        apiadd = ea
    else:
        idc.MakeName(ea, api + "_")
        apiadd = idc.LocByName(api)
    for xref in XrefsTo(ea, 0):
     if idaapi.is_call_insn(xref.frm):
      idaapi.netnode("$ vmm functions").altset(xref.frm, apiadd + 1)
      idaapi.analyze_area(xref.frm, xref.frm + 8)

    ea += 4

Message("done\n")
