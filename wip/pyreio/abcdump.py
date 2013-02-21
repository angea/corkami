# WIP of a port of Tamarin's abcdump

#case OP_lookupswitch:
#    var pos = code.position-1;
#    var target = pos + readS24()
#    var maxindex = readU32()
#    s += "default:" + labels.labelFor(target) // target + "("+(target-pos)+")"
#    s += " maxcase:" + maxindex
#    for (var i:int=0; i <= maxindex; i++) {
#        target = pos + readS24();
#        s += " " + labels.labelFor(target) // target + "("+(target-pos)+")"
#    }
#    break;





UNUSED1 = """
// method flags
const NEED_ARGUMENTS = 		0x01
const NEED_ACTIVATION = 	0x02
const NEED_REST = 			0x04
const HAS_OPTIONAL = 		0x08
const IGNORE_REST = 		0x10
const NATIVE =				0x20
const HAS_ParamNames =      0x80

const CONSTANT_Utf8					 = 0x01
const CONSTANT_Int					 = 0x03
const CONSTANT_UInt					 = 0x04
const CONSTANT_PrivateNs			 = 0x05 // non-shared namespace
const CONSTANT_Double				 = 0x06
const CONSTANT_Qname				 = 0x07 // o.ns::name, ct ns, ct name
const CONSTANT_Namespace			 = 0x08
const CONSTANT_Multiname			 = 0x09 // o.name, ct nsset, ct name
const CONSTANT_False				 = 0x0A
const CONSTANT_True					 = 0x0B
const CONSTANT_Null					 = 0x0C
const CONSTANT_QnameA				 = 0x0D // o.@ns::name, ct ns, ct attr-name
const CONSTANT_MultinameA			 = 0x0E // o.@name, ct attr-name
const CONSTANT_RTQname				 = 0x0F // o.ns::name, rt ns, ct name
const CONSTANT_RTQnameA				 = 0x10 // o.@ns::name, rt ns, ct attr-name
const CONSTANT_RTQnameL				 = 0x11 // o.ns::[name], rt ns, rt name
const CONSTANT_RTQnameLA			 = 0x12 // o.@ns::[name], rt ns, rt attr-name
const CONSTANT_NameL				 = 0x13	// o.[], ns=public implied, rt name
const CONSTANT_NameLA				 = 0x14 // o.@[], ns=public implied, rt attr-name
const CONSTANT_NamespaceSet			 = 0x15
const CONSTANT_PackageNs			 = 0x16
const CONSTANT_PackageInternalNs	 = 0x17
const CONSTANT_ProtectedNs			 = 0x18
const CONSTANT_StaticProtectedNs	 = 0x19
const CONSTANT_StaticProtectedNs2	 = 0x1a
const CONSTANT_MultinameL            = 0x1B
const CONSTANT_MultinameLA           = 0x1C
const CONSTANT_TypeName              = 0x1D

const constantKinds:Array = [ "0", "utf8", "2",
"int", "uint", "private", "double", "qname", "namespace",
"multiname", "false", "true", "null", "@qname", "@multiname", "rtqname",
"@rtqname", "[qname]", "@[qname]", "[name]", "@[name]", "nsset"
]

const TRAIT_Slot		 = 0x00
const TRAIT_Method		 = 0x01
const TRAIT_Getter		 = 0x02
const TRAIT_Setter		 = 0x03
const TRAIT_Class		 = 0x04
const TRAIT_Function	 = 0x05
const TRAIT_Const		 = 0x06

const traitKinds:Array = [
"var", "function", "function get", "function set", "class", "function", "const"
]

const ATTR_final			 = 0x01; // 1=final, 0=virtual
const ATTR_override          = 0x02; // 1=override, 0=new
const ATTR_metadata          = 0x04; // 1=has metadata, 0=no metadata
const ATTR_public            = 0x08; // 1=add public namespace

const CLASS_FLAG_sealed		 = 0x01;
const CLASS_FLAG_final		 = 0x02;
const CLASS_FLAG_interface	 = 0x04;
"""

