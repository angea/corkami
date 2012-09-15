###############################################################################

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

###############################################################################

IMAGE_THUNK_DATA = ('IMAGE_THUNK_DATA', (
	'4,ForwarderString,Function,Ordinal,AddressOfData',))

IMAGE_THUNK_DATA64 = ('IMAGE_THUNK_DATA64',
('8,ForwarderString,Function,Ordinal,AddressOfData',))

###############################################################################

def print_header(h, copy=""):
	name = h[0]
	labels = ['<top> %s \\n' % name] # visually, it should be the same

	name = name + copy
	print "%s [" % (name)
	print 'label =',
	for l in h[1]:
			fields = l.split(",")
			size, field = fields[0], ",".join(fields[1:])
			#print "\t%s" % l
			#labels += ["<%s_%s> +%02x %s \\l" % (name.replace(" ", "_"), field.replace(" ", "_"), int(size), field)]
			labels += ["<%s> +%02x %s \\l" % (field.replace(" ", "_"), int(size), field)]
	labels = '"%s"' % ("|\\\n".join(labels))
	print labels
	print "];"
	print

def start_cluster(name):
	print "subgraph cluster_%s {" % name.replace(" ", "_")
	print 'style = "dashed";'
	print 'label = "%s";' % name

def end_cluster():
	print "}"

def transition(src_block, src_element, target_block, target_element=None, style=None):
	target_element = "" if target_element is None else ":<%s>" % target_element
	style = "" if style is None else "[%s]" % style
	src_element = ":" + src_element if src_element != "" else src_element
	print '%s%s -> %s%s %s;' % (src_block, src_element, target_block, target_element, style)

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

###############################################################################

start_cluster("a Portable Executable file")

###############################################################################

start_cluster("DOS header")

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

print 'MZ [shape = "none", label="Signature: \'MZ\'"];'

transition('"OFFSET: 0"', "", "IMAGE_DOS_HEADER", "top")
transition('IMAGE_DOS_HEADER', 'e_magic', 'MZ')
end_cluster() # dos header

###############################################################################

start_cluster("PE Header")

start_cluster("NT Headers")
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
transition('IMAGE_NT_HEADERS', '', 'IMAGE_FILE_HEADER', 'top', 'label="followed by", weight = 1000')

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

IMAGE_OPTIONAL_HEADER64 = ('IMAGE_OPTIONAL_HEADER64', (
        '2,Magic',
        '1,MajorLinkerVersion',
        '1,MinorLinkerVersion',
        '4,SizeOfCode',
        '4,SizeOfInitializedData',
        '4,SizeOfUninitializedData',
        '4,AddressOfEntryPoint',
        '4,BaseOfCode',
        '8,ImageBase',
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
        '8,SizeOfStackReserve',
        '8,SizeOfStackCommit',
        '8,SizeOfHeapReserve',
        '8,SizeOfHeapCommit',
        '4,LoaderFlags',
        '4,NumberOfRvaAndSizes' ))

print_header(IMAGE_OPTIONAL_HEADER)
print '{rank = same; IMAGE_OPTIONAL_HEADER;IMAGE_NT_HEADERS;IMAGE_FILE_HEADER;}'

transition('IMAGE_FILE_HEADER', '', 'IMAGE_OPTIONAL_HEADER', 'top', 'label="followed by"')
print 'IMAGE_NT_HEADERS:Signature -> "SIGNATURE: PE\\\\0\\\\0";'

transition('IMAGE_DOS_HEADER', 'e_lfanew', 'IMAGE_NT_HEADERS', 'top', 'label="offset", weight=1000')

end_cluster() # nt headers

###############################################################################

start_cluster("Data directory")

