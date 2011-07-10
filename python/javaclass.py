# simple java .class parser

import sys
import struct

#TODO: split flag in different arrays
access_flags = [
("ACC_PUBLIC", 0x0001        ),
("ACC_PRIVATE", 0x0002       ),
("ACC_PROTECTED", 0x0004     ),
("ACC_STATIC", 0x0008        ),
("ACC_FINAL", 0x0010         ),
("ACC_SYNCHRONIZED", 0x0020  ),
("ACC_BRIDGE", 0x0040        ),
("ACC_VARARGS", 0x0080       ),
("ACC_NATIVE", 0x0100        ),
("ACC_ABSTRACT", 0x0400      ),
("ACC_STRICT", 0x0800        ),
("ACC_SYNTHETIC", 0x1000     ),
("ACC_ANNOTATION", 0x2000    ),
("ACC_ENUM",      0x4000     ),
]
ACCESS_FLAGS = dict([(i[1], i[0]) for i in access_flags] + access_flags)

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
	print i + 1, 
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

import pprint
print "methods", #methods
pprint.pprint(methods)

attributes_count = struct.unpack(">H", f.read(2))[0]
attributes = get_attributes(f, attributes_count)
print "attributes", attributes
