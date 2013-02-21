# MakePE

# pe structure code generator
# imports structures, pe checksum, defaults values

# Ange Albertini BSD Licence 2009-2011

try:
    import sys, re, os, templates, pefile
except:
    print "Import Error - missing pefile ?"

defaults = {
"IMAGEBASE":
    "400000H",
"CHARACTERISTICS":
    "IMAGE_FILE_RELOCS_STRIPPED | IMAGE_FILE_EXECUTABLE_IMAGE | IMAGE_FILE_LINE_NUMS_STRIPPED | IMAGE_FILE_LOCAL_SYMS_STRIPPED | IMAGE_FILE_32BIT_MACHINE",
"SUBSYSTEM":
    "IMAGE_SUBSYSTEM_WINDOWS_GUI",
}

default_directories = {
"Exports_Directory":
    "IMAGEBASE",
"DIRECTORY_ENTRY_EXPORT_SIZE":
    "0",
"Directory_Entry_Resource":
    "IMAGEBASE",
"DIRECTORY_ENTRY_RESOURCE_SIZE":
    "0",
"Directory_Entry_Basereloc":
    "IMAGEBASE",
"DIRECTORY_ENTRY_BASERELOC_SIZE":
    "0",
"DIRECTORY_ENTRY_IAT_SIZE":
    "0",
"Image_Tls_Directory32":
    "IMAGEBASE",
"DIRECTORY_ENTRY_TLS_SIZE":
    "0",
"Image_Delay_Import_Directory32":
    "IMAGEBASE",
}

def MakeImports(imports):
    HintNames = "HintNames:\n"
    ImportAddressTable = "ImportAddressTable:\n"
    descriptors = templates.Imports["DESCRIPTORS_START"]

    jumps = str()
    dll_names = str()
    apis = str()

    for dll in imports:
        descriptors += templates.Imports["IMAGE_IMPORT_DESCRIPTOR"] % {"dll":dll}
        HintNames += templates.Imports["HINT_NAME_start"] % {"dll":dll}
        ImportAddressTable += templates.Imports["IAT_start"] % {"dll":dll}
        dll_names += templates.Imports["DLL_NAME"] % {"dll":dll}

        for api in imports[dll]:
            HintNames += templates.Imports["HINT_NAME_thunk"] % {"api":api}
            ImportAddressTable += templates.Imports["IAT_thunk"] % {"dll":dll, "api":api}
            apis += templates.Imports["IMAGE_IMPORT_BY_NAME"] % {"api":api}

        HintNames += templates.Imports["Thunk_end"]
        ImportAddressTable += templates.Imports["Thunk_end"]

    ImportAddressTable += "IAT_size equ $ - ImportAddressTable\n"
    descriptors += templates.Imports["Descriptor_end"]

    source = str()
    source += ImportAddressTable + descriptors + HintNames + apis + dll_names
    source += templates.Imports["IMPORTS_END"]

    return source

def MakeImports64(imports):
    HintNames = "HintNames:\n"
    ImportAddressTable = "ImportAddressTable:\n"
    descriptors = templates.Imports["DESCRIPTORS_START"]

    jumps = str()
    dll_names = str()
    apis = str()

    for dll in imports:
        descriptors += templates.Imports["IMAGE_IMPORT_DESCRIPTOR"] % {"dll":dll}
        HintNames += templates.Imports["HINT_NAME_start"] % {"dll":dll}
        ImportAddressTable += templates.Imports["IAT_start"] % {"dll":dll}
        dll_names += templates.Imports["DLL_NAME"] % {"dll":dll}

        for api in imports[dll]:
            HintNames += templates.Imports["HINT_NAME_thunk64"] % {"api":api}
            ImportAddressTable += templates.Imports["IAT_thunk64"] % {"dll":dll, "api":api}
            apis += templates.Imports["IMAGE_IMPORT_BY_NAME"] % {"api":api}

        HintNames += templates.Imports["Thunk_end64"]
        ImportAddressTable += templates.Imports["Thunk_end64"]

    ImportAddressTable += "IAT_size equ $ - ImportAddressTable\n"
    descriptors += templates.Imports["Descriptor_end"]

    source = str()
    source += ImportAddressTable + descriptors + HintNames + apis + dll_names
    source += templates.Imports["IMPORTS_END"]

    return source

def MakeRelocs(relocs):
    source = str()
    source += templates.Relocations["START"]
    block = 0
    base = 0
    for i, off in enumerate(relocs):
        if (i % 512) == 0:
            base = i
            if i > 0:
                source += templates.Relocations["BLOCKEND"] % {"block": block}
                block += 1
            source += templates.Relocations["BLOCKSTART"] % {"block": block, "base": base}
        source += templates.Relocations["ENTRY"] % {"label": str(i), "offset": off, "base": base}
    source += templates.Relocations["BLOCKEND"] % {"block": block}
    source += templates.Relocations["END"]
    return source