dds = ('Data_directories',(
        '8,IMAGE_DIRECTORY_ENTRY_EXPORT',
        '8,IMAGE_DIRECTORY_ENTRY_IMPORT',
        '8,IMAGE_DIRECTORY_ENTRY_RESOURCE',
        '8,IMAGE_DIRECTORY_ENTRY_EXCEPTION',
        '8,IMAGE_DIRECTORY_ENTRY_SECURITY',
        '8,IMAGE_DIRECTORY_ENTRY_BASERELOC',
        '8,IMAGE_DIRECTORY_ENTRY_DEBUG',
        '8,IMAGE_DIRECTORY_ENTRY_COPYRIGHT',
        '8,IMAGE_DIRECTORY_ENTRY_GLOBALPTR',
        '8,IMAGE_DIRECTORY_ENTRY_TLS',
        '8,IMAGE_DIRECTORY_ENTRY_LOAD_CONFIG',
        '8,IMAGE_DIRECTORY_ENTRY_BOUND_IMPORT',
        '8,IMAGE_DIRECTORY_ENTRY_IAT',
        '8,IMAGE_DIRECTORY_ENTRY_DELAY_IMPORT',
        '8,IMAGE_DIRECTORY_ENTRY_COM_DESCRIPTOR',
        '8,IMAGE_DIRECTORY_ENTRY_RESERVED',
        '8,[ignored]...'))
print_header(dds)


IMAGE_DATA_DIRECTORY = ('IMAGE_DATA_DIRECTORY', (
	'4,VirtualAddress',
	'4,Size'))

print_header(IMAGE_DATA_DIRECTORY)

print 'IMAGE_OPTIONAL_HEADER:NumberOfRvaAndSizes -> Data_directories[label="counter"];'

start_cluster("exports")
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

print_header(IMAGE_EXPORT_DIRECTORY)
end_cluster() # exports
print 'Data_directories:IMAGE_DIRECTORY_ENTRY_EXPORT -> IMAGE_EXPORT_DIRECTORY;'

###############################################################################

start_cluster("imports")
IMAGE_IMPORT_DESCRIPTOR =  ('IMAGE_IMPORT_DESCRIPTOR', (
	'4,OriginalFirstThunk,Characteristics',
	'4,TimeDateStamp',
	'4,ForwarderChain',
	'4,Name',
	'4,FirstThunk'))

print_header(IMAGE_IMPORT_DESCRIPTOR)
end_cluster() # imports
print 'Data_directories:IMAGE_DIRECTORY_ENTRY_IMPORT -> IMAGE_IMPORT_DESCRIPTOR;'

###############################################################################

start_cluster("resources")
IMAGE_RESOURCE_DIRECTORY = ('IMAGE_RESOURCE_DIRECTORY', (
	'4,Characteristics',
	'4,TimeDateStamp',
	'2,MajorVersion',
	'2,MinorVersion',
	'2,NumberOfNamedEntries',
	'2,NumberOfIdEntries'))
print_header(IMAGE_RESOURCE_DIRECTORY)

IMAGE_RESOURCE_DIRECTORY_ENTRY = ('IMAGE_RESOURCE_DIRECTORY_ENTRY', (
	'4,Name',
	'4,OffsetToData'))
print_header(IMAGE_RESOURCE_DIRECTORY_ENTRY)

IMAGE_RESOURCE_DATA_ENTRY = ('IMAGE_RESOURCE_DATA_ENTRY', (
	'4,OffsetToData',
	'4,Size',
	'4,CodePage',
	'4,Reserved'))
print_header(IMAGE_RESOURCE_DATA_ENTRY)

print 'IMAGE_RESOURCE_DIRECTORY -> IMAGE_RESOURCE_DIRECTORY_ENTRY:top[label="follows"];'
print 'IMAGE_RESOURCE_DIRECTORY_ENTRY:OffsetToData->IMAGE_RESOURCE_DIRECTORY;'
print 'IMAGE_RESOURCE_DIRECTORY_ENTRY:OffsetToData->IMAGE_RESOURCE_DATA_ENTRY;'
print '{rank = same; IMAGE_RESOURCE_DIRECTORY;IMAGE_RESOURCE_DIRECTORY_ENTRY;}'
start_cluster("resources standard structure")

