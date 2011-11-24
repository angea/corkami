#todo: display different flags of field/method
#todo: check acceptable types of attributes

import sys, struct

#******************************************************************************
mnemonics_ = [
"nop",          "aconst_null",  "iconst_m1",    "iconst_0",     "iconst_1", "iconst_2",      "iconst_3",     "iconst_4",
"iconst_5",     "lconst_0",     "lconst_1",     "fconst_0",     "fconst_1", "fconst_2",      "dconst_0",     "dconst_1",
"bipush",       "sipush",       "ldc",          "ldc_w",        "ldc2_w",   "iload",         "lload",        "fload",
"dload",        "aload",        "iload_0",      "iload_1",      "iload_2",  "iload_3",       "lload_0",      "lload_1",
"lload_2",      "lload_3",      "fload_0",      "fload_1",      "fload_2",  "fload_3",       "dload_0",      "dload_1",
"dload_2",      "dload_3",      "aload_0",      "aload_1",      "aload_2",  "aload_3",       "iaload",       "laload",
"faload",       "daload",       "aaload",       "baload",       "caload",   "saload",        "istore",       "lstore",
"fstore",       "dstore",       "astore",       "istore_0",     "istore_1", "istore_2",      "istore_3",     "lstore_0",
"lstore_1",     "lstore_2",     "lstore_3",     "fstore_0",     "fstore_1", "fstore_2",      "fstore_3",     "dstore_0",
"dstore_1",     "dstore_2",     "dstore_3",     "astore_0",     "astore_1", "astore_2",      "astore_3",     "iastore",
"lastore",      "fastore",      "dastore",      "aastore",      "bastore",  "castore",       "sastore",      "pop",
"pop2",         "dup",          "dup_x1",       "dup_x2",       "dup2",     "dup2_x1",       "dup2_x2",      "swap",
"iadd",         "ladd",         "fadd",         "dadd",         "isub",     "lsub",          "fsub",         "dsub",
"imul",         "lmul",         "fmul",         "dmul",         "idiv",     "ldiv",          "fdiv",         "ddiv",
"irem",         "lrem",         "frem",         "drem",         "ineg",     "lneg",          "fneg",         "dneg",
"ishl",         "lshl",         "ishr",         "lshr",         "iushr",    "lushr",         "iand",         "land",
"ior",          "lor",          "ixor",         "lxor",         "iinc",     "i2l",           "i2f",          "i2d",
"l2i",          "l2f",          "l2d",          "f2i",          "f2l",      "f2d",           "d2i",          "d2l",
"d2f",          "i2b",          "i2c",          "i2s",          "lcmp",     "fcmpl",         "fcmpg",        "dcmpl",
"dcmpg",        "ifeq",         "ifne",         "iflt",         "ifge",     "ifgt",          "ifle",         "if_impeq",
"if_impne",     "if_implt",     "if_impge",     "if_impgt",     "if_imple", "if_acmpeq",     "if_acmpne",    "goto",
"jsr",          "ret",          "tableswitch",  "lookupswitch", "ireturn",  "lreturn",       "freturn",      "dreturn",
"areturn",      "return",       "getstatic",    "putstatic",    "getfield", "putfield",      "invokevirtual","invokespecial",
"invokestatic", "invokeinterface",      0,      "new",          "newarray", "anewarray",     "arraylength",  "athrow",
"checkcast",    "instanceof",   "monitorenter", "monitorexit",  "wide",     "multianewarray","ifnull",       "ifnonnull",
"goto_w",       "jsr_w",        "breakpoint",   0,      0,      0,      0,      0,
0,      0,      0,      0,      0,      0,      0,      0,
0,      0,      0,      0,      0,      0,      0,      0,
0,      0,      0,      0,      0,      0,      0,      0,
0,      0,      0,      0,      0,      0,      0,      0,
0,      0,      0,      0,      0,      0,      0,      0,
0,      0,      0,      0,      0,      0,                                                   "impdep1",      "impdep2",
]

MNEMONICS = {}
for i, j in enumerate(mnemonics_):
    MNEMONICS[i] = j
    if j != 0:
        MNEMONICS[j] = i

