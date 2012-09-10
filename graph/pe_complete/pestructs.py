###############################################################################

IMAGE_DATA_DIRECTORY = ('IMAGE_DATA_DIRECTORY', (
	'4,VirtualAddress', 
	'4,Size'))

IMAGE_DELAY_IMPORT_DESCRIPTOR = ('IMAGE_DELAY_IMPORT_DESCRIPTOR',(
	'4,grAttrs', 
	'4,szName', 
	'4,phmod', 
	'4,pIAT', 
	'4,pINT',
	'4,pBoundIAT',
	'4,pUnloadIAT',
	'4,dwTimeStamp'))

IMAGE_IMPORT_DESCRIPTOR =  ('IMAGE_IMPORT_DESCRIPTOR', (
	'4,OriginalFirstThunk,Characteristics',
	'4,TimeDateStamp', 
	'4,ForwarderChain', 
	'4,Name', 
	'4,FirstThunk'))

IMAGE_EXPORT_DIRECTORY =  ('IMAGE_EXPORT_DIRECTORY', (
	'4,Characteristics', 
	'4,TimeDateStamp', 
	'2,MajorVersion', 
	'2,MinorVersion', 
	'4,Name', 
	'4,Base', 
	'4,NumberOfFunctions', 
	'4,NumberOfNames', 
	'4,AddressOfFunctions', 
	'4,AddressOfNames', 
	'4,AddressOfNameOrdinals'))

IMAGE_RESOURCE_DIRECTORY = ('IMAGE_RESOURCE_DIRECTORY', (
	'4,Characteristics', 
	'4,TimeDateStamp', 
	'2,MajorVersion', 
	'2,MinorVersion', 
	'2,NumberOfNamedEntries', 
	'2,NumberOfIdEntries'))

IMAGE_RESOURCE_DIRECTORY_ENTRY = ('IMAGE_RESOURCE_DIRECTORY_ENTRY', (
	'4,Name', 
	'4,OffsetToData'))

IMAGE_RESOURCE_DATA_ENTRY = ('IMAGE_RESOURCE_DATA_ENTRY', (
	'4,OffsetToData',
	'4,Size',
	'4,CodePage',
	'4,Reserved'))

VS_VERSIONINFO = ('VS_VERSIONINFO', (
	'2,Length', 
	'2,ValueLength', 
	'2,Type'))

VS_FIXEDFILEINFO = ( 'VS_FIXEDFILEINFO',(
	'4,Signature', 
	'4,StrucVersion', 
	'4,FileVersionMS', 
	'4,FileVersionLS',
	'4,ProductVersionMS', 
	'4,ProductVersionLS', 
	'4,FileFlagsMask', 
	'4,FileFlags', 
	'4,FileOS', 
	'4,FileType', 
	'4,FileSubtype', 
	'4,FileDateMS', 
	'4,FileDateLS'))

StringFileInfo = ('StringFileInfo', (
	'2,Length', 
	'2,ValueLength', 
	'2,Type'))

StringTable = ('StringTable', (
	'2,Length',
	'2,ValueLength',
	'2,Type'))

String = ('String', (
	'2,Length',
	'2,ValueLength',
	'2,Type'))

Var = ( 'Var', (
	'2,Length',
	'2,ValueLength',
	'2,Type' ))

IMAGE_THUNK_DATA = ('IMAGE_THUNK_DATA', (
	'4,ForwarderString,Function,Ordinal,AddressOfData',))

IMAGE_THUNK_DATA64 = ('IMAGE_THUNK_DATA64',
('8,ForwarderString,Function,Ordinal,AddressOfData',))

IMAGE_DEBUG_DIRECTORY = ('IMAGE_DEBUG_DIRECTORY',(
	'4,Characteristics',
	'4,TimeDateStamp',
	'2,MajorVersion',
	'2,MinorVersion',
	'4,Type',
	'4,SizeOfData',
	'4,AddressOfRawData',
	'4,PointerToRawData'))

IMAGE_BASE_RELOCATION = ('IMAGE_BASE_RELOCATION',(
	'4,VirtualAddress', 
	'4,SizeOfBlock') )

IMAGE_BASE_RELOCATION_ENTRY = ('IMAGE_BASE_RELOCATION_ENTRY',(
	'2,Data',) )

IMAGE_TLS_DIRECTORY = ('IMAGE_TLS_DIRECTORY',(
	'4,StartAddressOfRawData',
	'4,EndAddressOfRawData',
	'4,AddressOfIndex',
	'4,AddressOfCallBacks',
	'4,SizeOfZeroFill',
	'4,Characteristics'))

