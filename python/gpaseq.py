"""
mov eax, off_xxxx
.
.
.
.
GetProcAddress
mov off_yyyy, eax
.
.
.
.
(repeat)

off_xxxx dd aApiName

Gets the ApiName, propagates the name to off_xxxx, gives the API name itself to off_yyyy, then redirects all refs to yyyy to the API name directly

"""

Message("start\n")

def skiplines(ea, x):
    return ea

def GetNullStr(ea):
    name = str()
    i = 0
    c = _idaapi.get_byte(ea + i)
    while c != 0:
     name += chr(c)
     i += 1
     c = _idaapi.get_byte(ea + i)
    return name

ea = idaapi.get_screen_ea()
while True:
    if idc.GetMnem(ea) != "mov":
        print "%x:%s\n" % (ea, idc.GetDisasm(ea))
        break

    add = idc.LocByName(idc.GetOpnd(ea, 1))
    ref = GetNullStr(idc.Dword(add))
    idc.MakeName(add, "lp%s" % ref)

    # skip 5 lines
    for _ in xrange(5):
        ea = idc.NextHead(ea, BADADDR)

    if idc.GetMnem(ea) != "mov":
        print "%x:%s\n" % (ea, idc.GetDisasm(ea))
        break

    # get assigned operand and rename it
    add2 = idc.LocByName(idc.GetOpnd(ea, 0))
    idc.MakeName(add2, ref)

    for xref in XrefsTo(add2, 0):
     if idaapi.is_call_insn(xref.frm):
      idaapi.netnode("$ vmm functions").altset(xref.frm, add2 + 1)
      idaapi.analyze_area(xref.frm, xref.frm + 8)

    #skip 4 lines
    for _ in xrange(4):
        ea = idc.NextHead(ea, BADADDR)

Message("done\n")
