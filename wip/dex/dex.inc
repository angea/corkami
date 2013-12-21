%macro DEX_FILE_MAGIC 0
db "dex", 0ah, "035", 0
%endmacro

ENDIAN_CONSTANT equ 012345678h
REVERSE_ENDIAN_CONSTANT equ 078563412h

NO_INDEX equ 0ffffffffh

ACC_PUBLIC                equ     0x1
ACC_PRIVATE               equ     0x2
ACC_PROTECTED             equ     0x4
ACC_STATIC                equ     0x8
ACC_FINAL                 equ    0x10
ACC_SYNCHRONIZED          equ    0x20
ACC_VOLATILE              equ    0x40
ACC_BRIDGE                equ    0x40
ACC_TRANSIENT             equ    0x80
ACC_VARARGS               equ    0x80
ACC_NATIVE                equ   0x100
ACC_INTERFACE             equ   0x200
ACC_ABSTRACT              equ   0x400
ACC_STRICT                equ   0x800
ACC_SYNTHETIC             equ  0x1000
ACC_ANNOTATION            equ  0x2000
ACC_ENUM                  equ  0x4000
;unused                   equ  0x8000
ACC_CONSTRUCTOR           equ 0x10000
ACC_DECLARED_SYNCHRONIZED equ 0x20000

VALUE_BYTE       equ 0x00
VALUE_SHORT      equ 0x02
VALUE_CHAR       equ 0x03
VALUE_INT        equ 0x04
VALUE_LONG       equ 0x06
VALUE_FLOAT      equ 0x10
VALUE_DOUBLE     equ 0x11
VALUE_STRING     equ 0x17
VALUE_TYPE       equ 0x18
VALUE_FIELD      equ 0x19
VALUE_METHOD     equ 0x1a
VALUE_ENUM       equ 0x1b
VALUE_ARRAY      equ 0x1c
VALUE_ANNOTATION equ 0x1d
VALUE_NULL       equ 0x1e
VALUE_BOOLEAN    equ 0x1f

TYPE_HEADER_ITEM                equ 0x0000
TYPE_STRING_ID_ITEM             equ 0x0001
TYPE_TYPE_ID_ITEM               equ 0x0002
TYPE_PROTO_ID_ITEM              equ 0x0003
TYPE_FIELD_ID_ITEM              equ 0x0004
TYPE_METHOD_ID_ITEM             equ 0x0005
TYPE_CLASS_DEF_ITEM             equ 0x0006
TYPE_MAP_LIST                   equ 0x1000
TYPE_TYPE_LIST                  equ 0x1001
TYPE_ANNOTATION_SET_REF_LIST    equ 0x1002
TYPE_ANNOTATION_SET_ITEM        equ 0x1003
TYPE_CLASS_DATA_ITEM            equ 0x2000
TYPE_CODE_ITEM                  equ 0x2001
TYPE_STRING_DATA_ITEM           equ 0x2002
TYPE_DEBUG_INFO_ITEM            equ 0x2003
TYPE_ANNOTATION_ITEM            equ 0x2004
TYPE_ENCODED_ARRAY_ITEM         equ 0x2005
TYPE_ANNOTATIONS_DIRECTORY_ITEM equ 0x2006

struc header_item
    .magic            resb 8
    .checksum         resd 1
    .signature        resd 5
    .file_size        resd 1
    .header_size      resd 1
    .endian_tag       resd 1
    .link_size        resd 1
    .link_off         resd 1
    .map_off          resd 1
    .strings_ids_size resd 1
    .strings_ids_off  resd 1
    .type_ids_size    resd 1
    .type_ids_off     resd 1
    .proto_ids_size   resd 1
    .proto_ids_off    resd 1
    .field_ids_size   resd 1
    .field_ids_off    resd 1
    .method_ids_size  resd 1
    .method_ids_off   resd 1
    .class_defs_size  resd 1
    .class_defs_off   resd 1
    .data_size        resd 1
    .data_off         resd 1
endstruc

struc proto_id_item
    .shorty_idx      resd 1
    .return_type_idx resd 1
    .parameters_off  resd 1
endstruc

%macro __str 1
db %%end - 2 -$
    db %1 ; this is actually an uleb128, so it won't work if string is longer than 0x7f
    db 0
%%end:
%endmacro

struc field_id_item
    .class_idx resw 1
     .type_idx resw 1
     .name_idx resd 1
endstruc

struc method_id_item
    .class_idx resw 1
    .proto_idx resw 1
     .name_idx resd 1
endstruc

struc class_def_item
    .class_idx         resd 1
    .access_flags      resd 1
    .superclass_idx    resd 1
    .interfaces_off    resd 1
    .source_file_idx   resd 1
    .annotations_off   resd 1
    .class_data_off    resd 1
    .static_values_off resd 1
endstruc

struc map_list
    .size resd 1
endstruc

struc map_item
    .type   resw 1
    .unused resw 1
    .size   resd 1
    .offset resd 1
endstruc

struc code_item
    .registers_size resw 1
    .ins_size       resw 1
    .outs_size      resw 1
    .tries_size     resw 1
    .debug_info_off resd 1
    .insns_size     resd 1
endstruc
;followed by:
;insns ; dw[insns_size]
;align 4, db 0
;try_item[tries_size]

struc type_list_
    .size resd 1
    .list resw 0 ; list = words[size]
endstruc