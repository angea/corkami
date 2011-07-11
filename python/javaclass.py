# simple java .class parser

# Ange Albertini, BSD Licence, 2011

import pprint
import sys
import struct

access_flags_class = [
    ("ACC_PUBLIC", 0x0001),
    ("ACC_FINAL", 0x0010),
    ("ACC_SUPER", 0x0020),
    ("ACC_INTERFACE", 0x0200),
    ("ACC_ABSTRACT", 0x0400),
    ("ACC_SYNTHETIC", 0x1000),
    ("ACC_ANNOTATION", 0x2000), # **
    ("ACC_ENUM", 0x4000), # *
    ]

ACCESS_FLAGS_CLASS = dict([(i[1], i[0]) for i in access_flags_class] + access_flags_class)

access_flags_field = [
    ("ACC_PUBLIC", 0x0001),
    ("ACC_PRIVATE", 0x0002),
    ("ACC_PROTECTED", 0x0004),
    ("ACC_STATIC", 0x0008),
    ("ACC_FINAL", 0x0010),
    ("ACC_VOLATILE", 0x0040),
    ("ACC_TRANSIENT", 0x0080),
    ("ACC_SYNTHETIC", 0x1000),
    ("ACC_ENUM", 0x4000), # *
    ]

ACCESS_FLAGS_FIELD = dict([(i[1], i[0]) for i in access_flags_field] + access_flags_field)

access_flags_method = [
    ("ACC_PUBLIC", 0x0001),
    ("ACC_PRIVATE", 0x0002),
    ("ACC_PROTECTED", 0x0004),
    ("ACC_STATIC", 0x0008),
    ("ACC_FINAL", 0x0010),
    ("ACC_SYNCHRONIZED", 0x0020),
    ("ACC_BRIDGE", 0x0040), # *
    ("ACC_VARARGS", 0x0080), # *
    ("ACC_NATIVE", 0x0100),
    ("ACC_ABSTRACT", 0x0400),
    ("ACC_STRICT", 0x0800),
    ("ACC_SYNTHETIC", 0x1000),
    ]

ACCESS_FLAGS_METHOD = dict([(i[1], i[0]) for i in access_flags_method] + access_flags_method)

