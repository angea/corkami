; a ' compiled' hello world .DEX file
; SHA1: 8dc5490b921841136ba7d5c0adb537bb2104d3ef

;Ange Albertini 2013

%include 'dex.inc'

header:
istruc header_item
    at header_item.magic           , DEX_FILE_MAGIC
    at header_item.checksum        , dd 0x1d995f3b
    at header_item.signature       , db 0x21,0xfd,0x5e,0x3d,0x92,0x18,0x30,0x42,0xb3,0x70,0x4e,0xeb,0xc9,0x9d,0xa9,0xf7,0xa8,0x34,0xc4,0xeb
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
HEADER_SIZE equ $ - header
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

dd 2, 3, 4, 5, 6, 7 ,9

TYPE_IDS_SIZE equ ($ - type_ids) / 4
;*******************************************************************************
proto_ids:
istruc proto_id_item
    at proto_id_item.shorty_idx     , dd 7
    at proto_id_item.return_type_idx, dd 5
    at proto_id_item.parameters_off , dd 0
iend
istruc proto_id_item
    at proto_id_item.shorty_idx     , dd 8
    at proto_id_item.return_type_idx, dd 5
    at proto_id_item.parameters_off , dd param1
iend
istruc proto_id_item
    at proto_id_item.shorty_idx     , dd 8
    at proto_id_item.return_type_idx, dd 5
    at proto_id_item.parameters_off , dd param2
iend
PROTO_IDS_SIZE equ ($ - proto_ids) / proto_id_item_size
;*******************************************************************************

field_ids
istruc field_id_item
    at field_id_item.class_idx, dw 3
     at field_id_item.name_idx, dd 0xb
iend
FIELD_IDS_SIZE equ ($ - field_ids) / field_id_item_size

;*******************************************************************************

method_ids:
istruc method_id_item
    at method_id_item.class_idx, dw 0
    at method_id_item.proto_idx, dw 1
    at method_id_item.name_idx , dd 12
iend
istruc method_id_item
    at method_id_item.class_idx, dw 1
iend
istruc method_id_item
    at method_id_item.class_idx, dw 4
iend
istruc method_id_item
    at method_id_item.class_idx, dw 4
    at method_id_item.proto_idx, dw 2
    at method_id_item.name_idx , dd 10
iend

METHOD_IDS_SIZE equ ($ - method_ids) / method_id_item_size
;*******************************************************************************
class_defs:

istruc class_def_item
    at class_def_item.class_idx      , dd 4
    at class_def_item.access_flags   , dd 1
    at class_def_item.superclass_idx , dd 1
    at class_def_item.source_file_idx, dd 0dh
    at class_def_item.class_data_off , dd class_data
iend

CLASS_DEFS_SIZE equ ($ - class_defs) / class_def_item_size

;*******************************************************************************
data:

return_void    equ 0eh
const_string   equ 1ah
sget_object    equ 62h
invoke_virtual equ 6eh
invoke_direct  equ 70h

code_items:
istruc code_item
    at code_item.registers_size, dw 1
    at code_item.ins_size      , dw 1
    at code_item.outs_size     , dw 1
    at code_item.tries_size    , dw 0
    at code_item.debug_info_off, dd debug_info
    at code_item.insns_size    , dd INSNS1_SIZE
iend
insns1
dw invoke_direct | 1000h, 1, 0
dw return_void
INSNS1_SIZE equ ($ - insns1) / 2
align 4, db 0
; no tries, no handlers


istruc code_item
    at code_item.registers_size, dw 3
    at code_item.ins_size      , dw 1
    at code_item.outs_size     , dw 2
    at code_item.debug_info_off, dd debug_info1
    at code_item.insns_size    , dd INSNS2_SIZE
iend
insns2
dw sget_object, 0
dw const_string | 100h, 1
dw invoke_virtual | 2000h, 0, 10h
dw return_void
INSNS2_SIZE equ ($ - insns2) / 2

align 4, db 0
; no tries, no handlers

;*******************************************************************************
type_list:
param1:
dw 1, 0, 2, 0
param2:
dw 1, 0, 6

;*******************************************************************************
string_data:
ainit      __str '<init>'
aHW        __str 'Hello World!'
print      __str 'Ljava/io/PrintStream;'
obj        __str 'Ljava/lang/Object;'
string     __str 'Ljava/lang/String;'
sys        __str 'Ljava/lang/System;'
simp       __str 'Lsimple;'
V          __str 'V'
VL         __str 'VL'
ST_        __str '[Ljava/lang/String;'
main       __str 'main'
out_       __str 'out'
printl     __str 'println'
simplejava __str 'simple.java'

;*******************************************************************************
debug_info:
db 0x01, 0x00, 0x07, 0x0e, 0x00
debug_info1:
db 0x03, 0x01, 0x00, 0x07, 0x0e, 0x78, 0x00

;*******************************************************************************
class_data:

static_fields_size db 0
instance_fields_size db 0
direct_methods_size db 2
virtual_methods_size db 0

db 2 ; method_idx_diff
db 81h, 80h, 4h ; ACC_CONSTRUCTOR | ACC_PUBLIC, encoded in uleb128
db 0b0h, 02 ; 130h, uleb128 encoded

db 1 ; method_idx_diff
db 9 ; ACC_PUBLIC | ACC_STATIC
db 0xc8, 0x02 ; 148h, uleb128 encoded

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
        at map_item.size  , dd 0eh
        at map_item.offset, dd string_ids
iend
istruc map_item
        at map_item.type  , dw TYPE_TYPE_ID_ITEM
        at map_item.size  , dd 07
        at map_item.offset, dd type_ids
iend
istruc map_item
        at map_item.type  , dw TYPE_PROTO_ID_ITEM
        at map_item.size  , dd 3
        at map_item.offset, dd proto_ids
iend
istruc map_item
        at map_item.type  , dw TYPE_FIELD_ID_ITEM
        at map_item.size  , dd 1
        at map_item.offset, dd field_ids
iend
istruc map_item
        at map_item.type  , dw TYPE_METHOD_ID_ITEM
        at map_item.size  , dd 4
        at map_item.offset, dd method_ids
iend
istruc map_item
        at map_item.type  , dw TYPE_CLASS_DEF_ITEM
        at map_item.size  , dd 1
        at map_item.offset, dd class_defs
iend
istruc map_item
        at map_item.type  , dw TYPE_CODE_ITEM
        at map_item.size  , dd 2
        at map_item.offset, dd code_items
iend
istruc map_item
        at map_item.type  , dw TYPE_TYPE_LIST
        at map_item.size  , dd 2
        at map_item.offset, dd type_list
iend
istruc map_item
        at map_item.type  , dw TYPE_STRING_DATA_ITEM
        at map_item.size  , dd 0eh
        at map_item.offset, dd string_data
iend
istruc map_item
        at map_item.type  , dw TYPE_DEBUG_INFO_ITEM
        at map_item.size  , dd 2
        at map_item.offset, dd debug_info
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