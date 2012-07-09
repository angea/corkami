# Hello World Java/JavaScript class/html generator ;)

# Ange Albertini, BSD licence 2012
import struct
import zipfile
from java import *

filename = "HWJava_Script"

magic = "\xCA\xFE\xBA\xBE"
minor_version = 0
major_version = 46

pool = ["",
    # HTML code taken from lcamtuf's JPEG/HTML example @ http://lcamtuf.coredump.cx/squirrel/
    make_utf8("<html><body><style>body { visibility:hidden;} .n { visibility: visible; position: absolute; padding: 0 1ex 0 1ex; margin: 0; top: 0; left: 0; } h1 { margin-top: 0.4ex; margin-bottom: 0.8ex; }</style><div class=n><script type='text/javascript'>alert('Hello World! [JavaScript]');</script><!--"), # </body></html> not required
    
    make_class(23),
    make_utf8("java/lang/Object"),
    make_class(3),
    make_utf8("main"),
    make_utf8("V"),
    make_utf8("Code"),
    make_utf8("(Ljava/lang/String;)V"),
    make_utf8("([Ljava/lang/String;)V"),
    make_utf8("out"),
    make_utf8("Ljava/io/PrintStream;"),
    make_nat(10, 11),
    make_utf8("java/lang/System"),
    make_class(13),
    make_fieldref(14, 12),
    make_utf8("Hello World! [Java]"),
    make_string(16),
    make_utf8("println"),
    make_nat(18, 8),
    make_utf8("java/io/PrintStream"),
    make_class(20),
    make_methodref(21, 19),
    make_utf8(filename),
    ]

access_flags = 1 # 1 = public
this_class   = 2
super_class  = 4

interfaces = []
fields = []

code = "".join([
    GETSTATIC, struct.pack(">H", 15),
    LDC, struct.pack(">B", 17),             # ldc String 18
    INVOKEVIRTUAL, struct.pack(">H", 22),
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
struct.pack(">H", 23), # exceptions
u4length(
    u2larray([]) # exceptions
    ),
])

method_attributes = [
attribute_code,
#attribute_exceptions,
]
main_method = "".join([struct.pack(">H", 9),                 # flag: public, static
    struct.pack(">H", 5),   # name: main
    struct.pack(">H", 9),  # return type: ([Ljava/lang/String;)V
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

with open(filename + '.class', "wb") as f:
    f.write(CLASS)
with open(filename + '.html', "wb") as f:
    f.write(CLASS)
