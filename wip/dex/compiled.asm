; a 'compiled' hello world .DEX file

;Ange Albertini 2013

%include 'dex.inc'

header:
istruc header_item
    at header_item.magic           , DEX_FILE_MAGIC
    at header_item.file_size       , dd FILE_SIZE
    at header_item.header_size     , dd HEADER_SIZE
    at header_item.endian_tag      , dd ENDIAN_CONSTANT

    at header_item.map_off         , dd map
    at header_item.strings_ids_size, dd STRING_IDS_SIZE
    at header_item.strings_ids_off , dd string_ids
    at header_item.type_ids_size   , dd TYPE_IDS_SIZE
    at header_item.type_ids_off    , dd type_ids
    at header_item.proto_ids_size  , dd PROTO_IDS_SIZE
    at header_item.proto_ids_off   , dd proto_ids
    at header_item.field_ids_size  , dd FIELD_IDS_SIZE
    at header_item.field_ids_off   , dd field_ids
    at header_item.method_ids_size , dd METHOD_IDS_SIZE
    at header_item.method_ids_off  , dd method_ids
    at header_item.class_defs_size , dd CLASS_DEFS_SIZE
    at header_item.class_defs_off  , dd class_defs
    at header_item.data_size       , dd DATA_SIZE
    at header_item.data_off        , dd data
iend
HEADER_SIZE equ ($ - header) ; not a count


;*******************************************************************************
; string_ids

string_ids
    dd ainit
    dd aHW
    dd print
    dd obj
    dd string
    dd sys
    dd simp
    dd V
    dd VL
    dd ST_
    dd main
    dd out_
    dd printl
    dd simplejava
STRING_IDS_SIZE equ ($ - string_ids) / 4


;*******************************************************************************
type_ids:
PrintStreamTID  equ 0
    dd PrintStreamSID

LangObjectTID   equ 1
    dd LangObjectSID

LangStringTID   equ 2
    dd LangStringSID

LangSystemTID   equ 3
    dd LangSystemSID

simpleTID       equ 4
    dd simpleSID

VoidTID         equ 5
    dd VoidSID

StringArrayTID  equ 6
    dd StringArraySID
TYPE_IDS_SIZE equ ($ - type_ids) / 4


;*******************************************************************************

proto_ids:
voidvoidProto       equ 0
istruc proto_id_item
    at proto_id_item.shorty_idx     , dd VoidSID
    at proto_id_item.return_type_idx, dd VoidTID
iend
LangStringvoidProto equ 1
istruc proto_id_item
    at proto_id_item.shorty_idx     , dd VLSID
    at proto_id_item.return_type_idx, dd VoidTID
    at proto_id_item.parameters_off , dd LangStringParam
iend
LangStringAvoidProt equ 2
istruc proto_id_item
    at proto_id_item.shorty_idx     , dd VLSID
    at proto_id_item.return_type_idx, dd VoidTID
    at proto_id_item.parameters_off , dd LangStringArrayParam
iend
PROTO_IDS_SIZE equ ($ - proto_ids) / proto_id_item_size


;*******************************************************************************

field_ids
istruc field_id_item
    at field_id_item.class_idx, dw LangSystemTID
    at field_id_item.name_idx,  dd outSID
iend
FIELD_IDS_SIZE equ ($ - field_ids) / field_id_item_size


;*******************************************************************************

method_ids:
istruc method_id_item
    at method_id_item.class_idx, dw PrintStreamTID
    at method_id_item.proto_idx, dw LangStringvoidProto
    at method_id_item.name_idx , dd printlnSID
iend
istruc method_id_item
    at method_id_item.class_idx, dw LangObjectTID
iend
istruc method_id_item
    at method_id_item.class_idx, dw simpleTID
iend
istruc method_id_item
    at method_id_item.class_idx, dw simpleTID
    at method_id_item.proto_idx, dw LangStringAvoidProt
    at method_id_item.name_idx , dd mainSID
iend

METHOD_IDS_SIZE equ ($ - method_ids) / method_id_item_size


;*******************************************************************************
class_defs:

istruc class_def_item
    at class_def_item.class_idx      , dd simpleTID
    at class_def_item.access_flags   , dd ACC_PUBLIC
    at class_def_item.superclass_idx , dd LangObjectTID
    at class_def_item.source_file_idx, dd simple_javaSID
    at class_def_item.class_data_off , dd class_data
iend

CLASS_DEFS_SIZE equ ($ - class_defs) / class_def_item_size


;*******************************************************************************
data:

OP_return_void    equ 0eh
OP_const_string   equ 1ah
OP_sget_object    equ 62h
OP_invoke_virtual equ 6eh
OP_invoke_direct  equ 70h

code_items:
istruc code_item
    at code_item.registers_size, dw 1
    at code_item.ins_size      , dw 1
    at code_item.outs_size     , dw 1
    at code_item.tries_size    , dw 0
    at code_item.insns_size    , dd INSNS1_SIZE
iend
insns1
    dw OP_invoke_direct | 1000h, 1, 0
    dw OP_return_void