opcodes = [
("nop", 0), # do nothing

("aconst_null", 1), # push /null/

("iconst_m1", 2 + 0), # push /int/ -1
("iconst_0",  2 + 1), # push /int/ 0
("iconst_1",  2 + 2), # push /int/ 1
("iconst_2",  2 + 3), # push /int/ 2
("iconst_3",  2 + 4), # push /int/ 3
("iconst_4",  2 + 5), # push /int/ 4
("iconst_5",  2 + 6), # push /int/ 5

("lconst_0", 9 + 0), # push /long/ 0
("lconst_1", 9 + 1), # push /long/ 1

("fconst_0", 11 + 0), # push /float/ 0.0
("fconst_1", 11 + 1), # push /float/ 1.0
("fconst_2", 11 + 2), # push /float/ 2.0

("dconst_0", 14 + 0), # push /double/ 0.0
("dconst_1", 14 + 1), # push /double/ 1.0

("bipush", 16), # push /byte/
("sipush", 17), # push /short/

("aload", 25),  # load /reference/ from local variable
("aload_0", 42 + 0),
("aload_1", 42 + 1),
("aload_2", 42 + 2),
("aload_3", 42 + 3),
("astore", 58), # store /reference/ into local variable
("astore_0", 75 + 0),
("astore_1", 75 + 1),
("astore_2", 75 + 2),
("astore_3", 75 + 3),

("anewarray", 189), # create new array of /reference/
("areturn", 176), # return /reference/ from method
("arraylength", 190), # get length of array


("athrow", 191), # throw exception or error

("iaload", 46), # load /int/ from array
("laload", 47), # load /long/ from array
("faload", 48), # load /float/ from array
("daload", 49), # load /double/ from array
("aaload", 50), # load /reference/ from array
("baload", 51), # load /byte/ or /boolean/ from array
("caload", 52), # load /char/ from array
("saload", 53), # load /short/ from array
("iastore", 79), # store into /int/ array
("lastore", 80), # store into /long/ array
("fastore", 81), # store into /float/ array
("dastore", 82), # store into /double/ array
("aastore", 83), # store into /reference/ array
("bastore", 84), # store into /byte/ or /boolean/ array
("castore", 85), # store into /char/ array
("sastore", 86), # store into /short/ array

("lcmp", 148), # compare /long/

("checkcast", 192), # check whether object is of given type

("f2i", 139), # convert /float/ to /int/
("f2l", 140), # convert /float/ to /long/
("f2d", 141), # convert /float/ to /double/

("d2i", 142), # convert /double/ to /int/
("d2l", 143), # convert /double/ to /long/
("d2f", 144), # convert /double/ to /float/

("i2b", 145), # convert /int/ to /byte/
("i2c", 146), # convert /int/ to /char/
("i2s", 147), # convert /int/ to /short/
("i2l", 133), # convert /int/ to /long/
("i2f", 134), # convert /int/ to /float/
("i2d", 135), # convert /int/ to /double/

("l2d", 138), # convert /long/ to /double/
("l2f", 137), # convert /long/ to /float/
("l2i", 136), # convert /long/ to /int/

("fcmpl", 149 + 0), # compare /double/
("fcmpg", 149 + 1), # compare /double/

("dcmpl", 151 + 0), # compare /double/
("dcmpg", 151 + 1), # compare /double/

("iadd", 96), # add /int/
("ladd", 97), # add /long/
("fadd", 98), # add /float/
("dadd", 99), # add /double/

("ldc", 18), # push item from runtime constant pool
("ldc_w", 19), # push item from runtime constant pool (wide index)
("ldc2_w", 20), # push /long/ or /double/ from runtime constant pool

("isub", 100), # substract /int/
("lsub", 101), # substract /long/
("fsub", 102), # substract /float/
("dsub", 103), # substract /double/

("imul", 104), # multiply /int/
("lmul", 105), # multiply /long/
("fmul", 106), # multiply /float/
("dmul", 107), # multiply /double/

("idiv", 108), # divide /int/
("ldiv", 109), # divide /long/
("fdiv", 110), # divide /float/
("ddiv", 111), # divide /double/

("ineg" , 116), # negate /int/
("lneg" , 117), # negate /long/
("fneg" , 118), # negate /float/
("dneg" , 119), # negate /double/

("irem" , 112), # remainder /int/
("lrem" , 113), # remainder /long/
("frem" , 114), # remainder /float/
("drem" , 115), # remainder /double/

("ireturn", 172), # return /int/ from method
("lreturn", 173), # return /long/ from method
("freturn", 174), # return /float/ from method
("dreturn", 175), # return /double/ from method

("lload", 22), # load /long/ from local variable
("lload_0", 30 + 0),
("lload_1", 30 + 1),
("lload_2", 30 + 2),
("lload_3", 30 + 3),
("lstore", 55), # store /long/ into local variable
("lstore_0", 63 + 0),
("lstore_1", 63 + 1),
("lstore_2", 63 + 2),
("lstore_3", 63 + 3),

("iload", 21), # load /int/ from local variable
("iload_0", 26 + 0),
("iload_1", 26 + 1),
("iload_2", 26 + 2),
("iload_3", 26 + 3),
("istore", 54), # store /int/ into local variable
("istore_0", 59 + 0),
("istore_1", 59 + 1),
("istore_2", 59 + 2),
("istore_3", 59 + 3),

("fload", 23), # load /float/ from local variable
("fload_0", 34 + 0),
("fload_1", 34 + 1),
("fload_2", 34 + 2),
("fload_3", 34 + 3),
("fstore", 56), # store /float/ into local variable
("fstore_0", 67 + 0),
("fstore_1", 67 + 1),
("fstore_2", 67 + 2),
("fstore_3", 67 + 3),

("dload", 24), # load /double/ from local variable
("dload_0", 38 + 0),
("dload_1", 38 + 1),
("dload_2", 38 + 2),
("dload_3", 38 + 3),
("dstore", 57), # store /double/ into local variable
("dstore_0", 71 + 0),
("dstore_1", 71 + 1),
("dstore_2", 71 + 2),
("dstore_3", 71 + 3),


("dup", 89), # duplicate the top operand stack value
("dup_x1", 90), # duplicate the top operand stack value and insert two values down
("dup_x2", 91), # duplicate the top operand stack value and insert two or three values down
("dup2", 92), # duplicate the top one or two operand stack values
("dup2_x1", 93), # duplicate the top or two operand stack values and insert two or three values down
("dup2_x2", 94), # duplicate the top or two operand stack values and insert two, three or four values down

("if" + "eq", 153 + 0), # Branch if /int/ comparison with zero succeeds
("if" + "ne", 153 + 1), # Branch if /int/ comparison with zero succeeds
("if" + "lt", 153 + 2), # Branch if /int/ comparison with zero succeeds
("if" + "ge", 153 + 3), # Branch if /int/ comparison with zero succeeds
("if" + "gt", 153 + 4), # Branch if /int/ comparison with zero succeeds
("if" + "ge", 153 + 5), # Branch if /int/ comparison with zero succeeds

("if_imp" + "eq", 159 + 0), # Branch if /int/ comparison succeeds
("if_imp" + "ne", 159 + 1), # Branch if /int/ comparison succeeds
("if_imp" + "lt", 159 + 2), # Branch if /int/ comparison succeeds
("if_imp" + "ge", 159 + 3), # Branch if /int/ comparison succeeds
("if_imp" + "gt", 159 + 4), # Branch if /int/ comparison succeeds
("if_imp" + "ge", 159 + 5), # Branch if /int/ comparison succeeds

("if_acmp" + "eq", 165 + 0), # Branch if /reference/ comparison succeeds
("if_acmp" + "ne", 165 + 1), # Branch if /reference/ comparison succeeds

("ifnull", 198), # branch if /reference/ null
("ifnonnull", 199), #branch if /reference/ not null

("iinc", 132), # increment local variable by constant

("goto", 167), # branch always
("goto_w", 200), # branch always (wide index)

("ishl", 120), # shift left /int/
("lshl", 121), # shift left /long/
("ishr", 122), # arithmetic shift right /int/
("lshr", 123), # arithmetic shift right /long/
("iushr", 124), # logical shift right /int/
("lushr", 125), # logical shift right /long/
("iand", 126), # boolean AND /int/
("land", 127), # boolean AND /long/
("ior", 128), # boolean OR /int/
("lor", 129), # boolean OR /long/
("ixor", 130), # boolean XOR /int/
("lor", 131), # boolean XOR /long/

("jsr", 168), # jump subroutine
("jsr_w", 201), # jump subroutine (wide index)


("instanceof", 193), # determine if object is of given type

("invokevirtual", 182), # invoke instance method; dispatch based on class
("invokespecial", 183), # invoke instance method; special handling for superclass, private, and instance initialization method invocations
("invokestatic", 184), # invoke a class (/static/) method
("invokeinterface", 185), # invoke interface method

("tableswitch", 170), # access jump table by index and jump
("lookupswitch", 171), # access jump table by key match and jump

("getstatic", 178), # get /static/ field from class
("putstatic", 179), # set /static/ field in class
("getfield", 180), # fetch field from object
("putfield", 181), # set field in object

("monitorenter", 194), # enter monitor for object
("monitorexit", 195), # exit monitor for object

("multianewarray", 197), # create new multidimensional array
("new", 187), # create new object
("newarray", 188), # create new array


("swap", 95), # swap the top two operand stack values
("pop", 87), # pop the top operand stack value
("pop2", 88), # pop the top one or two operand stack values

("ret", 169), # return from subroutine
("return", 177), # return /void/ from method
("wide", 196), # extend local variable index by additional bytes

("breakpoint", 202), # reserved
("impdep1", 254), # reserved
("impdep2", 255), # reserved
]

