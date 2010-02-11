import pefile
templates = {'IDA':[
"""
static main(){
auto i;
i = AddEnum(-1,"hashes",0x1100000);
%(enums)s
}""",
"""AddConstEx(i, "%(dll)s_%(api)s", 0x%(const)08X, -1);"""],
'hiew':["%(enums)s", ".%(const)08X  %(dll)s_%(api)s"]}

template = templates['hiew']

def rol(x, shift, size=32):
    return (x << shift) | (x >> (size - shift))

def hash_api(s):
    cs = 0
    for c in s + "\x00":
        cs = rol(cs,7) + ord(c)
        cs %= 2**32
    return cs

enums = []
for dll in ['kernel32', 'user32']:
    pe = pefile.PE(r"c:\windows\system32\%s.dll" % dll)
    for sym in pe.DIRECTORY_ENTRY_EXPORT.symbols:
        enums += [template[1] % {"dll":dll, "api":sym.name, "const":hash_api(sym.name)}]

print template[0] % {"enums":"\n".join(enums)}