NB_OPERANDS = [
 1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,
 2,  3,  2,  3,  3,  2,  2,  2,  2,  2,  1,  1,  1,  1,  1,  1,
 1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,
 1,  1,  1,  1,  1,  1,  2,  2,  2,  2,  2,  1,  1,  1,  1,  1,
 1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,
 1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,
 1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,
 1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,
 1,  1,  1,  1,  3,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,
 1,  1,  1,  1,  1,  1,  1,  1,  1,  3,  3,  3,  3,  3,  3,  3,
 3,  3,  3,  3,  3,  3,  3,  3,  3,  2, 99, 99,  1,  1,  1,  1,
 1,  1,  3,  3,  3,  3,  3,  3,  3,  5,  3,  3,  2,  3,  1,  1,
 3,  3,  1,  1,  0,  4,  3,  3,  5,  5,  1,  0,  0,  0,  0,  0,
 ]

def hex(s):
    return " ".join(["%02X" % ord(i) for i in s])

#******************************************************************************

depth = 0
def lower():
    global depth
    depth += 1

def higher():
    global depth
    depth -= 1

def dprint(s):
    global depth
    print "%s%s" % (" " * depth, s)

#******************************************************************************

def bread(buffer, n):
    """ reads n chars from a buffer, returns n read and the truncated buffer"""
    return buffer[:n], buffer[n:]

def unpack_from_buffer(format, buffer):
    """UGLY HACK makes a buffer behave like a stream"""
    size = struct.calcsize(format)
    nread, buffer = bread(buffer, size)
    vars = struct.unpack(format, nread)
    return vars, buffer

#******************************************************************************


TAG_DESCS = {
    1 :"UTF-8 text",
    3 :"Integer",
    4 :"Float",
    5 :"Long",
    6 :"Double",
    7 :"Class",
    8 :"String constant",
    9 :"Field reference",
    10:"Method reference",
    11:"Interface Method reference",
    12:"Name and type"
    }

tags_types = [
    (1 ,"CONSTANT_Utf8"),
    (3 ,"CONSTANT_Integer"),
    (4 ,"CONSTANT_Float"),
    (5 ,"CONSTANT_Long"),
    (6 ,"CONSTANT_Double"),
    (7 ,"CONSTANT_Class"),
    (8 ,"CONSTANT_String"),
    (9 ,"CONSTANT_Fieldref"),
    (10,"CONSTANT_Methodref"),
    (11,"CONSTANT_InterfaceMethodref"),
    (12,"CONSTANT_NameAndType"),
    ]

TAGS_TYPES = dict([(i[1], i[0]) for i in tags_types] + tags_types)

#******************************************************************************

def parse_utf8_c(f):
    length = struct.unpack(">H", f.read(2))[0]
    bytes = f.read(length)
    return [length, bytes]

def parse_class_c(f):
    name_index = struct.unpack(">H", f.read(2))[0]
    return [name_index]

def parse_string_c(f):
    string_index = struct.unpack(">H", f.read(2))[0]
    return [string_index]


def parse_fldmethintmeth_c(f):
    class_index, name_and_type_index = struct.unpack(">2H", f.read(2 * 2))
    return [class_index, name_and_type_index]


def parse_fieldref_c(f):
    return parse_fldmethintmeth_c(f)

def parse_methodref_c(f):
    return parse_fldmethintmeth_c(f)

def parse_interfacemethodref_c(f):
    return parse_fldmethintmeth_c(f)

def parse_nameandtype_c(f):
    name_index, descriptor_index = struct.unpack(">2H", f.read(2 * 2))
    return [name_index, descriptor_index]


def parse_integer_c(f):
    bytes = struct.unpack(">L", f.read(4))[0]
    return [bytes]


def parse_float_c(f):
    return parse_integer


def parse_long_c(f):
    high_bytes, low_bytes = struct.unpack(">2L", f.read(2 * 4))
    return [high_bytes, low_bytes]


def parse_double_c(f):
    return parse_long(f)


def parse_constant(f):
    tag = struct.unpack(">B", f.read(1))[0]

    info = [
        None,
        parse_utf8_c,
        None,
        parse_integer_c, parse_float_c,
        parse_long_c, parse_double_c,
        parse_class_c,
        parse_string_c,
        parse_fieldref_c, parse_methodref_c, parse_interfacemethodref_c,
        parse_nameandtype_c][tag](f)
    return tag, info

