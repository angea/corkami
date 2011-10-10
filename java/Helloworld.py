# Hello World class generator

#Ange Albertini, BSD licence 2011

import struct
import zipfile
from java import *

filename = "HelloWorld"

magic = "\xCA\xFE\xBA\xBE"
minor_version = 0
major_version = 46

pool = ["",
    make_utf8(filename),
    make_class(1),
    make_utf8("java/lang/Object"),
    make_class(3),
    make_utf8("main"),
    make_utf8("V"),
    make_utf8("Code"),
    make_utf8("Exceptions"),
    make_utf8("(Ljava/lang/String;)V"),
    make_utf8("([Ljava/lang/String;)V"),
    make_utf8("out"),
    make_utf8("Ljava/io/PrintStream;"),
    make_nat(11, 12),
    make_utf8("java/lang/System"),
    make_class(14),
    make_fieldref(15, 13),
    make_utf8("Hello World !"),
    make_string(17),
    make_utf8("println"),
    make_nat(19, 9),
    make_utf8("java/io/PrintStream"),
    make_class(21),
    make_methodref(22, 20),
    ]

access_flags = 1 # 1 = public
this_class   = 2
super_class  = 4

interfaces = []
fields = []

code = "".join([
    GETSTATIC, struct.pack(">H", 16),
    LDC, struct.pack(">B", 18),             # ldc String 18
    INVOKEVIRTUAL, struct.pack(">H", 23),
    RETURN,
    ])

attribute_code = "".join([
struct.pack(">H", 7), # code
u4length("".join([
    struct.pack(">H", 2), # maxlocals
    struct.pack(">H", 1), # maxstack
    u4length(code), # code itself
    u2larray([]), # exceptions
    u2larray([]), # attributes
    ]),)
])

attribute_exceptions = "".join([
struct.pack(">H", 8), # exceptions
u4length(
    u2larray([]) # exceptions
    ),
])

method_attributes = [
attribute_code,
attribute_exceptions,
]
main_method = "".join([struct.pack(">H", 9),                 # flag: public, static
    struct.pack(">H", 5),   # name: main
    struct.pack(">H", 10),  # return type: ([Ljava/lang/String;)V
    u2larray(method_attributes),
    ])

methods = [
    main_method,
    ]

attributes = []

CLASS = make_classfile(
    magic,
    minor_version,
    major_version,
    pool,
    access_flags,
    this_class,
    super_class,
    interfaces,
    fields,
    methods,
    attributes
    )

fn = "Hello"

#print " ".join(["%02X" % ord(c) for c in fc])
with open(filename + '.class', "wb") as f:
    f.write(CLASS)

with zipfile.ZipFile(filename + '.jar', 'w') as myzip:
    myzip.write(filename + '.class')

print "done"
