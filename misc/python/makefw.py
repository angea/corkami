# a simple script that will generate a forwarding DLL assembler listing
# for example, to create a forwarder for an ollydbg plugin to an immunity debugger plugin

# 1. edit DLLNAME and forwarders
# 2. run makefw.py <myfile.asm>
# 3. compile with yasm 'yasm -o <myfile.exe> <myfile.asm>"

DLLNAME = "multiasm"

forwarders = {
"IMMDBG_Pluginaction"  : "_ODBG_Pluginaction"  ,
"IMMDBG_Pluginclose"   : "_ODBG_Pluginclose"   ,
"IMMDBG_Plugindata"    : "_ODBG_Plugindata"    ,
"IMMDBG_Plugindestroy" : "_ODBG_Plugindestroy" ,
"IMMDBG_Plugininit"    : "_ODBG_Plugininit"    ,
"IMMDBG_Pluginmenu"    : "_ODBG_Pluginmenu"    ,
"IMMDBG_Pluginshortcut": "_ODBG_Pluginshortcut",
}

###############################################################################
import sys

TEMPLATE = """
%%include 'consts.inc'

IMAGEBASE equ 1000000h
org IMAGEBASE
bits 32

SECTIONALIGN equ 1000h
FILEALIGN equ 200h

istruc IMAGE_DOS_HEADER
    at IMAGE_DOS_HEADER.e_magic, db 'MZ'
    at IMAGE_DOS_HEADER.e_lfanew, dd NT_Signature - IMAGEBASE
iend

NT_Signature:
istruc IMAGE_NT_HEADERS
    at IMAGE_NT_HEADERS.Signature, db 'PE', 0, 0
iend
istruc IMAGE_FILE_HEADER
    at IMAGE_FILE_HEADER.Machine,               dw IMAGE_FILE_MACHINE_I386
    at IMAGE_FILE_HEADER.NumberOfSections,      dw NUMBEROFSECTIONS
    at IMAGE_FILE_HEADER.SizeOfOptionalHeader,  dw SIZEOFOPTIONALHEADER
    at IMAGE_FILE_HEADER.Characteristics,       dw IMAGE_FILE_EXECUTABLE_IMAGE | IMAGE_FILE_32BIT_MACHINE | IMAGE_FILE_DLL
iend

OptionalHeader:
istruc IMAGE_OPTIONAL_HEADER32
    at IMAGE_OPTIONAL_HEADER32.Magic,                     dw IMAGE_NT_OPTIONAL_HDR32_MAGIC
    at IMAGE_OPTIONAL_HEADER32.AddressOfEntryPoint,       dd EntryPoint - IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.ImageBase,                 dd IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.SectionAlignment,          dd SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER32.FileAlignment,             dd FILEALIGN
    at IMAGE_OPTIONAL_HEADER32.MajorSubsystemVersion,     dw 4
    at IMAGE_OPTIONAL_HEADER32.SizeOfImage,               dd 2 * SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER32.SizeOfHeaders,             dd SIZEOFHEADERS
    at IMAGE_OPTIONAL_HEADER32.Subsystem,                 dw IMAGE_SUBSYSTEM_WINDOWS_CUI
    at IMAGE_OPTIONAL_HEADER32.NumberOfRvaAndSizes,       dd 16
iend

DataDirectory:
istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ExportsVA,  dd Exports_Directory - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.ExportsSize,  dd EXPORTS_SIZE    ; exports size is *REQUIRED* in this case
iend

SIZEOFOPTIONALHEADER equ $ - OptionalHeader
SectionHeader:
istruc IMAGE_SECTION_HEADER
    at IMAGE_SECTION_HEADER.VirtualSize,      dd 1 * SECTIONALIGN
    at IMAGE_SECTION_HEADER.VirtualAddress,   dd 1 * SECTIONALIGN
    at IMAGE_SECTION_HEADER.SizeOfRawData,    dd 1 * FILEALIGN
    at IMAGE_SECTION_HEADER.PointerToRawData, dd 1 * FILEALIGN
    at IMAGE_SECTION_HEADER.Characteristics,  dd IMAGE_SCN_MEM_EXECUTE | IMAGE_SCN_MEM_WRITE
iend
NUMBEROFSECTIONS equ ($ - SectionHeader) / IMAGE_SECTION_HEADER_size

SIZEOFHEADERS equ $ - IMAGEBASE

section progbits vstart=IMAGEBASE + SECTIONALIGN align=FILEALIGN

EntryPoint:
    push 1
    pop eax
    retn 3 * 4
_c

Exports_Directory:
  Characteristics       dd 0
  TimeDateStamp         dd 0
  MajorVersion          dw 0
  MinorVersion          dw 0
  Name                  dd 0
  Base                  dd 0
  NumberOfFunctions     dd NUMBER_OF_FUNCTIONS
  NumberOfNames         dd NUMBER_OF_NAMES
  AddressOfFunctions    dd address_of_functions - IMAGEBASE
  AddressOfNames        dd address_of_names - IMAGEBASE
  AddressOfNameOrdinals dd address_of_name_ordinals - IMAGEBASE
_d

address_of_functions:
%(ADDRESS_OF_FUNCTIONS)s
NUMBER_OF_FUNCTIONS equ ($ - address_of_functions) / 4
_d

address_of_names:
%(ADDRESS_OF_NAMES)s
NUMBER_OF_NAMES equ ($ - address_of_names) / 4
_d

%(FORWARDER_NAMES)s

%(FORWARDED_EXPORTS)s
_d

address_of_name_ordinals:
    dw %(ORDINALS)s
_d

a__exp__Export db 'ExitProcess', 0
_d

EXPORTS_SIZE equ $ - Exports_Directory

align FILEALIGN, db 0
"""

###############################################################################

ORDINALS = []
FORWARDER_NAMES = []
ADDRESS_OF_FUNCTIONS = []
FORWARDED_EXPORTS = []
ADDRESS_OF_NAMES = []

for i, forwarder in enumerate(forwarders):
        ORDINALS.append("%i" % i)
        forwarded = forwarders[forwarder]

        FORWARDER_NAMES.append("""%(forwarded)s db "%(DLLNAME)s.%(forwarded)s", 0""" % locals())
        FORWARDED_EXPORTS.append("""%(forwarder)s db "%(forwarder)s", 0""" % locals())

        ADDRESS_OF_FUNCTIONS.append("""    dd %(forwarded)s - IMAGEBASE""" % locals())
        ADDRESS_OF_NAMES.append("""    dd %(forwarder)s - IMAGEBASE""" % locals())

FORWARDER_NAMES = "\r\n".join(FORWARDER_NAMES)
ADDRESS_OF_FUNCTIONS = "\r\n".join(ADDRESS_OF_FUNCTIONS)
ADDRESS_OF_NAMES = "\r\n".join(ADDRESS_OF_NAMES)
FORWARDED_EXPORTS = "\r\n".join(FORWARDED_EXPORTS)
ORDINALS = ", ".join(ORDINALS)

with open(sys.argv[1], "wt") as f:
        f.write(TEMPLATE % locals())
