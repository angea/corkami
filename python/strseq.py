# takes a structure of ApiStr (null terminated), then 4-byte alignment.
Message("start\n")

ea = idaapi.get_screen_ea()
i = 0
while True:
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

    #make the align
    ea += i
    if ea % 4 != 0:
        rest = 4 - (ea % 4)
        idc.MakeAlign(ea, rest, 2) # 2 = 4 bytes aligned
        ea += rest

    if _idaapi.get_byte(ea) == 0:
        break

Message("done\n")