arguments = [
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


OPCODES = dict([(i[1], i[0]) for i in opcodes] + opcodes)

# t = []
# for i in range(16):
#     l = ["%02X" % (i * 16)]
#     for j in range(16):
#         opcode = i * 16 + j
#         text = OPCODES[opcode] if opcode in OPCODES else ""
#         l.append(text.rjust(15))
#     t.append(" ".join(l))
# with open("opcodes.txt", "wt") as f:
#     f.write("\n".join(t))

def get_flags(value, flags_mapping):
    flags = []
    for i, j in sorted(flags_mapping.iteritems()):
        if type(i) != int:
            continue
        if (value & i) == i:
            flags.append([j])
    return flags

def make_flag(flags, flags_mapping):
    value = 0
    for flag in flags:
        value |= flags_mapping[flag]
    return value

assert [['ACC_PUBLIC'], ['ACC_FINAL']] == get_flags (1 + 0x10, ACCESS_FLAGS_CLASS)
assert 0x11 == make_flag(["ACC_PUBLIC", "ACC_FINAL"], ACCESS_FLAGS_CLASS)

def disasm_code(code):
    listing = []
    offset = 0
    while offset < len(code):
        opcode_byte = ord(code[offset : offset + 1])
        offset += 1
        if opcode_byte == 0xb1:
            opcode = "return"
            listing.append(["return"])

        elif opcode_byte == 0x12:
            listing.append(["ldc %s" % constant_pool[struct.unpack(">B", code[offset: offset + 1])[0] - 1]])
            offset += 1

        elif opcode_byte == 0xb2:
            operand = constant_pool[struct.unpack(">H", code[offset: offset + 2])[0] - 1]
            listing.append(["getstatic"])
            offset += 2

        elif opcode_byte == 0xb6:
            listing.append(["invokevirtual"])
            offset += 2
        else:
            return listing

    return listing


def get_exception_table(f, exception_table_length):
    exception_table = []
    for k in range(exception_table_length):
        start_pc = struct.unpack(">H", f.read(2))[0]
        end_pc = struct.unpack(">H", f.read(2))[0]
        handler_pc = struct.unpack(">H", f.read(2))[0]
        catch_type = struct.unpack(">H", f.read(2))[0]

        exception_table.append([start_pc, end_pc, handler_pc, catch_type])
    return exception_table

def get_attributes(f, attributes_count):
    attributes = []
    for j in range(attributes_count):
        attribute_name_index = struct.unpack(">H", f.read(2))[0]
        attribute_name = constant_pool[attribute_name_index - 1][2]

        attribute_length = struct.unpack(">L", f.read(4))[0]

        if attribute_name == "Code":
            max_stack = struct.unpack(">H", f.read(2))[0]
            max_locals = struct.unpack(">H", f.read(2))[0]
            code_length = struct.unpack(">L", f.read(4))[0]
            code = f.read(code_length)
            code = disasm_code(code)
            exception_table_length = struct.unpack(">H", f.read(2))[0]
            exception_table = get_exception_table(f, exception_table_length)

            attributes_count2 = struct.unpack(">H", f.read(2))[0]
            attributes2 = get_attributes(f,attributes_count2)

            attributes.append([max_stack, max_locals, code, exception_table, attributes2])
        else:
            info = f.read(attribute_length)
            attributes.append([attribute_name_index, info])
    return attributes

f = open(sys.argv[1], "rb")

magic = struct.unpack(">L", f.read(4))[0]
if magic != 0xcafebabe:
    print "wrong magic"
    sys.exit()
minor_version = struct.unpack(">H", f.read(2))[0]
major_version = struct.unpack(">H", f.read(2))[0]
print "version: %i.%i" % (major_version, minor_version)
print
constant_pool_count = struct.unpack(">H", f.read(2))[0]

constant_pool = []
for i in range(constant_pool_count - 1):
    print "%03i" % (i + 1),
    tag = struct.unpack(">B", f.read(1))[0]

    if tag == 1: # CONSTANT_utf8
        length = struct.unpack(">H", f.read(2))[0]
        bytes = f.read(length)
        constant_pool.append([tag, length, bytes])
        print "utf8", bytes

    elif tag == 3: # integer
        bytes = struct.unpack(">L", f.read(4))[0]
        constant_pool.append([tag, bytes])

    elif tag == 4: # float
        bytes = struct.unpack(">L", f.read(4))[0]
        constant_pool.append([tag, bytes])

    elif tag == 5: # long
        high_bytes = struct.unpack(">L", f.read(4))[0]
        low_bytes = struct.unpack(">L", f.read(4))[0]
        constant_pool.append([tag, high_bytes, low_bytes])

    elif tag == 6: # double
        high_bytes = struct.unpack(">L", f.read(4))[0]
        low_bytes = struct.unpack(">L", f.read(4))[0]
        constant_pool.append([tag, high_bytes, low_bytes])

    elif tag == 7: #class
        name_index = struct.unpack(">H", f.read(2))[0]
        constant_pool.append([tag, name_index])
        print "class" # => %s" % constant_pool[name_index - 1]

    elif tag == 8: #string
        string_index = struct.unpack(">H", f.read(2))[0]
        constant_pool.append([tag, string_index])
        print "string => %s" % constant_pool[string_index - 1]

    elif tag == 9: #fieldref
        class_index = struct.unpack(">H", f.read(2))[0]
        name_and_type_index = struct.unpack(">H", f.read(2))[0]
        constant_pool.append([tag, class_index, name_and_type_index])
        print "fieldref"

    elif tag == 10: #methodref
        class_index = struct.unpack(">H", f.read(2))[0]
        name_and_type_index = struct.unpack(">H", f.read(2))[0]
        constant_pool.append([tag, class_index, name_and_type_index])
        print "methodref"

    elif tag == 11: #interfacemethodref
        class_index = struct.unpack(">H", f.read(2))[0]
        name_and_type_index = struct.unpack(">H", f.read(2))[0]
        constant_pool.append([tag, class_index, name_and_type_index])
        print "interfacemethodref"

    elif tag == 12: #nameandtype
        name_index = struct.unpack(">H", f.read(2))[0]
        descriptor_index = struct.unpack(">H", f.read(2))[0]
        print "nameandtype" # %s, %s" % (constant_pool[name_index - 1], constant_pool[descriptor_index - 1])

access_flags = struct.unpack(">H", f.read(2))[0]
this_class = struct.unpack(">H", f.read(2))[0]
super_class = struct.unpack(">H", f.read(2))[0]

interfaces_count = struct.unpack(">H", f.read(2))[0]
interfaces = []
for i in range(interfaces_count):
    interfaces.append([struct.unpack(">H", f.read(2))[0]])

print "interfaces", interfaces

field_count = struct.unpack(">H", f.read(2))[0]
fields = []
for i in range(field_count):
    access_flags = struct.unpack(">H", f.read(2))[0]
    name_index = struct.unpack(">H", f.read(2))[0]
    descriptor_index = struct.unpack(">H", f.read(2))[0]
    attributes_count = struct.unpack(">H", f.read(2))[0]
    attributes = get_attributes(f, attributes_count)

    fields.append([access_flags, name_index, descriptor_index, attributes])

print "fields", fields

methods_count = struct.unpack(">H", f.read(2))[0]
methods = []
for i in range(methods_count):
    access_flags = struct.unpack(">H", f.read(2))[0]
    name_index = struct.unpack(">H", f.read(2))[0]
    descriptor_index = struct.unpack(">H", f.read(2))[0]
    attributes_count = struct.unpack(">H", f.read(2))[0]
    attributes = get_attributes(f, attributes_count)
    methods.append([access_flags, name_index, descriptor_index, attributes])

print "methods", 
pprint.pprint(methods)

attributes_count = struct.unpack(">H", f.read(2))[0]
attributes = get_attributes(f, attributes_count)
print "attributes", attributes
