# god that's ugly...

def bread(buffer, n):
    """ reads n chars from a buffer, returns n read and the truncated buffer"""
    return buffer[:n], buffer[n:]

def unpack_from_buffer(format, buffer):
    """UGLY HACK makes a buffer behave like a stream"""
    size = struct.calcsize(format)
    nread, buffer = bread(buffer, size)
    vars = struct.unpack(format, nread)
    return vars, buffer


def NoneDef(data, meta):
    return "(NOT SUPPORTED)"

def FileHeader(data, meta):
    [MajorVersion, MinorVersion, ProfileIdentifier, DeclarationSize, FileSize, CharacterEncoding], data = \
        unpack_from_buffer("<HHLLQL", data)
    if (ProfileIdentifier & 8) == 8:
        [UnitsScalingFactor], data = unpack_from_buffer("<Q", data)
        print UnitsScalingFactor
    return     ", ".join(["%s:%s " % (i, str(locals()[i])) for i in ["MajorVersion", "MinorVersion", "ProfileIdentifier", "DeclarationSize", "FileSize", "CharacterEncoding"]])

def readstring(data):
    [length], data = unpack_from_buffer("<H", data)
    return data[:length], data[length:]

def ModifierChain(data, meta):
    initial = len(data)
    Name, data = readstring(data)

    [Types, Attributes], data = unpack_from_buffer("<LL", data)
    if Attributes == 1:
        [X, Y, Z, Radius], data = unpack_from_buffer("<LLLL", data)
    elif Attributes == 2:
        [MinX, MinY, MinZ, MaxX, MaxY, MaxZ], data = unpack_from_buffer("<LLLLLL", data)
    offset = initial - len(data)
    if (offset % 4) > 0:
        data = data[4 - (offset % 4):]

    [ModifierCount], data = unpack_from_buffer("<L", data)
    for i in ["Name", "Types", "Attributes", "ModifierCount"]:
        print i, locals()[i]
    for i in range(ModifierCount):
        [blocktype, data_size, meta_size], data = unpack_from_buffer("<LLL", data)
        print "block %08X:%s" % (blocktype, blocktypes[blocktype][0]),
        print data_size, meta_size
        if blocktype == 0xFFFFFF45:
            subdata = data[:data_size]
            ShaderName, subdata = readstring(subdata)
            print ShaderName,
            
            [ChainIndex, ShadingAttributes, ShaderListCount], subdata = unpack_from_buffer("<LLL", subdata)
            print "ShaderListCount", ShaderListCount
            for j in xrange(ShaderListCount):
                [ShaderCount], subdata = unpack_from_buffer("<L", subdata)

        data = data[data_size:]
        if data_size % 4 > 0:
            data = data[4 - (data_size % 4):]

        data = data[meta_size:]
        if meta_size % 4 > 0:
            data = data[4 - (meta_size % 4):]

    return ""

def ShadingModifier(data, meta):
    ShadingModifierName, data = readstring(data)
    [ChainIndex, ShadingAttributes, ShaderListCount], data = unpack_from_buffer("<LLL", data)
    s = "(Modifier Name: %s, Chain Index:%x, Attributes:%x)" % (ShadingModifierName, ChainIndex, ShadingAttributes)
    return s

blocktypes = {
    0x00443355:["FileHeader",                     FileHeader],
    0xFFFFFF12:["FileReference",                  NoneDef],
    0xFFFFFF14:["ModifierChain",                  ModifierChain],
    0xFFFFFF15:["PriorityUpdate",                 NoneDef],
    0xFFFFFF16:["NewObjectType",                  NoneDef],
    0xFFFFFF21:["GroupNode",                      NoneDef],
    0xFFFFFF22:["ModelNode",                      NoneDef],
    0xFFFFFF23:["LightNode",                      NoneDef],
    0xFFFFFF24:["ViewNode",                       NoneDef],
    0xFFFFFF31:["CLODMeshDeclaration",            NoneDef],
    0xFFFFFF3B:["CLODMeshContinuation",           NoneDef],
    0xFFFFFF3C:["CLODProgressiveMeshContinuation",NoneDef],
    0xFFFFFF36:["PointSet",                       NoneDef],
    0xFFFFFF3E:["PointSetContinuation",           NoneDef],
    0xFFFFFF37:["LineSet",                        NoneDef],
    0xFFFFFF3F:["LineSetContinuation",            NoneDef],
    0xFFFFFF41:["TwoDGlyphModifier",              NoneDef],
    0xFFFFFF42:["SubdivisionModifier",            NoneDef],
    0xFFFFFF43:["AnimationModifier",              NoneDef],
    0xFFFFFF44:["BoneWeightModifier",             NoneDef],
    0xFFFFFF45:["ShadingModifier",                ShadingModifier],
    0xFFFFFF46:["CLODModifier",                   NoneDef],
    0xFFFFFF51:["LightResource",                  NoneDef],
    0xFFFFFF52:["ViewResource",                   NoneDef],
    0xFFFFFF53:["LitTextureShader",               NoneDef],
    0xFFFFFF54:["MaterialResource",               NoneDef],
    0xFFFFFF55:["TextureDeclaration",             NoneDef],
    0xFFFFFF5C:["TextureContinuation",            NoneDef],
}

import sys
import struct
f = open(sys.argv[1])
while 1:
    r = f.read(1)
    if r == "":
        print "EOF"
        break
    r = r + f.read(12 - 1)
    blocktype, data_size, meta_data_size = struct.unpack("<LLL", r)

    data = f.read(data_size)
    if (data_size % 4) != 0:
        f.read(4 - (data_size % 4))

    meta_data = f.read(meta_data_size)
    if (meta_data_size % 4) != 0:
        f.read(4 - (meta_data_size % 4))
    print blocktypes[blocktype][0], blocktypes[blocktype][1](data, meta_data)
f.close()