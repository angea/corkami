# this idapython scripts is for renaming register,
# but rather than selecting a range, select the (renamed or not) register,
# then the range will automatically be 'from this line till the end of the function'
# if you do it again for the same register later (address-wise), the 'previous' range will be shortened.

import idaapi
import idc
import idautils

REGS = "eax ebx ecx edx edi esi ebp" #TODO: add all regs/get it automatically for any CPU ?

def org_reg(newname, ea, func):
    """get the reg_var structure for a renamed register"""
    for reg in REGS.split():
        rv = idaapi.find_regvar(func, ea, ea + 1, reg, "")
        if rv is not None and rv.user == newname:
            return rv
    return None

def main():
    ea = ScreenEA()
    rv = None

    func = idaapi.get_func(ea)
    if func is None:
        Message("Error: not in a function\n")
        return

    reg = get_highlighted_identifier()
    if reg is None:
        Message("Error: no highlighted name\n")
        return

    # it's not a reg ? we get the renaming for it then
    if reg not in REGS:
        rv = org_reg(reg, ea, func)
        if rv is None:
            Message("Error: the highlighted name is neither a register nor a renamed register\n")
            return

    new = AskStr(reg, "new name[;comment]")
    if new is None:
        Message("Cancelled\n")
        return
    if ";" in new:
        new, cmt = new.split(";")
    else:
        cmt = ""

    # was there a previous rename ? let's truncate it
    if rv is not None:
        s, e, c, u, cmt = rv.startEA, rv.endEA, rv.canon, rv.user, rv.cmt
        idaapi.del_regvar(func, s, e,c )
        idaapi.add_regvar(func, s, ea - 1, c, u, cmt)

    idaapi.add_regvar(func, ea, func.endEA, reg if rv is None else rv.canon, new, cmt)

    # optional / to be perfected- added end ranges
    #idc.ExtLinA(ea, 0, "{")
    #idc.ExtLinB(func.endEA, 0, "} %s => %s ;%s" % (reg, new, cmt))

    return

main()