IMAGE_TLS_DIRECTORY64 = ('IMAGE_TLS_DIRECTORY64', (
	'8,StartAddressOfRawData',
	'8,EndAddressOfRawData',
	'8,AddressOfIndex',
	'8,AddressOfCallBacks',
	'4,SizeOfZeroFill',
	'4,Characteristics' ) )

IMAGE_LOAD_CONFIG_DIRECTORY = ('IMAGE_LOAD_CONFIG_DIRECTORY', (
	'4,Size',
	'4,TimeDateStamp',
	'2,MajorVersion',
	'2,MinorVersion',
	'4,GlobalFlagsClear',
	'4,GlobalFlagsSet',
	'4,CriticalSectionDefaultTimeout',
	'4,DeCommitFreeBlockThreshold',
	'4,DeCommitTotalFreeThreshold',
	'4,LockPrefixTable',
	'4,MaximumAllocationSize',
	'4,VirtualMemoryThreshold',
	'4,ProcessHeapFlags',
	'4,ProcessAffinityMask',
	'2,CSDVersion',
	'2,Reserved1',
	'4,EditList',
	'4,SecurityCookie',
	'4,SEHandlerTable',
	'4,SEHandlerCount' ) )

IMAGE_LOAD_CONFIG_DIRECTORY64 = ('IMAGE_LOAD_CONFIG_DIRECTORY64',(
	'4,Size',
	'4,TimeDateStamp',
	'2,MajorVersion',
	'2,MinorVersion',
	'4,GlobalFlagsClear',
	'4,GlobalFlagsSet',
	'4,CriticalSectionDefaultTimeout',
	'8,DeCommitFreeBlockThreshold',
	'8,DeCommitTotalFreeThreshold',
	'8,LockPrefixTable',
	'8,MaximumAllocationSize',
	'8,VirtualMemoryThreshold',
	'8,ProcessAffinityMask',
	'4,ProcessHeapFlags',
	'2,CSDVersion',
	'2,Reserved1',
	'8,EditList',
	'8,SecurityCookie',
	'8,SEHandlerTable',
	'8,SEHandlerCount' ) )

IMAGE_BOUND_IMPORT_DESCRIPTOR = ('IMAGE_BOUND_IMPORT_DESCRIPTOR', (
	'4,TimeDateStamp',
	'2,OffsetModuleName',
	'2,NumberOfModuleForwarderRefs'))

IMAGE_BOUND_FORWARDER_REF = ('IMAGE_BOUND_FORWARDER_REF',(
	'4,TimeDateStamp',
	'2,OffsetModuleName',
	'2,Reserved') )

dds = ('Data_directories',(
    '8,0 IMAGE_DIRECTORY_ENTRY_EXPORT',
    '8,1 IMAGE_DIRECTORY_ENTRY_IMPORT',
    '8,2 IMAGE_DIRECTORY_ENTRY_RESOURCE',
    '8,3 IMAGE_DIRECTORY_ENTRY_EXCEPTION',
    '8,4 IMAGE_DIRECTORY_ENTRY_SECURITY',
    '8,5 IMAGE_DIRECTORY_ENTRY_BASERELOC',
    '8,6 IMAGE_DIRECTORY_ENTRY_DEBUG',
    '8,7 IMAGE_DIRECTORY_ENTRY_COPYRIGHT',
    '8,8 IMAGE_DIRECTORY_ENTRY_GLOBALPTR',
    '8,9 IMAGE_DIRECTORY_ENTRY_TLS',
    '8,A IMAGE_DIRECTORY_ENTRY_LOAD_CONFIG',
    '8,B IMAGE_DIRECTORY_ENTRY_BOUND_IMPORT',
    '8,C IMAGE_DIRECTORY_ENTRY_IAT',
    '8,D IMAGE_DIRECTORY_ENTRY_DELAY_IMPORT',
    '8,E IMAGE_DIRECTORY_ENTRY_COM_DESCRIPTOR',
    '8,F IMAGE_DIRECTORY_ENTRY_RESERVED'))

###############################################################################

def print_header(h):
        name = h[0]
        print "%s [" % name
        print 'label =',
        labels = ['<top> %s \\n' % name]
        for l in h[1]:
                l = l[l.find(",") + 1:]
                #print "\t%s" % l
                labels += ["<%s_%s> %s \\l" % (name.replace(" ", "_"), l.replace(" ", "_"), l)]
        labels = '"%s"' % ("|\\\n".join(labels))
        print labels
        print "];"
        print