def MakeExports(exports, dll_name):
    counter = len(exports)
    ordinals = []
    functions = []
    names = []
    strings = []
    for i, export in enumerate(sorted(exports)):
        ordinals += [templates.Exports["ORDINAL"] % locals()]
        functions += [templates.Exports["FUNCTION"] % locals()]
        strings += [templates.Exports["STRING"] % locals()]
        names += [templates.Exports["NAME"] % locals()]
    ordinals = "\n".join(ordinals)
    functions = "\n".join(functions)
    strings = "\n".join(strings)
    names = "\n".join(names)
    return templates.Exports["BODY"] % locals()

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print "Missing argument: Makepe.py filename.asm"
        sys.exit()
    checksum = False
    f = open(sys.argv[1], "rt")
    r = f.read()
    f.close()

#parse imports tags
    findimp = re.findall(";%IMPORT64 ([a-z.0-9_]+)!([a-z.0-9_]+)", r, re.I | re.M)
    imports = {}
    if findimp:
        for dll, api in findimp:
            if dll not in imports:
                imports[dll] = list()
            imports[dll] += [api]

    r = re.sub(r";%IMPORT64 ([a-z.0-9_]+)!([A-Za-z0-9_]+)", r"""\2:\n    jmp [__imp__\2]""", r)
    r = r.replace(";%IMPORTS64", MakeImports64(imports)) # this one first to prevent collision

    findimp = re.findall(";%IMPORT ([a-z.0-9_]+)!([a-z.0-9_]+)", r, re.I | re.M)
    imports = {}
    if findimp:
        for dll, api in findimp:
            if dll not in imports:
                imports[dll] = list()
            imports[dll] += [api]

    r = re.sub(r";%IMPORT ([a-z.0-9_]+)!([A-Za-z0-9_]+)", r"""\2:\n    jmp [__imp__\2]""", r)
    r = r.replace(";%IMPORTS", MakeImports(imports))


#parse exports tags
    findexp = re.findall(";%EXPORT ([A-Za-z.0-9_]+)", r, re.I | re.M)
    exports = []
    if findexp:
        for name in findexp:
            exports += [name]

    r = re.sub(r";%EXPORT ([A-Za-z.0-9_]+)", r"""__exp__\1:""", r)
    findexp2 = re.findall(r";%EXPORTS ([A-Za-z.0-9_]+)", r, re.I | re.M)
    dll_name = ""
    if findexp2:
        dll_name = findexp2[0]
    r = re.sub(r";%EXPORTS ([A-Za-z\.0-9_]+)", MakeExports(exports, dll_name), r)

#parse relocation tags
    #add a counter for each of them
    for i in range(r.count(";%reloc ")):
        r = r.replace(";%reloc ", ";%%reloc%i " % i, 1)

    findrel = re.findall(";%reloc[0-9]+ ([0-9])", r, re.I | re.M)
    relocs = []
    if findrel:
        for off in findrel:
            relocs += [off]

    r = re.sub(r";%reloc([0-9]+) [0-9]", r"""reloc\1:""", r)
    r = r.replace(";%relocs", MakeRelocs(relocs))

#parse string tags
    #add a counter for each of them
    strcnt = 0
    strs = []
    ind = r.find("%string:")
    inds = r.find(";%strings")
    while inds > -1 or ind > -1:
        ind = r.find("%string:")
        inds = r.find(";%strings")
        if ind == -1 or inds < ind:
            r = r.replace(";%strings", "\n".join(strs), 1)
            strs = []

            ind = r.find("%string:")
            inds = r.find(";%strings")
            continue
        elif ind > -1:
            strcnt += 1
            name = "string_%03i" % strcnt
            content = r[ind + 8:].splitlines()[0].strip()
            r = r.replace("%string:" + content, name, 1)
            #print name, content

            strs.append("%s db %s" % (name, content))
            ind = r.find("%string:")
            inds = r.find(";%strings")
            continue
        else:
            pass
            #print ind, inds
        ind = r.find("%string:")
        inds = r.find(";%strings")


# add default values for variables that are not defined
    find_define = re.findall("([A-Z_0-9 ]+).*EQU", r, re.I | re.M)
    defines = []
    if find_define:
        for i in find_define:
            defines += i.split()

    find_define = re.findall("([A-Z_0-9 ]+).*:", r, re.I | re.M)
    if find_define:
        for i in find_define:
            defines += i.split()

    for d in defaults, default_directories:
        for s in d:
            if s not in defines:
                r += "\r\n" + s + " EQU %s" % d[s]

    if r.find('IMAGE_SUBSYSTEM_NATIVE') != -1:
        extension = ".sys"
        checksum = True
    elif r.find('IMAGE_FILE_DLL') != -1:
        extension = ".dll"
    else:
        extension = ".exe"

    source = sys.argv[1]
    temp = source.replace(".asm",".tmp")
    target = source.replace(".asm", extension)
    temp_asm = open(temp, "wt")
    temp_asm.write(r)
    temp_asm.close()
    if os.system("yasm %s -o %s" % (temp, target)) == 0:
        # cleaning temp files if no errors
        os.remove(temp)

    if checksum:
        pe = pefile.PE(target)
        pe.OPTIONAL_HEADER.CheckSum = pe.generate_checksum()
        pe.write(target)

