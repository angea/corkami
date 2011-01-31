#idapython script to revert import_doublesum's import obfuscation
#TODO: make it independant/hiew/ollydbg

SYSDIR = "c:\\windows\\system32\\"

def rol(x, shift, size=32):
    return (x << shift) | (x >> (size - shift))

def hash_(s):
    cs = 0
    for c in s + "\x00":
        cs = rol(cs,7) + ord(c)
        cs %= 2**32
    return cs

def hashfn(s):
    return hash_(s.lower()) + 0x20

def get_dllhashes():
    import glob
    fns = glob.glob(SYSDIR + "*.dll")
    fnhashes = dict()
    for fn in fns:
        fn = fn.replace(SYSDIR , "")
        fnhashes[hashfn(fn)] = fn
    return fnhashes

def export_hashes(fn):
    import pefile
    exports = dict()
    pe = pefile.PE(SYSDIR + fn)
    for sym in pe.DIRECTORY_ENTRY_EXPORT.symbols:
        if sym.name is not None:
            exports[hash_(sym.name)] = sym.name
    return exports

Message("script start\n")

# let's get all the imports calls
imports_ea = 0x00401047
fnhashes = get_dllhashes()

exports = dict()

for xref in XrefsTo(imports_ea, 0):

    # check we have the right sequence
    if idc.GetMnem(xref.frm) != "jmp":
        continue
    if idc.GetMnem(xref.frm - 5) != "push":
        continue
    if idc.GetMnem(xref.frm - 5 - 5) != "push":
        continue

    # then get the parameters for it
    start_ea = xref.frm - 5 - 5
    dllsum = idc.Dword(start_ea + 1)
    apisum = idc.Dword(start_ea + 5 + 1)


    filename = fnhashes[dllsum]
    if filename not in exports:
        exports[filename] = export_hashes(filename)
    api = exports[filename][apisum]

    print "%08X: call to %08X/%08X (%s.%s)" % (start_ea, dllsum, apisum, filename, api)

    # now let's add our information back in the IDB
    idc.MakeName(start_ea, api)

    # not needed here - modify the callee directly
    # idaapi.netnode("$ vmm functions").altset(<source>, <target> + 1)

    # not needed here - re-analyze the new code
    # idaapi.analyze_area(<start>, <end>)

Message("script end\n")