start_cluster("root level")
print_header(IMAGE_RESOURCE_DIRECTORY, "1")
print_header(IMAGE_RESOURCE_DIRECTORY_ENTRY, "1")
end_cluster() # root

start_cluster("type level")
print_header(IMAGE_RESOURCE_DIRECTORY, "2")
print_header(IMAGE_RESOURCE_DIRECTORY_ENTRY, "2")
print "IMAGE_RESOURCE_DIRECTORY_ENTRY1:OffsetToData -> IMAGE_RESOURCE_DIRECTORY2:top;"
end_cluster() # type

start_cluster("language level")
print_header(IMAGE_RESOURCE_DIRECTORY, "3")
print_header(IMAGE_RESOURCE_DIRECTORY_ENTRY, "3")
print "IMAGE_RESOURCE_DIRECTORY_ENTRY2:OffsetToData -> IMAGE_RESOURCE_DIRECTORY3:top;"
end_cluster() # language

start_cluster("resource data")
print_header(IMAGE_RESOURCE_DATA_ENTRY, "1")
print "IMAGE_RESOURCE_DIRECTORY_ENTRY3:OffsetToData -> IMAGE_RESOURCE_DATA_ENTRY1:top;"
print "IMAGE_RESOURCE_DATA_ENTRY1:OffsetToData -> Data;"
print "IMAGE_RESOURCE_DATA_ENTRY1:Size -> Data;"
end_cluster() # data

end_cluster() # resources' standard structure
end_cluster() # resources
print 'Data_directories:IMAGE_DIRECTORY_ENTRY_RESOURCE -> IMAGE_RESOURCE_DIRECTORY;'

###############################################################################

print 'Data_directories:IMAGE_DIRECTORY_ENTRY_EXCEPTION -> "IMAGE_DIRECTORY_ENTRY_EXCEPTION";'

###############################################################################

print 'Data_directories:IMAGE_DIRECTORY_ENTRY_SECURITY -> "IMAGE_DIRECTORY_ENTRY_SECURITY";'

print_header(IMAGE_THUNK_DATA)

###############################################################################

start_cluster("relocations")
IMAGE_BASE_RELOCATION = ('IMAGE_BASE_RELOCATION',(
	'4,VirtualAddress',
	'4,SizeOfBlock') )
print_header(IMAGE_BASE_RELOCATION)

IMAGE_BASE_RELOCATION_ENTRY = ('IMAGE_BASE_RELOCATION_ENTRY',(
	'2,Data',) )
print_header(IMAGE_BASE_RELOCATION_ENTRY)
print("}") # relocs

print 'Data_directories:IMAGE_DIRECTORY_ENTRY_BASERELOC -> IMAGE_BASE_RELOCATION;'
print 'IMAGE_BASE_RELOCATION->IMAGE_BASE_RELOCATION_ENTRY:top[label="follows"];'

###############################################################################

start_cluster("debug")
IMAGE_DEBUG_DIRECTORY = ('IMAGE_DEBUG_DIRECTORY',(
	'4,Characteristics',
	'4,TimeDateStamp',
	'2,MajorVersion',
	'2,MinorVersion',
	'4,Type',
	'4,SizeOfData',
	'4,AddressOfRawData',
	'4,PointerToRawData'))
print_header(IMAGE_DEBUG_DIRECTORY)
print("}") #debug

###############################################################################

print 'Data_directories:IMAGE_DIRECTORY_ENTRY_DEBUG -> IMAGE_DEBUG_DIRECTORY;'

###############################################################################

print 'Data_directories:IMAGE_DIRECTORY_ENTRY_COPYRIGHT -> "IMAGE_DIRECTORY_ENTRY_COPYRIGHT";'

###############################################################################

print 'Data_directories:IMAGE_DIRECTORY_ENTRY_GLOBALPTR -> "IMAGE_DIRECTORY_ENTRY_GLOBALPTR";'

###############################################################################

start_cluster("Thread Local Storage")
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

