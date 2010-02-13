#templates to generate PE structures via MakePE
Imports = """
DESCRIPTORS_START|
IMPORT_DESCRIPTOR: ; replace with imports:
|IMAGE_IMPORT_DESCRIPTOR|
%(dll)s_DESCRIPTOR:
    dd %(dll)s_hintnames - IMAGEBASE    ; OriginalFirstThunk/Characteristics, IMAGE_IMPORT_BY_NAME array
    dd 0                                ; TimeDateStamp
    dd 0                                ; ForwarderChain
    dd %(dll)s - IMAGEBASE              ; Name
    dd %(dll)s_iat - IMAGEBASE          ; FirstThunk


|Descriptor_end|
    times 5 dd 0

|HINT_NAME_start|
;align 2, db 0
%(dll)s_hintnames:

|HINT_NAME_thunk|
    DD a%(api)s - IMAGEBASE         ; ForwarderString / Function / Ordinal / AddressOfData

|IAT_start|
;align 2, db 0
%(dll)s_iat:

|IAT_thunk|
__imp__%(api)s:
    DD a%(api)s - IMAGEBASE         ; ForwarderString / Function / Ordinal / AddressOfData
|Thunk_end|
    DD 0

|DLL_NAME|
;align 2, db 0
%(dll)s  DB '%(dll)s',0

|IMAGE_IMPORT_BY_NAME|
;align 2, db 0
a%(api)s:
    dw 0            ; Hint
    db '%(api)s',0  ; Name

|IMPORTS_END|
DIRECTORY_ENTRY_IMPORT_SIZE EQU $ - IMPORT_DESCRIPTOR

""".lstrip().split("|")

Imports = dict([i, j.lstrip("\n")] for i, j in zip(Imports[::+2], Imports[1::+2]))

Relocations = """START#
;relocations start
Directory_Entry_Basereloc:
block_start:
; relocation block start
    .VirtualAddress dd reloc0 - IMAGEBASE
    .SizeOfBlock dd base_reloc_size_of_block
#ENTRY#
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc%(label)s + %(offset)s - reloc0)
#END#
    base_reloc_size_of_block equ $ - block_start
;relocation block end

;relocations end

DIRECTORY_ENTRY_BASERELOC_SIZE  equ $ - Directory_Entry_Basereloc
""".lstrip().split("#")

Relocations = dict([i, j.lstrip("\n")] for i, j in zip(Relocations[::+2], Relocations[1::+2]))


Exports = """BODY|
Exports_Directory:
  Characteristics       dd 0
  TimeDateStamp         dd 0
  MajorVersion          dw 0
  MinorVersion          dw 0
  Name                  dd aDllName - IMAGEBASE
  Base                  dd 0
  NumberOfFunctions     dd %(counter)i
  NumberOfNames         dd %(counter)i
  AddressOfFunctions    dd address_of_functions - IMAGEBASE
  AddressOfNames        dd address_of_names - IMAGEBASE
  AddressOfNameOrdinals dd address_of_name_ordinals - IMAGEBASE

aDllName db '%(dll_name)s', 0

address_of_functions:
%(functions)s
address_of_names:
%(names)s
address_of_name_ordinals:
%(ordinals)s
%(strings)s

EXPORT_SIZE equ $ - Exports_Directory
|ORDINAL|
    dw 0
|FUNCTION|
    dd __exp__%(export)s - IMAGEBASE
|NAME|
    dd a__exp__%(export)s - IMAGEBASE
|STRING|
a__exp__%(export)s db '%(export)s', 0
""".lstrip().split("|")

Exports = dict([i, j.lstrip("\n")] for i, j in zip(Exports[::+2], Exports[1::+2]))
