# simple class generator helper

#Ange Albertini, BSD licence 2011
import struct

def make_utf8(s):
    return "".join(["\x01", struct.pack(">H", len(s)), s])

def make_class(i):
    return "".join(["\x07", struct.pack(">H", i)])

def make_nat(name, type):
    return "".join(["\x0C", struct.pack(">H", name), struct.pack(">H", type)])

def make_fieldref(field, ref):
    return "".join(["\x09", struct.pack(">H", field), struct.pack(">H", ref)])

def make_methodref(method, ref):
    return "".join(["\x0A", struct.pack(">H", method), struct.pack(">H", ref)])

def make_string(utf):
    return "".join(["\x08", struct.pack(">H", utf)])

def u4length(s):
    return "".join([struct.pack(">L", len(s)), s])

def u2larray(l):
    return "".join([struct.pack(">H", len(l)), "".join(l)])


GETSTATIC = "\xb2"
LDC = "\x12"
INVOKEVIRTUAL = "\xb6"
RETURN = "\xb1"

def make_classfile(
    magic, minor_version, major_version, pool, access_flags, this_class, super_class, interfaces,
    fields, methods, attributes):
        return "".join([
            magic,
            struct.pack(">H", minor_version),
            struct.pack(">H", major_version),
            u2larray(pool),
            struct.pack(">H", access_flags),
            struct.pack(">H", this_class),
            struct.pack(">H", super_class),
            u2larray(interfaces),
            u2larray(fields),
            u2larray(methods),
            u2larray(attributes)
            ])

