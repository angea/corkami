#templates to generate PE structures via MakePE
Imports = """
DESCRIPTORS_START|
IMPORT_DESCRIPTOR: ; replace with imports:
|IMAGE_IMPORT_DESCRIPTOR|
%(dll)s_DESCRIPTOR:
    dd %(dll)s_hintnames - IMAGEBASE    ; OriginalFirstThunk/Characteristics, IMAGE_IMPORT_BY_NAME array
    dd 0                                ; TimeDateStamp
    dd -1                               ; ForwarderChain
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