#******************************************************************************


def print_utf8_c(constant):
    tag, info = constant
    if tag != TAGS_TYPES["CONSTANT_Utf8"]:
        print "ERROR - UTF8 constant expected"
        return

    [length, bytes] = info
    dprint("%s [UTF8 Text:%i]" % (bytes, length))
    return

def print_intfloat_c(constant):
    tag, info = constant
    if TAG_TYPES[tag] not in ["CONSTANT_Integer", "CONSTANT_Float"]:
        print "ERROR - Integer or Float constant expected"
    [bytes] = constant

    dprint("%04X" % bytes)
    return

def print_long_c(tag):
    tag, info = constant
    if TAG_TYPES[tag] not in ["CONSTANT_Long"]:
        print "ERROR - Long or Double constant expected"
    [high_bytes, low_bytes] = info

    dprint("%04X%04X [long]" % (high_bytes, low_bytes))
    return

def print_double_c(tag):
    tag, info = constant
    if TAG_TYPES[tag] not in ["CONSTANT_Double"]:
        print "ERROR - Long or Double constant expected"
    [high_bytes, low_bytes] = info

    dprint("%04X%04X [double]" % (high_bytes, low_bytes))


def print_class_c(constant):
    tag, info = constant
    if tag != TAGS_TYPES["CONSTANT_Class"]:
        print "ERROR - class constant expected"
        return
    [name_index] = info

    indexed_constant = constant_pool[name_index]
    if indexed_constant[0] != TAGS_TYPES["CONSTANT_Utf8"]:
        print "ERROR"
    dprint("Class: %s" % indexed_constant[1][1])

def print_string_c(constant):
    [tag, info] = constant
    if tag != TAGS_TYPES["CONSTANT_String"]:
        print "ERROR - string constant expected"
        return
    [name_index] = info

    indexed_constant = constant_pool[name_index]
    if indexed_constant[0] != TAGS_TYPES["CONSTANT_Utf8"]:
        print "ERROR"

    dprint("String: %s" % indexed_constant[1])


def print_fldmethintmeth_c(constant):
    tag, info = constant
    if TAGS_TYPES[tag] not in ["CONSTANT_Fieldref", "CONSTANT_Methodref", "CONSTANT_InterfaceMethodref"]:
        print "ERROR: expected Fieldref/Methodref/InterfaceMethodref type constant"
        return
    class_index, name_and_type_index = info
    lower()
    print_class_c(constant_pool[class_index])
    print_nameandtype_c(constant_pool[name_and_type_index])
    higher()


def print_nameandtype(name, type):
    """by indexes"""
    if constant_pool[name][0] != TAGS_TYPES["CONSTANT_Utf8"]:
        print "Error in name&type name's type"
    if constant_pool[type][0] != TAGS_TYPES["CONSTANT_Utf8"]:
        print "Error in name&type's type's type"

    name = constant_pool[name][1][1]
    type = constant_pool[type][1][1]
    dprint("Name: %s Type: %s" % (name, type))


def print_nameandtype_c(constant):
    tag, info = constant
    [name, type] = info
    print_nameandtype(name, type)


def print_constant(constant):
    tag, info = constant
    lower()
    [
        None,
        print_utf8_c,
        None,
        print_intfloat_c, print_intfloat_c,
        print_long_c, print_double_c,
        print_class_c,
        print_string_c,
        print_fldmethintmeth_c, print_fldmethintmeth_c, print_fldmethintmeth_c,
        print_nameandtype_c,
        ][tag](constant)
    higher()
    return


def print_flags(flags):
    print flags

"""
#multinewarray:
#	indexbyte16
#	dimensions8
#
#invokeinterface
#	indexbyte16
#	const8
#	zero8
"""