INSNS1_SIZE equ ($ - insns1) / 2
align 4, db 0
; no tries, no handlers

istruc code_item
    at code_item.registers_size, dw 3
    at code_item.ins_size      , dw 1
    at code_item.outs_size     , dw 2
    at code_item.insns_size    , dd INSNS2_SIZE
iend
insns2
    dw OP_sget_object, 0
    dw OP_const_string | 100h, 1
    dw OP_invoke_virtual | 2000h, 0, 10h
    dw OP_return_void
INSNS2_SIZE equ ($ - insns2) / 2
align 4, db 0
; no tries, no handlers

CODE_ITEMS_SIZE equ 2

;*******************************************************************************

type_list:

align 4, db 0
LangStringParam:
istruc type_list_
 at type_list_.size, dd 1 ; one element
iend
    dw LangStringTID

align 4, db 0
LangStringArrayParam:
istruc type_list_
 at type_list_.size, dd 1 ; one element
iend
    dw StringArrayTID

TYPE_LIST_SIZE equ 2

;*******************************************************************************

string_data:
initSID equ 0
ainit      __str '<init>'

msgSID equ 1
aHW        __str 'Hello World!'

PrintStreamSID equ 2
print      __str 'Ljava/io/PrintStream;'


LangObjectSID equ 3
obj        __str 'Ljava/lang/Object;'

LangStringSID equ 4
string     __str 'Ljava/lang/String;'

LangSystemSID equ 5
sys        __str 'Ljava/lang/System;'

simpleSID equ 6
simp       __str 'Lsimple;'

VoidSID equ 7
V          __str 'V'

VLSID equ 8
VL         __str 'VL'

StringArraySID equ 9
ST_        __str '[Ljava/lang/String;'

mainSID equ 10
main       __str 'main'

outSID equ 11
out_       __str 'out'

printlnSID equ 12
printl     __str 'println'

simple_javaSID equ 13
simplejava __str 'simple.java'

STRING_DATA_SIZE equ 0eh

;*******************************************************************************

class_data:

static_fields_size db 0
instance_fields_size db 0
direct_methods_size db 2
virtual_methods_size db 0

db 2 ; method_idx_diff (uleb128)
db 81h, 80h, 4h ; ACC_CONSTRUCTOR | ACC_PUBLIC (uleb128)
db 0b0h, 02 ; code offset 130h (uleb128)

db 1 ; method_idx_diff
db ACC_PUBLIC | ACC_STATIC ; (uleb128)
db 0xc8, 0x02 ; code offset 148h (uleb128)

;*******************************************************************************

map:

map_list_:
istruc map_list
    at map_list.size, dd MAP_SIZE
iend

map_elements:
istruc map_item
        at map_item.type  , dw TYPE_HEADER_ITEM
        at map_item.size  , dd 1
        at map_item.offset, dd header
iend
istruc map_item
        at map_item.type  , dw TYPE_STRING_ID_ITEM
        at map_item.size  , dd STRING_IDS_SIZE
        at map_item.offset, dd string_ids
iend
istruc map_item
        at map_item.type  , dw TYPE_TYPE_ID_ITEM
        at map_item.size  , dd TYPE_IDS_SIZE
        at map_item.offset, dd type_ids
iend
istruc map_item
        at map_item.type  , dw TYPE_PROTO_ID_ITEM
        at map_item.size  , dd PROTO_IDS_SIZE
        at map_item.offset, dd proto_ids
iend
istruc map_item
        at map_item.type  , dw TYPE_FIELD_ID_ITEM
        at map_item.size  , dd FIELD_IDS_SIZE
        at map_item.offset, dd field_ids
iend
istruc map_item
        at map_item.type  , dw TYPE_METHOD_ID_ITEM
        at map_item.size  , dd METHOD_IDS_SIZE
        at map_item.offset, dd method_ids
iend
istruc map_item
        at map_item.type  , dw TYPE_CLASS_DEF_ITEM
        at map_item.size  , dd CLASS_DEFS_SIZE
        at map_item.offset, dd class_defs
iend
istruc map_item
        at map_item.type  , dw TYPE_CODE_ITEM
        at map_item.size  , dd CODE_ITEMS_SIZE
        at map_item.offset, dd code_items
iend
istruc map_item
        at map_item.type  , dw TYPE_TYPE_LIST
        at map_item.size  , dd TYPE_LIST_SIZE
        at map_item.offset, dd type_list
iend
istruc map_item
        at map_item.type  , dw TYPE_STRING_DATA_ITEM
        at map_item.size  , dd STRING_DATA_SIZE
        at map_item.offset, dd string_data
iend
istruc map_item
        at map_item.type  , dw TYPE_CLASS_DATA_ITEM
        at map_item.size  , dd 1
        at map_item.offset, dd class_data
iend
istruc map_item
        at map_item.type  , dw TYPE_MAP_LIST
        at map_item.size  , dd 1
        at map_item.offset, dd map_list_
iend
MAP_SIZE equ ($ - map_elements) / map_item_size

DATA_SIZE equ $ - data

FILE_SIZE equ $ - header