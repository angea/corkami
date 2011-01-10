#Python I/O interface for different Reverse Engineering tools
#Hiew (PyHiew), IDA (IDAPython)

#BSD Licence, Ange Albertini 2011

__all__ = [ "FRAMEWORK", "msg", "getselection"]

def msg(s):
    print s
    return

def msg_hiew(s):
    if s.find("\n") > -1:
        hiew.Window.FromString("Info", s) # multiline_hiew(s)
    else:
        hiew.Message("Info", s)

def msg_ida(s):
    idc.Message(s + "\n")

def getselection_hiew():
    return hiew.Data.GetSelData()

def getselection_ida():
    start, end = idc.SelStart(), idc.SelEnd()
    r = []
    for i in range(end - start):
        r.append(chr(idc.Byte(start + i)))
    return "".join(r) if r != [] else None

try:
    import hiew
    FRAMEWORK = "HIEW"
    msg = msg_hiew
    getselection = getselection_hiew
except:

    try:
        import idaapi
        import idc
        FRAMEWORK = "IDA"
        msg = msg_ida
        getselection = getselection_ida

    except:
        import sys
        sys.exit()