OP_bkpt = 0x01
OP_nop = 0x02
OP_throw = 0x03
OP_getsuper = 0x04
OP_setsuper = 0x05
OP_dxns = 0x06
OP_dxnslate = 0x07
OP_kill = 0x08
OP_label = 0x09
OP_ifnlt = 0x0C
OP_ifnle = 0x0D
OP_ifngt = 0x0E
OP_ifnge = 0x0F
OP_jump = 0x10
OP_iftrue = 0x11
OP_iffalse = 0x12
OP_ifeq = 0x13
OP_ifne = 0x14
OP_iflt = 0x15
OP_ifle = 0x16
OP_ifgt = 0x17
OP_ifge = 0x18
OP_ifstricteq = 0x19
OP_ifstrictne = 0x1A
OP_lookupswitch = 0x1B
OP_pushwith = 0x1C
OP_popscope = 0x1D
OP_nextname = 0x1E
OP_hasnext = 0x1F
OP_pushnull = 0x20
OP_pushundefined = 0x21
OP_pushconstant = 0x22
OP_nextvalue = 0x23
OP_pushbyte = 0x24
OP_pushshort = 0x25
OP_pushtrue = 0x26
OP_pushfalse = 0x27
OP_pushnan = 0x28
OP_pop = 0x29
OP_dup = 0x2A
OP_swap = 0x2B
OP_pushstring = 0x2C
OP_pushint = 0x2D
OP_pushuint = 0x2E
OP_pushdouble = 0x2F
OP_pushscope = 0x30
OP_pushnamespace = 0x31
OP_hasnext2 = 0x32
OP_li8 = 0x35
OP_li16 = 0x36
OP_li32 = 0x37
OP_lf32 = 0x38
OP_lf64 = 0x39
OP_si8 = 0x3A
OP_si16 = 0x3B
OP_si32 = 0x3C
OP_sf32 = 0x3D
OP_sf64 = 0x3E
OP_newfunction = 0x40
OP_call = 0x41
OP_construct = 0x42
OP_callmethod = 0x43
OP_callstatic = 0x44
OP_callsuper = 0x45
OP_callproperty = 0x46
OP_returnvoid = 0x47
OP_returnvalue = 0x48
OP_constructsuper = 0x49
OP_constructprop = 0x4A
OP_callsuperid = 0x4B
OP_callproplex = 0x4C
OP_callinterface = 0x4D
OP_callsupervoid = 0x4E
OP_callpropvoid = 0x4F
OP_sxi1 = 0x50
OP_sxi8 = 0x51
OP_sxi16 = 0x52
OP_applytype = 0x53
OP_newobject = 0x55
OP_newarray = 0x56
OP_newactivation = 0x57
OP_newclass = 0x58
OP_getdescendants = 0x59
OP_newcatch = 0x5A
OP_findpropstrict = 0x5D
OP_findproperty = 0x5E
OP_finddef = 0x5F
OP_getlex = 0x60
OP_setproperty = 0x61
OP_getlocal = 0x62
OP_setlocal = 0x63
OP_getglobalscope = 0x64
OP_getscopeobject = 0x65
OP_getproperty = 0x66
OP_getouterscope = 0x67
OP_initproperty = 0x68
OP_setpropertylate = 0x69
OP_deleteproperty = 0x6A
OP_deletepropertylate = 0x6B
OP_getslot = 0x6C
OP_setslot = 0x6D
OP_getglobalslot = 0x6E
OP_setglobalslot = 0x6F
OP_convert_s = 0x70
OP_esc_xelem = 0x71
OP_esc_xattr = 0x72
OP_convert_i = 0x73
OP_convert_u = 0x74
OP_convert_d = 0x75
OP_convert_b = 0x76
OP_convert_o = 0x77
OP_coerce = 0x80
OP_coerce_b = 0x81
OP_coerce_a = 0x82
OP_coerce_i = 0x83
OP_coerce_d = 0x84
OP_coerce_s = 0x85
OP_astype = 0x86
OP_astypelate = 0x87
OP_coerce_u = 0x88
OP_coerce_o = 0x89
OP_negate = 0x90
OP_increment = 0x91
OP_inclocal = 0x92
OP_decrement = 0x93
OP_declocal = 0x94
OP_typeof = 0x95
OP_not = 0x96
OP_bitnot = 0x97
OP_add_d = 0x9B
OP_add = 0xA0
OP_subtract = 0xA1
OP_multiply = 0xA2
OP_divide = 0xA3
OP_modulo = 0xA4
OP_lshift = 0xA5
OP_rshift = 0xA6
OP_urshift = 0xA7
OP_bitand = 0xA8
OP_bitor = 0xA9
OP_bitxor = 0xAA
OP_equals = 0xAB
OP_strictequals = 0xAC
OP_lessthan = 0xAD
OP_lessequals = 0xAE
OP_greaterthan = 0xAF
OP_greaterequals = 0xB0
OP_instanceof = 0xB1
OP_istype = 0xB2
OP_istypelate = 0xB3
OP_in = 0xB4
OP_increment_i = 0xC0
OP_decrement_i = 0xC1
OP_inclocal_i = 0xC2
OP_declocal_i = 0xC3
OP_negate_i = 0xC4
OP_add_i = 0xC5
OP_subtract_i = 0xC6
OP_multiply_i = 0xC7
OP_getlocal0 = 0xD0
OP_getlocal1 = 0xD1
OP_getlocal2 = 0xD2
OP_getlocal3 = 0xD3
OP_setlocal0 = 0xD4
OP_setlocal1 = 0xD5
OP_setlocal2 = 0xD6
OP_setlocal3 = 0xD7
OP_debug = 0xEF
OP_debugline = 0xF0
OP_debugfile = 0xF1
OP_bkptline = 0xF2