def print_cluster(name):
        print "subgraph cluster_%s {" % name.replace(" ", "_")
        print 'style = "dashed";'
        print 'label = "%s";' % name

###############################################################################

print """digraph g {
graph [
rankdir = "LR"
];
node [
fontsize = "10"
shape = "record"
];
edge [
];
"""

print_cluster("a Portable Executable file") 

print_cluster("DOS header") 

IMAGE_DOS_HEADER = ('IMAGE_DOS_HEADER',(
	'2,e_magic',
	'2,e_cblp',
	'2,e_cp',
	'2,e_crlc',
	'2,e_cparhdr',
	'2,e_minalloc',
	'2,e_maxalloc',
	'2,e_ss',
	'2,e_sp',
	'2,e_csum',
	'2,e_ip',
	'2,e_cs',
	'2,e_lfarlc',
	'2,e_ovno',
	'16,e_res',
	'2,e_oemid',
	'2,e_oeminfo',
	'40,e_res2',
	'4,e_lfanew'))

print_header(IMAGE_DOS_HEADER)

print '"offset 0" -> IMAGE_DOS_HEADER:top[contraint = false];'

print 'IMAGE_DOS_HEADER:IMAGE_DOS_HEADER_e_magic -> "''MZ''";'
print "}" # dos header

print_cluster("PE Header")

print_cluster("NT Headers")
#print "subgraph cluster_hack {"
#print 'style = "invis"'

IMAGE_NT_HEADERS = ('IMAGE_NT_HEADERS', ('4,Signature',))
print_header(IMAGE_NT_HEADERS)

IMAGE_FILE_HEADER = ('IMAGE_FILE_HEADER',(
	'2,Machine',
	'2,NumberOfSections',
	'4,TimeDateStamp',
	'4,PointerToSymbolTable',
	'4,NumberOfSymbols',
	'2,SizeOfOptionalHeader',
	'2,Characteristics'))

print_header(IMAGE_FILE_HEADER)
print 'IMAGE_NT_HEADERS -> IMAGE_FILE_HEADER [label="followed by", constraint = false];'

machine_types = [
    ('IMAGE_FILE_MACHINE_UNKNOWN',  0x0000),
    ('IMAGE_FILE_MACHINE_AM33',     0x01d3),
    ('IMAGE_FILE_MACHINE_AMD64',    0x8664),
    ('IMAGE_FILE_MACHINE_ARM',      0x01c0),
    ('IMAGE_FILE_MACHINE_EBC',      0x0ebc),
    ('IMAGE_FILE_MACHINE_I386',     0x014c),
    ('IMAGE_FILE_MACHINE_IA64',     0x0200),
    ('IMAGE_FILE_MACHINE_MR32',     0x9041),
    ('IMAGE_FILE_MACHINE_MIPS16',   0x0266),
    ('IMAGE_FILE_MACHINE_MIPSFPU',  0x0366),
    ('IMAGE_FILE_MACHINE_MIPSFPU16',0x0466),
    ('IMAGE_FILE_MACHINE_POWERPC',  0x01f0),
    ('IMAGE_FILE_MACHINE_POWERPCFP',0x01f1),
    ('IMAGE_FILE_MACHINE_R4000',    0x0166),
    ('IMAGE_FILE_MACHINE_SH3',      0x01a2),
    ('IMAGE_FILE_MACHINE_SH3DSP',   0x01a3),
    ('IMAGE_FILE_MACHINE_SH4',      0x01a6),
    ('IMAGE_FILE_MACHINE_SH5',      0x01a8),
    ('IMAGE_FILE_MACHINE_THUMB',    0x01c2),
    ('IMAGE_FILE_MACHINE_WCEMIPSV2',0x0169),
 ]