print """TLS_Callbacks [label = "<top>CALLBACKS | callback1 (VA) \l| ...\l"];"""
print_header(IMAGE_TLS_DIRECTORY)
print 'IMAGE_TLS_DIRECTORY:AddressOfCallBacks -> TLS_Callbacks;'
print 'IMAGE_TLS_DIRECTORY:AddressOfIndex -> "Pointer overwritten by index of current callback (0, 1, ...)";'
end_cluster() # TLS
print 'Data_directories:IMAGE_DIRECTORY_ENTRY_TLS -> IMAGE_TLS_DIRECTORY;'

###############################################################################
start_cluster("Load Config")

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

print_header(IMAGE_LOAD_CONFIG_DIRECTORY)
print("}") #load config

print 'Data_directories:IMAGE_DIRECTORY_ENTRY_LOAD_CONFIG -> IMAGE_LOAD_CONFIG_DIRECTORY;'

###############################################################################

start_cluster("bound imports")

IMAGE_BOUND_FORWARDER_REF = ('IMAGE_BOUND_FORWARDER_REF',(
	'4,TimeDateStamp',
	'2,OffsetModuleName',
	'2,Reserved') )
print_header(IMAGE_BOUND_FORWARDER_REF)

IMAGE_BOUND_IMPORT_DESCRIPTOR = ('IMAGE_BOUND_IMPORT_DESCRIPTOR', (
	'4,TimeDateStamp',
	'2,OffsetModuleName',
	'2,NumberOfModuleForwarderRefs'))
print_header(IMAGE_BOUND_IMPORT_DESCRIPTOR)
print 'IMAGE_BOUND_IMPORT_DESCRIPTOR -> IMAGE_BOUND_FORWARDER_REF [label = "follows"];'
end_cluster() # bound
print 'Data_directories:IMAGE_DIRECTORY_ENTRY_BOUND_IMPORT -> IMAGE_BOUND_IMPORT_DESCRIPTOR;'

###############################################################################

print 'Data_directories:IMAGE_DIRECTORY_ENTRY_IAT -> "IAT";'

###############################################################################
start_cluster("delay imports")

IMAGE_DELAY_IMPORT_DESCRIPTOR = ('IMAGE_DELAY_IMPORT_DESCRIPTOR',(
	'4,grAttrs',
	'4,szName',
	'4,phmod',
	'4,pIAT',
	'4,pINT',
	'4,pBoundIAT',
	'4,pUnloadIAT',
	'4,dwTimeStamp'))

print_header(IMAGE_DELAY_IMPORT_DESCRIPTOR)
end_cluster() # delay imports
print 'Data_directories:IMAGE_DIRECTORY_ENTRY_DELAY_IMPORT -> IMAGE_DELAY_IMPORT_DESCRIPTOR;'

###############################################################################

print 'Data_directories:IMAGE_DIRECTORY_ENTRY_COM_DESCRIPTOR -> "COM";'

###############################################################################

print 'Data_directories:IMAGE_DIRECTORY_ENTRY_RESERVED -> "reserved";'

###############################################################################

end_cluster() # DDs

###############################################################################

start_cluster("section table")

IMAGE_SECTION_HEADER = ('IMAGE_SECTION_HEADER', (
        '8,Name',
        '4,Misc,Misc_PhysicalAddress,Misc_VirtualSize',
        '4,VirtualAddress',
        '4,SizeOfRawData',
        '4,PointerToRawData',
        '4,PointerToRelocations',
        '4,PointerToLinenumbers',
        '2,NumberOfRelocations',
        '2,NumberOfLinenumbers',
        '4,Characteristics'))

print_header(IMAGE_SECTION_HEADER)

print 'IMAGE_FILE_HEADER:NumberOfSections -> IMAGE_SECTION_HEADER:top[label="counter"];'
print 'IMAGE_FILE_HEADER:SizeOfOptionalHeader -> IMAGE_SECTION_HEADER:top[label="relative offset"];'
end_cluster() # sections

###############################################################################

print 'IMAGE_OPTIONAL_HEADER -> Data_directories:top[label="follows"];'

end_cluster() # DDs

end_cluster() # PE header

end_cluster() # PE file