OPCODES = [
"OP_0x00       ",
"bkpt          ",
"nop           ",
"throw         ",
"getsuper      ",
"setsuper      ",
"dxns          ",
"dxnslate      ",
"kill          ",
"label         ",
"OP_0x0A       ",
"OP_0x0B       ",
"ifnlt         ",
"ifnle         ",
"ifngt         ",
"ifnge         ",
"jump          ",
"iftrue        ",
"iffalse       ",
"ifeq          ",
"ifne          ",
"iflt          ",
"ifle          ",
"ifgt          ",
"ifge          ",
"ifstricteq    ",
"ifstrictne    ",
"lookupswitch  ",
"pushwith      ",
"popscope      ",
"nextname      ",
"hasnext       ",
"pushnull      ",
"pushundefined ",
"pushconstant  ",
"nextvalue     ",
"pushbyte      ",
"pushshort     ",
"pushtrue      ",
"pushfalse     ",
"pushnan       ",
"pop           ",
"dup           ",
"swap          ",
"pushstring    ",
"pushint       ",
"pushuint      ",
"pushdouble    ",
"pushscope     ",
"pushnamespace ",
"hasnext2      ",
"OP_0x33       ", # lix8 (internal)
"OP_0x34       ", # lix16 (internal)
"li8           ",
"li16          ",
"li32          ",
"lf32          ",
"lf64          ",
"si8           ",
"si16          ",
"si32          ",
"sf32          ",
"sf64          ",
"OP_0x3F       ",
"newfunction   ",
"call          ",
"construct     ",
"callmethod    ",
"callstatic    ",
"callsuper     ",
"callproperty  ",
"returnvoid    ",
"returnvalue   ",
"constructsuper",
"constructprop ",
"callsuperid   ",
"callproplex   ",
"callinterface ",
"callsupervoid ",
"callpropvoid  ",
"sxi1          ",
"sxi8          ",
"sxi16         ",
"applytype     ",
"OP_0x54       ",
"newobject     ",
"newarray      ",
"newactivation ",
"newclass      ",
"getdescendants",
"newcatch      ",
"OP_0x5B       ", # findpropglobalstrict (internal)
"OP_0x5C       ", # findpropglobal (internal)
"findpropstrict",
"findproperty  ",
"finddef       ",
"getlex        ",
"setproperty   ",
"getlocal      ",
"setlocal      ",
"getglobalscope",
"getscopeobject",
"getproperty   ",
"getouterscope ",
"initproperty  ",
"OP_0x69       ",
"deleteproperty",
"OP_0x6B       ",
"getslot       ",
"setslot       ",
"getglobalslot ",
"setglobalslot ",
"convert_s     ",
"esc_xelem     ",
"esc_xattr     ",
"convert_i     ",
"convert_u     ",
"convert_d     ",
"convert_b     ",
"convert_o     ",
"checkfilter   ",
"OP_0x79       ",
"OP_0x7A       ",
"OP_0x7B       ",
"OP_0x7C       ",
"OP_0x7D       ",
"OP_0x7E       ",
"OP_0x7F       ",
"coerce        ",
"coerce_b      ",
"coerce_a      ",
"coerce_i      ",
"coerce_d      ",
"coerce_s      ",
"astype        ",
"astypelate    ",
"coerce_u      ",
"coerce_o      ",
"OP_0x8A       ",
"OP_0x8B       ",
"OP_0x8C       ",
"OP_0x8D       ",
"OP_0x8E       ",
"OP_0x8F       ",
"negate        ",
"increment     ",
"inclocal      ",
"decrement     ",
"declocal      ",
"typeof        ",
"not           ",
"bitnot        ",
"OP_0x98       ",
"OP_0x99       ",
"OP_0x9A       ",
"add_d         ",
"OP_0x9C       ",
"OP_0x9D       ",
"OP_0x9E       ",
"OP_0x9F       ",
"add           ",
"subtract      ",
"multiply      ",
"divide        ",
"modulo        ",
"lshift        ",
"rshift        ",
"urshift       ",
"bitand        ",
"bitor         ",
"bitxor        ",
"equals        ",
"strictequals  ",
"lessthan      ",
"lessequals    ",
"greaterthan   ",
"greaterequals ",
"instanceof    ",
"istype        ",
"istypelate    ",
"in            ",
"OP_0xB5       ",
"OP_0xB6       ",
"OP_0xB7       ",
"OP_0xB8       ",
"OP_0xB9       ",
"OP_0xBA       ",
"OP_0xBB       ",
"OP_0xBC       ",
"OP_0xBD       ",
"OP_0xBE       ",
"OP_0xBF       ",
"increment_i   ",
"decrement_i   ",
"inclocal_i    ",
"declocal_i    ",
"negate_i      ",
"add_i         ",
"subtract_i    ",
"multiply_i    ",
"OP_0xC8       ",
"OP_0xC9       ",
"OP_0xCA       ",
"OP_0xCB       ",
"OP_0xCC       ",
"OP_0xCD       ",
"OP_0xCE       ",
"OP_0xCF       ",
"getlocal0     ",
"getlocal1     ",
"getlocal2     ",
"getlocal3     ",
"setlocal0     ",
"setlocal1     ",
"setlocal2     ",
"setlocal3     ",
"OP_0xD8       ",
"OP_0xD9       ",
"OP_0xDA       ",
"OP_0xDB       ",
"OP_0xDC       ",
"OP_0xDD       ",
"OP_0xDE       ",
"OP_0xDF       ",
"OP_0xE0       ",
"OP_0xE1       ",
"OP_0xE2       ",
"OP_0xE3       ",
"OP_0xE4       ",
"OP_0xE5       ",
"OP_0xE6       ",
"OP_0xE7       ",
"OP_0xE8       ",
"OP_0xE9       ",
"OP_0xEA       ",
"OP_0xEB       ",
"OP_0xEC       ",
"OP_0xED       ",
"OP_0xEE       ",
"debug         ",
"debugline     ",
"debugfile     ",
"bkptline      ",
"timestamp     ",
"OP_0xF4       ",
"OP_0xF5       ",
"OP_0xF6       ",
"OP_0xF7       ",
"OP_0xF8       ",
"OP_0xF9       ",
"OP_0xFA       ",
"OP_0xFB       ",
"OP_0xFC       ",
"OP_0xFD       ",
"OP_0xFE       ",
"OP_0xFF       "
]

