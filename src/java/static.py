# static <clinit> class generator
# <clinit> got executed before Exception is triggered because no main is present

# Ange Albertini, BSD licence 2011

import struct
import zipfile
from java import *

magic = "\xCA\xFE\xBA\xBE"
minor_version = 0
major_version = 46

filename = "Code"

pool = [
    "",                       # 0
    make_class(4),            # 1
    make_utf8("sun/misc/VM"), # 2
    make_class(2),            # 3
    make_utf8("Code"),        # 4
    make_utf8("()V"),         # 5
    make_utf8("<clinit>"),    # 6
    ]

access_flags = 1 # 1 = public
this_class   = 1
super_class  = 3

interfaces = []
fields = []

code = "".join([
    RETURN,
    ])

attribute_code = "".join([
struct.pack(">H", 4), # code
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
    struct.pack(">H", 7),       # flag: public, static
    struct.pack(">H", 6),       # name: <clinit>
    struct.pack(">H", 5),       # return type: ()V
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