IMAGE_OPTIONAL_HEADER = ('IMAGE_OPTIONAL_HEADER',(
	'2,Magic',
	'1,MajorLinkerVersion',
	'1,MinorLinkerVersion',
	'4,SizeOfCode',
	'4,SizeOfInitializedData',
	'4,SizeOfUninitializedData',
	'4,AddressOfEntryPoint',
	'4,BaseOfCode',
	'4,BaseOfData',
	'4,ImageBase',
	'4,SectionAlignment',
	'4,FileAlignment',
	'2,MajorOperatingSystemVersion',
	'2,MinorOperatingSystemVersion',
	'2,MajorImageVersion',
	'2,MinorImageVersion',
	'2,MajorSubsystemVersion',
	'2,MinorSubsystemVersion',
	'4,Reserved1',
	'4,SizeOfImage',
	'4,SizeOfHeaders',
	'4,CheckSum',
	'2,Subsystem',
	'2,DllCharacteristics',
	'4,SizeOfStackReserve',
	'4,SizeOfStackCommit',
	'4,SizeOfHeapReserve',
	'4,SizeOfHeapCommit',
	'4,LoaderFlags',
	'4,NumberOfRvaAndSizes' ))

print_header(IMAGE_OPTIONAL_HEADER)
print 'IMAGE_FILE_HEADER -> IMAGE_OPTIONAL_HEADER[label="followed by", constraint = false];'
#print "}"

print 'IMAGE_NT_HEADERS:IMAGE_NT_HEADERS_Signature -> "PE\\\\0\\\\0";'

print 'IMAGE_DOS_HEADER:IMAGE_DOS_HEADER_e_lfanew -> IMAGE_NT_HEADERS[label="offset", constraint = false];'

print "}" # nt headers

print_cluster("Data directory")
print_header(IMAGE_DATA_DIRECTORY)

print_header(IMAGE_LOAD_CONFIG_DIRECTORY)

print_cluster("exports")
print_header(IMAGE_EXPORT_DIRECTORY)
print "}" # exports

print_cluster("delay imports")
print_header(IMAGE_DELAY_IMPORT_DESCRIPTOR)
print "}" # delay imports

print_cluster("imports")
print_header(IMAGE_IMPORT_DESCRIPTOR)
print "}" # imports

print_cluster("resources")
print_header(IMAGE_RESOURCE_DIRECTORY)
print_header(IMAGE_RESOURCE_DIRECTORY_ENTRY)

print_header(IMAGE_RESOURCE_DATA_ENTRY)
print 'IMAGE_RESOURCE_DIRECTORY -> IMAGE_RESOURCE_DIRECTORY_ENTRY[label="follows"];'
print 'IMAGE_RESOURCE_DIRECTORY_ENTRY:IMAGE_RESOURCE_DIRECTORY_ENTRY_OffsetToData->IMAGE_RESOURCE_DIRECTORY;'
print 'IMAGE_RESOURCE_DIRECTORY_ENTRY:IMAGE_RESOURCE_DIRECTORY_ENTRY_OffsetToData->IMAGE_RESOURCE_DATA_ENTRY;'
print "}" # resources

print_header(IMAGE_LOAD_CONFIG_DIRECTORY)
print_header(IMAGE_THUNK_DATA)

print_cluster("relocations")
print_header(IMAGE_BASE_RELOCATION)
print_header(IMAGE_BASE_RELOCATION_ENTRY)
print("}") # relocs

print_header(IMAGE_DEBUG_DIRECTORY)

print_cluster("bound imports")
print_header(IMAGE_BOUND_FORWARDER_REF)
print_header(IMAGE_BOUND_IMPORT_DESCRIPTOR)
print 'IMAGE_BOUND_IMPORT_DESCRIPTOR -> IMAGE_BOUND_FORWARDER_REF [label = "follows"];'
print "}" # bound

print_cluster("TLS")
print_header(IMAGE_TLS_DIRECTORY)
print "}" # TLS

print 'IMAGE_OPTIONAL_HEADER:IMAGE_OPTIONAL_HEADER_NumberOfRvaAndSizes -> Data_directories[label="counter"];'