import struct
import sys

def readUnsignedByte(f):
    return struct.unpack("<B", f.read(1))[0]

def readByte(f):
    return struct.unpack("<b", f.read(1))[0]

def readU32(f):
    result = readUnsignedByte(f)
    if not (result & 0x00000080):
        return result
    result = result & 0x0000007f | (readUnsignedByte(f)<< 7)
    if (not(result & 0x00004000)):
        return result
    result = result & 0x00003fff | (readUnsignedByte(f) << 14)
    if (not(result & 0x00200000)):
        return result
    result = result & 0x001fffff | (readUnsignedByte(f) << 21)
    if (not(result & 0x10000000)):
        return result
    return  result & 0x0fffffff | (readUnsignedByte(f) << 28)


def readS24(f):
    b = readUnsignedByte(f)
    b |= readUnsignedByte(f)<<8
    b |= readByte(f)<<16
    return b
def parseMethodBodies(f):
    m = "METHOD%i" % readU32(f)
    local_count = readU32(f)
    initScopeDepth = readU32(f)
    maxScopeDepth = readU32(f)
    code_length = readU32(f)
    if code_length > 0:
        data = f.read(code_length)
    ex_count = readU32(f)
    for _ in xrange(ex_count):
        from_ =  readU32(f)
        to = readU32(f)
        target = readU32(f)
        type_ = "NAME%" % readU32(f)
        name_ = "NAME%" % readU32(f)

