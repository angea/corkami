import sys, struct

TAGS_E = {
	1:"CONSTANT_Utf8",
	3:"CONSTANT_Integer",
	4:"CONSTANT_Float",
	5:"CONSTANT_Long",
	6:"CONSTANT_Double",
	7:"CONSTANT_Class",
	8:"CONSTANT_String",
	9:"CONSTANT_Fieldref",
	10:"CONSTANT_Methodref",
	11:"CONSTANT_InterfaceMethodref",
	12:"CONSTANT_NameAndType",
	}

def parse_utf8(f):
	length = struct.unpack(">H", f.read(2))[0]
	bytes = f.read(length)
	return length, bytes

def parse_class(f):
	name_index = struct.unpack(">H", f.read(2))[0]
	return name_index

def parse_string(f):
	string_index = struct.unpack(">H", f.read(2))[0]
	return string_index

def parse_fldmethintmeth(f):
	class_index, name_and_type_index = struct.unpack(">2H", f.read(2 * 2))
	return class_index, name_and_type_index

def parse_nameandtype(f):
	name_index, descriptor_index = struct.unpack(">2H", f.read(2 * 2))
	return name_index, descriptor_index

def parse_intfloat(f):
	bytes = struct.unpack(">L", f.read(4))[0]
	return bytes
	
def parse_longdouble(f):
	high_bytes, low_bytes = struct.unpack(">2L", f.read(2 * 4))
	return bytes
	
def parse_constant(f):
		parsers = [
			None, 
			parse_utf8, 
			None,
			parse_intfloat, parse_intfloat, 
			parse_longdouble, parse_longdouble, 
			parse_class, 
			parse_string,
			parse_fldmethintmeth, parse_fldmethintmeth, parse_fldmethintmeth,
			parse_nameandtype]

		tag = struct.unpack(">B", f.read(1))[0]
			
		info = parsers[tag](f)
		return tag, info

		
ACCESS_FLAGS_E = {
	0x0001: "ACC_PUBLIC", 
	0x0010:"ACC_FINAL",
	0x0020:"ACC_SUPER", 
	0x0200:"ACC_INTERFACE",
	0x0400:"ACC_ABSTRACT", 
	0x1000:"ACC_SYNTHETIC", 
	0x2000:"ACC_ANNOTATION",
	0x4000:"ACC_ENUM",
	}

f = open(sys.argv[1], "rb")
magic, minor_version, major_version, constant_pool_count = struct.unpack(">LHHH", f.read(4 + 2 + 2 + 2))

constant_pool = []
i = 1
while i < constant_pool_count:
	print i, parse_constant(f)
	i += 1
	
access_flags, this_class, super_class = struct.unpack(">3H", f.read(3 * 2))

interfaces_count = struct.unpack(">H", f.read(2))[0]
i = 1
while i < interfaces_count:
	i += 1

fields_count = struct.unpack(">H", f.read(2))[0]

i = 1
while i < fields_count:
	i += 1

methods_count = struct.unpack(">H", f.read(2))[0]
i = 1
while i < methods_count:
	i += 1

attributes_count = struct.unpack(">H", f.read(2))[0]
i = 1
while i < attributes_count:
	i += 1

print "Signature: %08X" % magic
print "version %i.%i" % (major_version, minor_version)
print "constant pool count: ", constant_pool_count

l = []
for t in ACCESS_FLAGS_E:
	if (access_flags & t):
		l.append(ACCESS_FLAGS_E[t])
print "0x%04X = %s" % (access_flags, " | ".join(l))

print this_class, super_class
