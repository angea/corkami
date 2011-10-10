# Tiny class generator

#122 bytes
#119 bytes with a one char filename
#115 bytes with a 'main' or 'Code' class name
#110 with a shorter super class: sun/misc/VM (thx Sami!)

#Ange Albertini, BSD licence 2011

import struct
import zipfile
from java import *

magic = "\xCA\xFE\xBA\xBE"
minor_version = 0
major_version = 46

filename = "main"

pool = ["",
    make_class(2),
    make_utf8("main"),
    make_utf8("sun/misc/VM"),
    make_class(3),
    make_utf8("Code"),
    make_utf8("([Ljava/lang/String;)V"),
#    make_utf8(filename),
    ]

access_flags = 1 # 1 = public
this_class   = 1
super_class  = 4

interfaces = []
fields = []

code = "".join([
    RETURN,
    ])

attribute_code = "".join([
struct.pack(">H", 5), # code
u4length("".join([
    struct.pack(">H", 0), # maxlocals
    struct.pack(">H", 1), # maxstack
    u4length(code), # code itself
    u2larray([]), # exceptions
    u2larray([]), # attributes
    ]),)
])

method_attributes = [
attribute_code,
]
main_method = "".join([
    struct.pack(">H", 1 + 8),       # flag: public, static
    struct.pack(">H", 2),           # name: main
    struct.pack(">H", 6),           # return type: ([Ljava/lang/String;)V
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

#print " ".join(["%02X" % ord(c) for c in fc])
with open(filename + '.class', "wb") as f:
    f.write(CLASS)

with zipfile.ZipFile(filename + '.jar', 'w') as myzip:
    myzip.write(filename + '.class')

print "done"