def parse_code(info):
    """not a parser at file level, already loaded in attribute info"""

    [max_stack, max_locals, code_length], info = unpack_from_buffer(">HHL", info)

    code, info = bread(info, code_length)

    lower()
    offset = 0
    while len(code) > 0:
        opcode_start = offset
        [opcode], code = unpack_from_buffer(">B", code)
        if opcode not in MNEMONICS:
            print "MNEMONIC absent"
            break;
        offset += 1

        nbops = NB_OPERANDS[opcode]
        operand = ()

        if opcode == "lookupswitch":
            pad = 4 - (opcode_start % 4)
            [pad, default, npairs], code = unpack_from_buffer(">%iBLL" % pad, code)

            offset += pad + 4  * (2 + npairs)

            pairs = [None] * npairs
            for i in xrange(npairs):
                [match, offset], code = unpack_from_buffer(">LL", code)
                pairs[i] = [match, offset]

        elif opcode == "tableswitch":
            pad = 4 - (opcode_start % 4)
            [pad, low, high], code = unpack_from_buffer(">%iBLLL" % pad, code)
            jumps = [None] * (high - low + 1)
            offset += pad + 4 * (2 + high - low + 1)

            for i in xrange(high - low + 1):
                [jump], code = unpack_from_buffer(">L", code)
                jumps[i] = jump

        elif opcode == "wide":
            [subopcode], code = unpack_from_buffer(">B", code)
            mnemonic = MNEMONIC[subopcode]

            if mnemonic in ["iload", "fload", "aload", "lload", "dload", "istore", "fstore", "astore", "lstore", "dstore", "ret"]:
                [operand], code = unpack_from_buffer(">H", code)
                offset += 2 + 1

            elif mnemonic == "iinc":
                [operand], code = unpack_from_buffer(">L", code)
                offset += 4 + 1
            else:
                print "ERROR: wrong opcode with wide"

        elif opcode == "invokeinterface":
            [index, const, zero], code = unpack_from_buffer(">HBB", code)
            offset += 4

        elif nbops in [0, 99]:
            print "ERROR"
            break;

        elif nbops == 2:
            operand, code = unpack_from_buffer(">B", code)
            offset += 1

        elif nbops == 3:
            operand, code = unpack_from_buffer(">H", code)
            offset += 2

        elif nbops == 4:
            operand, code = unpack_from_buffer(">LB", code)
            offset += 3

        elif nbops == 5:
            operand, code = unpack_from_buffer(">H", code)
            offset += 4

        dprint("%02X: %s\t\t%s" % (opcode_start, MNEMONICS[opcode], operand))
    higher()

    [exception_table_length], info = unpack_from_buffer(">H", info)
    exceptions = [None] * exception_table_length

    for i in xrange(exception_table_length):
        [start_pc, end_pc, handler_pc, catch_type], info = unpack_from_buffer(">4H", info)
        exceptions[i] = [start_pc, end_pc, handler_pc, catch_type]

    [attributes_count], info = unpack_from_buffer(">H", info)
    attributes = [None] * attributes_count

    assert attributes_count == 0 # no attribute_parser at buffer level for now :(

    dprint("Max stack:%i locals:%i" % (max_stack, max_locals))
    dprint("Exception table [%i]" % exception_table_length);
    lower()
    for i,j in exceptions:
        dprint("%i: %s" % (i, str(j)))
    higher()

    dprint("Attributes [%i]" % attributes_count);
    lower()
    for i,j in attributes:
        dprint("%i: %s" % (i, str(j)))
    higher()
    return


def print_attribute(attribute):
    attribute_name_index, attribute_length, info = attribute
    assert attribute_length == len(info)
    dprint("Name:")
    lower()
    print_utf8_c(constant_pool[attribute_name_index])
    dprint("Content: %s" % repr(info))
    attribute_name = constant_pool[attribute_name_index][1][1]
    att_parsers = {
        "Code": parse_code,
        #"Exceptions": pass,
        }

    # theoretically, the 'code' attributes includes themerde on doit filer tout le buffer et pas juste 'info' :(
    if attribute_name in att_parsers:
        dprint("'%s' specific content" % attribute_name)
        lower()
        att_parsers[attribute_name](info)
        higher()
    higher()


def print_fldmet(fldmet):
    lower()
    access_flags, name_index, descriptor_index, attributes_count, attributes = fldmet
    dprint("Access Flags: 0x%04X = %s" % (access_flags, enum(access_flags, METHOD_FLAGS_E)))
    print_nameandtype(name_index, descriptor_index)

    lower()
    dprint("attributes [%i]" % attributes_count)
    att_len = len(str(attributes))
    for i,j in enumerate(attributes):
        lower()
        dprint("att: %i" % i)
        print_attribute(j)
        higher()
    higher()
    higher()