print 'Data_directories:Data_directories_0_IMAGE_DIRECTORY_ENTRY_EXPORT -> IMAGE_EXPORT_DIRECTORY[label="0"];'
print 'Data_directories:Data_directories_1_IMAGE_DIRECTORY_ENTRY_IMPORT -> IMAGE_IMPORT_DESCRIPTOR;'
print 'Data_directories:Data_directories_2_IMAGE_DIRECTORY_ENTRY_RESOURCE -> IMAGE_RESOURCE_DIRECTORY;'
print 'Data_directories:Data_directories_3_IMAGE_DIRECTORY_ENTRY_EXCEPTION -> "IMAGE_DIRECTORY_ENTRY_EXCEPTION";'
print 'Data_directories:Data_directories_4_IMAGE_DIRECTORY_ENTRY_SECURITY -> "IMAGE_DIRECTORY_ENTRY_SECURITY";'
print 'Data_directories:Data_directories_5_IMAGE_DIRECTORY_ENTRY_BASERELOC -> IMAGE_BASE_RELOCATION;'
print 'Data_directories:Data_directories_6_IMAGE_DIRECTORY_ENTRY_DEBUG -> IMAGE_DEBUG_DIRECTORY;'
print 'Data_directories:Data_directories_7_IMAGE_DIRECTORY_ENTRY_COPYRIGHT -> "IMAGE_DIRECTORY_ENTRY_COPYRIGHT";'
print 'Data_directories:Data_directories_8_IMAGE_DIRECTORY_ENTRY_GLOBALPTR -> "IMAGE_DIRECTORY_ENTRY_GLOBALPTR";'
print 'Data_directories:Data_directories_9_IMAGE_DIRECTORY_ENTRY_TLS -> IMAGE_TLS_DIRECTORY;'
print 'Data_directories:Data_directories_A_IMAGE_DIRECTORY_ENTRY_LOAD_CONFIG -> IMAGE_LOAD_CONFIG_DIRECTORY;'
print 'Data_directories:Data_directories_B_IMAGE_DIRECTORY_ENTRY_BOUND_IMPORT -> IMAGE_BOUND_IMPORT_DESCRIPTOR;'
print 'Data_directories:Data_directories_C_IMAGE_DIRECTORY_ENTRY_IAT -> "IAT";'
print 'Data_directories:Data_directories_D_IMAGE_DIRECTORY_ENTRY_DELAY_IMPORT -> IMAGE_DELAY_IMPORT_DESCRIPTOR;'
print 'Data_directories:Data_directories_E_IMAGE_DIRECTORY_ENTRY_COM_DESCRIPTOR -> "COM";'
print 'Data_directories:Data_directories_F_IMAGE_DIRECTORY_ENTRY_RESERVED -> "reserved";'

print "}" # DDs

print_cluster("section table")

IMAGE_SECTION_HEADER = ('IMAGE_SECTION_HEADER',
('8s,Name', '4,Misc,Misc_PhysicalAddress,Misc_VirtualSize',
'4,VirtualAddress', '4,SizeOfRawData', '4,PointerToRawData',
'4,PointerToRelocations', '4,PointerToLinenumbers',
'2,NumberOfRelocations', '2,NumberOfLinenumbers',
'4,Characteristics'))

print_header(IMAGE_SECTION_HEADER)
print "}" # sections


print_header(dds)

print 'IMAGE_OPTIONAL_HEADER -> Data_directories:top[label="follows"];'

print 'IMAGE_FILE_HEADER:IMAGE_FILE_HEADER_NumberOfSections -> IMAGE_SECTION_HEADER[label="counter"];'


print 'IMAGE_FILE_HEADER:IMAGE_FILE_HEADER_SizeOfOptionalHeader->IMAGE_SECTION_HEADER[label="relative offset"];'

print 'IMAGE_BASE_RELOCATION->IMAGE_BASE_RELOCATION_ENTRY[label="follows"];'
print "}" # DDs

print "}" # PE header

# print_cluster("64 bit")
# print_header(IMAGE_TLS_DIRECTORY64)

IMAGE_OPTIONAL_HEADER64 = ('IMAGE_OPTIONAL_HEADER64',
('2,Magic', '1,MajorLinkerVersion',
'1,MinorLinkerVersion', '4,SizeOfCode',
'4,SizeOfInitializedData', '4,SizeOfUninitializedData',
'4,AddressOfEntryPoint', '4,BaseOfCode',
'8,ImageBase', '4,SectionAlignment', '4,FileAlignment',
'2,MajorOperatingSystemVersion', '2,MinorOperatingSystemVersion',
'2,MajorImageVersion', '2,MinorImageVersion',
'2,MajorSubsystemVersion', '2,MinorSubsystemVersion',
'4,Reserved1', '4,SizeOfImage', '4,SizeOfHeaders',
'4,CheckSum', '2,Subsystem', '2,DllCharacteristics',
'8,SizeOfStackReserve', '8,SizeOfStackCommit',
'8,SizeOfHeapReserve', '8,SizeOfHeapCommit',
'4,LoaderFlags', '4,NumberOfRvaAndSizes' ))

# print_header(IMAGE_OPTIONAL_HEADER64)
# print_header(IMAGE_THUNK_DATA64)
# print_header(IMAGE_LOAD_CONFIG_DIRECTORY64)
# print "}" # 64b

print "}" # PE file

