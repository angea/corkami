# a python script to generate an import table in ASM
# Ange Albertini, BSD Licence, 2013

d = {
    "kernel32.dll": [
        "ExitProcess",

#        "FindResourceA",
#        "LoadResource",

#        "GetModuleHandleA",
#        "GetCommandLineA",
        ],
    "msvcrt.dll": [
        "printf"
        ],
    "user32.dll":[
        "MessageBoxA",

#        "LoadIconA",
#        "LoadCursorA",
#
#        "RegisterClassExA",
#        "CreateWindowExA",
#        "ShowWindow",
#        "UpdateWindow",
#
#        "GetMessageA",
#        "TranslateMessage",
#        "DispatchMessageA",
#        "PostQuitMessage",
#        "DefWindowProcA",
        ]
    }

################################################################################

t_desc = """istruc IMPORT_IMAGE_DESCRIPTOR
    at IMPORT_IMAGE_DESCRIPTOR.DllName, dd sz_%(dllnameclean)-8s  - IMAGEBASE
    at IMPORT_IMAGE_DESCRIPTOR.IAT,     dd iat_%(dllnameclean)-8s - IMAGEBASE
iend"""

t_descs = """%(descs)s
istruc IMPORT_IMAGE_DESCRIPTOR
iend"""

t_hn = """hn_%(apiclean)-16s db 0, 0, '%(api)s', 0"""

t_iatentry = "__imp__%(apiclean)-16s dd hn_%(apiclean)-16s - IMAGEBASE"

t_iat = """iat_%(dllnameclean)s:
%(iat)s
    dd 0"""

t_dllnamedec = "sz_%(dllnameclean)-8s db '%(dllname)s', 0"

t_imports = """imports:
%(descs)s

%(iats)s

%(dllnames)s

%(hns)s
"""

################################################################################

descs = []
dllnames = []
iats = []
hns = []
for dllname in d:
    dllnameclean = dllname.lower().replace(".dll", "")
    descs.append(t_desc % locals())
    dllnames.append(t_dllnamedec % locals())
    iat = []
    for api in d[dllname]:
        apiclean = api.lower()
        hns.append(t_hn % locals())
        iat.append(t_iatentry % locals())
    iat = "\r\n".join(iat)
    iat = t_iat % locals()
    iats.append(iat)

hns = ("\r\n".join(hns)).strip()
descs = ("\r\n".join(descs)).strip()
descs = t_descs % locals()
iats = ("\r\n".join(iats)).strip()
dllnames = ("\r\n".join(dllnames)).strip()

################################################################################

print (t_imports % locals()).strip()