#******************************************************************************

def parse_attribute(f):
    attribute_name_index, attribute_length = struct.unpack(">HL", f.read (2 + 4))
    info = f.read(attribute_length)
    return attribute_name_index, attribute_length, info


def parse_field(f):
    access_flags, name_index, descriptor_index, attributes_count = struct.unpack(">4H", f.read(4 * 2))
    attributes = [parse_attribute(f) for i in xrange(attributes_count)]
    return access_flags, name_index, descriptor_index, attributes_count, attributes


def parse_method(f):
    return parse_field(f)

#******************************************************************************

CLASS_FLAGS_E = {
    0x0001:"PUBLIC",
    0x0010:"FINAL",
    0x0020:"SUPER",
    0x0200:"INTERFACE",
    0x0400:"ABSTRACT",
    0x1000:"SYNTHETIC",
    0x2000:"ANNOTATION",
    0x4000:"ENUM",
    }

METHOD_FLAGS_E = {
    0x0001:"PUBLIC",
    0x0002:"PRIVATE",
    0x0004:"PROTECTED",
    0x0008:"STATIC",
    0x0010:"FINAL",
    0x0020:"SYNCHRONIZED",
    0x0040:"BRIDGE",
    0x0080:"VARARGS",
    0x0100:"NATIVE",
    0x0400:"ABSTRACT",
    0x0800:"STRICT",
    0x1000:"SYNTHETIC",
    }

FIELDS_FLAGS_E = {
    0x0001:"PUBLIC",
    0x0002:"PRIVATE",
    0x0004:"PROTECTED",
    0x0008:"STATIC",
    0x0010:"FINAL",
    0x0040:"VOLATILE",
    0x0080:"TRANSIENT",
    0x1000:"SYNTHETIC",
    0x4000:"ENUM",
    }
#******************************************************************************

f = open(sys.argv[1], "rb")
magic, minor_version, major_version, constant_pool_count = struct.unpack(">LHHH", f.read(4 + 2 + 2 + 2))

constant_pool = [None] * constant_pool_count
i = 1
while i < constant_pool_count:
    pool = parse_constant(f)
    constant_pool[i] = pool
    i += 1
    if pool[0] in [5,6]:
        constant_pool[i] = None
        i += 1

access_flags, this_class, super_class = struct.unpack(">3H", f.read(3 * 2))

interfaces_count = struct.unpack(">H", f.read(2))[0]
interfaces = [parse_interface(f) for i in xrange(interfaces_count)]

fields_count = struct.unpack(">H", f.read(2))[0]
fields = [parse_field(f) for i in xrange(fields_count)]

methods_count = struct.unpack(">H", f.read(2))[0]
methods = [parse_method(f) for i in xrange(methods_count)]

attributes_count = struct.unpack(">H", f.read(2))[0]
attributes = [parse_attribute(f) for i in xrange(attributes_count)]

#******************************************************************************
# rendering

print "Signature: %08X" % magic
print "version %i.%i" % (major_version, minor_version)
dprint("constant pool [%i]" % constant_pool_count)

format = "%0"+ ("%i" % len(str(constant_pool_count))) + "i"

lower()
for i,j in enumerate(constant_pool):
    if j is not None:
        dprint(format % i)
        print_constant(j)
higher()

print

def enum(val, flags):
    l = []
    for flag in flags:
        if (flag & val):
            val -= flag
            l.append(flags[flag])
    if val != 0:
        return "UNEXPECTED FLAG: %i: val"
    return " | ".join(l)

dprint("Access Flags: 0x%04X (%s)" % (access_flags, enum(access_flags, CLASS_FLAGS_E)))

dprint("This class:")
print_class_c(constant_pool[this_class])

dprint("Super class:")
print_class_c(constant_pool[super_class])

dprint("interfaces [%i]" % interfaces_count)
for inter in interfaces:
    print_interface(inter)

dprint("fields [%i]" % fields_count)
for field in fields:
    print_fldmet(field)

dprint("methods [%i]" % methods_count)
for method in methods:
    print_fldmet(method)

dprint("attributes [%i]" % attributes_count)
for attribute in attributes:
    print_attribute(attribute)