f = open("extract", "rb")
while (1):
    try:
        op_byte = ord(f.read(1))
    except:
        break
    opcode = OPCODES[op_byte]
    print "%02X" % op_byte,
    print opcode,

    if op_byte in [OP_call, OP_construct, OP_constructsuper, OP_applytype]:
        print " (%i)" % readU32(f)

    elif op_byte in [OP_pushbyte, OP_getscopeobject]:
        print " %i" % readByte(f)

    elif op_byte in [OP_getsuper,
                        OP_setsuper,
                        OP_getproperty,
                        OP_initproperty,
                        OP_setproperty,
                        OP_getlex,
                        OP_findpropstrict,
                        OP_findproperty,
                        OP_finddef,
                        OP_deleteproperty,
                        OP_istype,
                        OP_coerce,
                        OP_astype,
                        OP_getdescendants]:
        print "Name%i" % readU32(f)

    elif op_byte in [OP_pushnamespace]:
        print "Namespace%i" % readU32(f)

    elif op_byte in [OP_constructprop,
                     OP_callproperty,
                     OP_callproplex,
                     OP_callsuper,
                     OP_callsupervoid,
                     OP_callpropvoid]:
        print "NAME%i (%i)" % (readU32(f), readU32(f))

    elif op_byte in [OP_callstatic]:
        print "METHOD%i (%i)" % (readU32(f), readU32(f))

    elif op_byte in [OP_inclocal,
                     OP_declocal,
                     OP_inclocal_i,
                     OP_declocal_i,
                     OP_getlocal,
                     OP_kill,
                     OP_setlocal,
                     OP_debugline,
                     OP_getglobalslot,
                     OP_getslot,
                     OP_setglobalslot,
                     OP_setslot,
                     OP_pushshort,
                     OP_newcatch]:
        print "%i" % readU32(f)

    elif op_byte in [
        OP_jump,
        OP_iftrue, OP_iffalse,
        OP_ifeq, OP_ifne,
        OP_ifge, OP_ifnge,
        OP_ifgt, OP_ifngt,
        OP_ifle, OP_ifnle,
        OP_iflt, OP_ifnlt,
        OP_ifstricteq, OP_ifstrictne]:
        offset = readS24(f)
        target = f.tell() + offset
        print "%i (%i)" % (target, offset)
        # TODO: MANAGE LABELS

    elif op_byte in [OP_debugfile, OP_pushstring]:
        print "escaped_string(%i)" % readU32(f)

    elif op_byte in [OP_pushint]:
        i = readU32(f)
        print "INTS%i // 0x%08X" % (i, i)

    elif op_byte in [OP_pushuint]:
        i = readU32(f)
        print "UINTS%i // 0x%08X" % (i, i)

    elif op_byte in [OP_pushdouble]:
        print "DOUBLE%i" % readU32(f)

    elif op_byte in [
        OP_getlocal0,
        OP_convert_b,
        OP_convert_d,
        OP_convert_i,
        OP_convert_s,
        OP_convert_u,
        OP_returnvoid,
        OP_nop,
        OP_dup,
        OP_add_i,
        OP_subtract,
        OP_greaterequals,
        OP_getglobalscope,
        OP_multiply_i,
        OP_divide,
        0, # 0 shouldn't be parsed ?
        OP_dxnslate,
        OP_esc_xattr,
        OP_add,
        OP_throw,
        OP_setlocal2,
        OP_bkpt,
        OP_pushtrue,
        OP_pushfalse,
        ]:
        print

    elif op_byte in [OP_newfunction]:
        print "METHODS%i" % readU32(f)

    elif op_byte in [OP_newobject]:
        print "{%i}" % readU32(f)

    elif op_byte in [OP_newarray]:
        print "[%i]" % readU32(f)

    elif op_byte in [OP_hasnext2]:
        print readU32(f), readU32(f)

    elif op_byte in [OP_newclass]:
        print "INSTANCE%i" % readU32(f)

    elif op_byte in [OP_debug]:
        print readUnsignedByte(f), readU32(f), readUnsignedByte(f), readU32(f)

    elif op_byte in [OP_lookupswitch]:
        pos = f.tell() - 1 # position
        target = pos + readS24(f)
        maxindex = readU32(f)
        #...

    else:
        print
        print "UNKNOWN"
        break

f.close()