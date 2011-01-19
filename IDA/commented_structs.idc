// this IDC script contains 'standard' (including 'undocumented' structure such as TIB and PEB)
// with repeatable comments for their members, so that it's easier to know structure members are pointing to

//example, knowing that fs:0 is the _TIB:
// mov eax, large fs:30h
// mov eax, [eax+0Ch]
// mov eax, [eax+0Ch]
// mov eax, [eax]
// mov eax, [eax]
// mov eax, [eax+18h]

// mov eax, large fs:_TIB.PebPtr ; _PEB
// mov eax, [eax+_PEB.Ldr] ; _PEB_LDR_DATA
// mov eax, [eax+_PEB_LDR_DATA.InLoadOrderModuleList.Flink] ; _LDR_MODULE
// mov eax, [eax+_LDR_MODULE.InLoadOrderModuleList.Flink] ; _LDR_MODULE
// mov eax, [eax+_LDR_MODULE.InLoadOrderModuleList.Flink] ; _LDR_MODULE
// mov eax, [eax+_LDR_MODULE.BaseAddress]

// Ange Albertini 2011
// BSD Licence
// Thanks to Elias Bachaalany for his help

#define UNLOADED_FILE   1
#include <idc.idc>

static main(void) {
        Enums();                // enumerations
        Structures();           // structure types
	LowVoids(0x10000);
	HighVoids(0x7FFE1000);
}

//------------------------------------------------------------------------
// Information about enum types

static Enums(void) {
        auto id;
}

static Structures_0(id) {

	id = AddStrucEx(-1,"_IMAGE_RESOURCE_DIRECTORY_ENTRY::$7AACFB3DBED1BA3D55397FFBFADEE77C::$45C58CAF9905A50F8AA1384997788C55",0);
	id = AddStrucEx(-1,"_IMAGE_RESOURCE_DIRECTORY_ENTRY::$7AACFB3DBED1BA3D55397FFBFADEE77C",1);
	id = AddStrucEx(-1,"_IMAGE_RESOURCE_DIRECTORY_ENTRY::$21F14C53C6B1BB262D09330CFB432764::$D336A141F49B1DF346892EAF19BAFECD",0);
	id = AddStrucEx(-1,"_IMAGE_RESOURCE_DIRECTORY_ENTRY::$21F14C53C6B1BB262D09330CFB432764",1);
	id = AddStrucEx(-1,"_IMAGE_THUNK_DATA64_u",1);
	id = AddStrucEx(-1,"_IMAGE_THUNK_DATA32_u",1);
	id = AddStrucEx(-1,"_IMAGE_IMPORT_BY_NAME",0);
	id = AddStrucEx(-1,"_IMAGE_IMPORT_DESCRIPTOR_u",1);
	id = AddStrucEx(-1,"_IMAGE_THUNK_DATA64",0);
	id = AddStrucEx(-1,"_IMAGE_THUNK_DATA32",0);
	id = AddStrucEx(-1,"_IMAGE_SECTION_HEADER_u",1);
	id = AddStrucEx(-1,"IMAGE_DATA_DIRECTORY",0);
	id = AddStrucEx(-1,"IMAGE_DIRECTORY_ENTRY_EXPORT",0);
	id = AddStrucEx(-1,"IMAGE_DIRECTORY_ENTRY_IMPORT",0);
	id = AddStrucEx(-1,"_IMAGE_IMPORT_DESCRIPTOR",0);
	id = AddStrucEx(-1,"IMAGE_DIRECTORY_ENTRY_RESOURCE",0);
	id = AddStrucEx(-1,"_IMAGE_RESOURCE_DIRECTORY",0);
	id = AddStrucEx(-1,"IMAGE_RESOURCE_DIRECTORY_ENTRY",0);
	id = AddStrucEx(-1,"_IMAGE_SECTION_HEADER",0);
	id = AddStrucEx(-1,"IMAGE_OPTIONAL_HEADER32",0);
	id = AddStrucEx(-1,"IMAGE_DIRECTORY_ENTRY_DELAY_IMPORT",0);
	id = AddStrucEx(-1,"IMAGE_DIRECTORY_ENTRY_DEBUG",0);
	id = AddStrucEx(-1,"_IMAGE_DEBUG_DIRECTORY",0);
	id = AddStrucEx(-1,"IMAGE_TLS_DIRECTORY",0);
	id = AddStrucEx(-1,"IMAGE_DIRECTORY_ENTRY_TLS",0);
	id = AddStrucEx(-1,"IMAGE_FILE_HEADER",0);
	id = AddStrucEx(-1,"_UNICODE_STRING",0);
	id = AddStrucEx(-1,"_ULARGE_INTEGER_u",0);
	id = AddStrucEx(-1,"_ULARGE_INTEGER",1);
	id = AddStrucEx(-1,"_LARGE_INTEGER_u",0);
	id = AddStrucEx(-1,"_LARGE_INTEGER",1);
	id = AddStrucEx(-1,"_LIST_ENTRY",0);
	id = AddStrucEx(-1,"IMAGE_EXPORT_DIRECTORY",0);
	id = AddStrucEx(-1,"_PEB",0);
	id = AddStrucEx(-1,"_PEB_LDR_DATA",0);
	id = AddStrucEx(-1,"IMAGE_DOS_HEADER",0);
	id = AddStrucEx(-1,"LIST_ENTRY",0);
	id = AddStrucEx(-1,"_TIB_u",1);
	id = AddStrucEx(-1,"_TIB",0);
	id = AddStrucEx(-1,"IMAGE_NT_HEADERS",0);
	id = AddStrucEx(-1,"IMAGE_OPTIONAL_HEADER64",0);
	id = AddStrucEx(-1,"_LDR_MODULE",0);
	
	id = GetStrucIdByName("_IMAGE_IMPORT_BY_NAME");
	AddStrucMember(id,"Hint",	0X0,	0x10000400,	-1,	2);
	AddStrucMember(id,"Name",	0X2,	0x000400,	-1,	1);
	AddStrucMember(id,"_padding",	0X3,	0x000400,	-1,	1);
	
	id = GetStrucIdByName("_IMAGE_THUNK_DATA64_u");
	AddStrucMember(id,"ForwarderString",	0X0,	0x30000400,	-1,	8);
	AddStrucMember(id,"Function",	0X0,	0x30000400,	-1,	8);
	AddStrucMember(id,"Ordinal",	0X0,	0x30000400,	-1,	8);
	AddStrucMember(id,"AddressOfData",	0X0,	0x30000400,	-1,	8);
	SetMemberComment(id,	0X3,	"RVA",	1);
	
	id = GetStrucIdByName("_IMAGE_THUNK_DATA64");
	AddStrucMember(id,"u1",	0X0,	0x60000400,	GetStrucIdByName("_IMAGE_THUNK_DATA64_u"),	8);
	
	id = GetStrucIdByName("_IMAGE_THUNK_DATA32_u");
	AddStrucMember(id,"ForwarderString",	0X0,	0x20000400,	-1,	4);
	AddStrucMember(id,"Function",	0X0,	0x20500400,	0XFFFFFFFF,	4);
	AddStrucMember(id,"Ordinal",	0X0,	0x20000400,	-1,	4);
	AddStrucMember(id,"AddressOfData",	0X0,	0x20000400,	-1,	4);
	SetMemberComment(id,	0X3,	"_IMAGE_IMPORT_BY_NAME",	1);
	
	id = GetStrucIdByName("_IMAGE_THUNK_DATA32");
	AddStrucMember(id,"u1",	0X0,	0x60000400,	GetStrucIdByName("_IMAGE_THUNK_DATA32_u"),	4);
	
	id = GetStrucIdByName("_IMAGE_IMPORT_DESCRIPTOR_u");
	AddStrucMember(id,"Characteristics",	0X0,	0x20000400,	-1,	4);
	AddStrucMember(id,"OriginalFirstThunk",	0X0,	0x20000400,	-1,	4);
	SetMemberComment(id,	0X1,	"_IMAGE_THUNK_DATA32 / _IMAGE_THUNK_DATA64  (RVA)",	1);
	
	id = GetStrucIdByName("_IMAGE_IMPORT_DESCRIPTOR");
	AddStrucMember(id,"anonymous_0",	0X0,	0x60000400,	GetStrucIdByName("_IMAGE_IMPORT_DESCRIPTOR_u"),	4);
	AddStrucMember(id,"TimeDateStamp",	0X4,	0x20000400,	-1,	4);
	AddStrucMember(id,"ForwarderChain",	0X8,	0x20000400,	-1,	4);
	AddStrucMember(id,"Name",	0XC,	0x20000400,	-1,	4);
	AddStrucMember(id,"FirstThunk",	0X10,	0x20000400,	-1,	4);
	
	id = GetStrucIdByName("_IMAGE_RESOURCE_DIRECTORY");
	AddStrucMember(id,"Characteristics",	0X0,	0x20000400,	-1,	4);
	AddStrucMember(id,"TimeDateStamp",	0X4,	0x20000400,	-1,	4);
	AddStrucMember(id,"MajorVersion",	0X8,	0x10000400,	-1,	2);
	AddStrucMember(id,"MinorVersion",	0XA,	0x10000400,	-1,	2);
	AddStrucMember(id,"NumberOfNamedEntries",	0XC,	0x10000400,	-1,	2);
	AddStrucMember(id,"NumberOfIdEntries",	0XE,	0x10000400,	-1,	2);
	
	id = GetStrucIdByName("_IMAGE_RESOURCE_DIRECTORY_ENTRY::$7AACFB3DBED1BA3D55397FFBFADEE77C::$45C58CAF9905A50F8AA1384997788C55");
	AddStrucMember(id,"DataIsDirectory",	0X0,	0x20000400,	-1,	4);
	
	id = GetStrucIdByName("_IMAGE_RESOURCE_DIRECTORY_ENTRY::$7AACFB3DBED1BA3D55397FFBFADEE77C");
	AddStrucMember(id,"OffsetToData",	0X0,	0x20000400,	-1,	4);
	SetMemberComment(id,	0X0,	"_IMAGE_RESOURCE_DIRECTORY (relative offset) / [DATA] (RVA)",	1);
	AddStrucMember(id,"anonymous_0",	0X0,	0x60000400,	GetStrucIdByName("_IMAGE_RESOURCE_DIRECTORY_ENTRY::$7AACFB3DBED1BA3D55397FFBFADEE77C::$45C58CAF9905A50F8AA1384997788C55"),	4);
	
	id = GetStrucIdByName("_IMAGE_RESOURCE_DIRECTORY_ENTRY::$21F14C53C6B1BB262D09330CFB432764::$D336A141F49B1DF346892EAF19BAFECD");
	AddStrucMember(id,"NameIsString",	0X0,	0x20000400,	-1,	4);
	
	id = GetStrucIdByName("_IMAGE_RESOURCE_DIRECTORY_ENTRY::$21F14C53C6B1BB262D09330CFB432764");
	AddStrucMember(id,"anonymous_0",	0X0,	0x60000400,	GetStrucIdByName("_IMAGE_RESOURCE_DIRECTORY_ENTRY::$21F14C53C6B1BB262D09330CFB432764::$D336A141F49B1DF346892EAF19BAFECD"),	4);
	AddStrucMember(id,"Name",	0X0,	0x20000400,	-1,	4);
	AddStrucMember(id,"Id",	0X0,	0x10000400,	-1,	2);
	
	id = GetStrucIdByName("IMAGE_RESOURCE_DIRECTORY_ENTRY");
	AddStrucMember(id,"anonymous_0",	0X0,	0x60000400,	GetStrucIdByName("_IMAGE_RESOURCE_DIRECTORY_ENTRY::$21F14C53C6B1BB262D09330CFB432764"),	4);
	AddStrucMember(id,"anonymous_1",	0X4,	0x60000400,	GetStrucIdByName("_IMAGE_RESOURCE_DIRECTORY_ENTRY::$7AACFB3DBED1BA3D55397FFBFADEE77C"),	4);
	
	id = GetStrucIdByName("_IMAGE_SECTION_HEADER_u");
	AddStrucMember(id,"PhysicalAddress",	0X0,	0x20000400,	-1,	4);
	AddStrucMember(id,"VirtualSize",	0X0,	0x20000400,	-1,	4);
	
	id = GetStrucIdByName("_IMAGE_SECTION_HEADER");
	AddStrucMember(id,"Name",	0X0,	0x000400,	-1,	8);
	AddStrucMember(id,"Misc",	0X8,	0x60000400,	GetStrucIdByName("_IMAGE_SECTION_HEADER_u"),	4);
	AddStrucMember(id,"VirtualAddress",	0XC,	0x20000400,	-1,	4);
	SetMemberComment(id,	0XC,	"RVA",	1);
	AddStrucMember(id,"SizeOfRawData",	0X10,	0x20000400,	-1,	4);
	AddStrucMember(id,"PointerToRawData",	0X14,	0x20000400,	-1,	4);
	SetMemberComment(id,	0X14,	"Offset",	1);
	AddStrucMember(id,"PointerToRelocations",	0X18,	0x20000400,	-1,	4);
	AddStrucMember(id,"PointerToLinenumbers",	0X1C,	0x20000400,	-1,	4);
	AddStrucMember(id,"NumberOfRelocations",	0X20,	0x10000400,	-1,	2);
	AddStrucMember(id,"NumberOfLinenumbers",	0X22,	0x10000400,	-1,	2);
	AddStrucMember(id,"Characteristics",	0X24,	0x20000400,	-1,	4);
	
	id = GetStrucIdByName("_IMAGE_DEBUG_DIRECTORY");
	AddStrucMember(id,"Characteristics",	0X0,	0x20000400,	-1,	4);
	AddStrucMember(id,"TimeDateStamp",	0X4,	0x20000400,	-1,	4);
	AddStrucMember(id,"MajorVersion",	0X8,	0x10000400,	-1,	2);
	AddStrucMember(id,"MinorVersion",	0XA,	0x10000400,	-1,	2);
	AddStrucMember(id,"Type",	0XC,	0x20000400,	-1,	4);
	AddStrucMember(id,"SizeOfData",	0X10,	0x20000400,	-1,	4);
	AddStrucMember(id,"AddressOfRawData",	0X14,	0x20000400,	-1,	4);
	AddStrucMember(id,"PointerToRawData",	0X18,	0x20000400,	-1,	4);
	
	id = GetStrucIdByName("IMAGE_TLS_DIRECTORY");
	AddStrucMember(id,"StartAddressOfRawData",	0X0,	0x20000400,	-1,	4);
	AddStrucMember(id,"EndAddressOfRawData",	0X4,	0x20000400,	-1,	4);
	AddStrucMember(id,"AddressOfIndex",	0X8,	0x20000400,	-1,	4);
	AddStrucMember(id,"AddressOfCallBacks",	0XC,	0x20500400,	0XFFFFFFFF,	4);
	SetMemberComment(id,	0XC,	"Callbacks\n(null-terminated list of offset)",	1);
	AddStrucMember(id,"SizeOfZeroFill",	0X10,	0x20000400,	-1,	4);
	AddStrucMember(id,"Characteristics",	0X14,	0x20000400,	-1,	4);
	
	id = GetStrucIdByName("IMAGE_EXPORT_DIRECTORY");
	AddStrucMember(id,"Characteristics",	0X0,	0x20000400,	-1,	4);
	AddStrucMember(id,"TimeDateStamp",	0X4,	0x20000400,	-1,	4);
	AddStrucMember(id,"MajorVersion",	0X8,	0x10000400,	-1,	2);
	AddStrucMember(id,"MinorVersion",	0XA,	0x10000400,	-1,	2);
	AddStrucMember(id,"Name",	0XC,	0x20000400,	-1,	4);
	AddStrucMember(id,"Base",	0X10,	0x20000400,	-1,	4);
	AddStrucMember(id,"NumberOfFunctions",	0X14,	0x20000400,	-1,	4);
	AddStrucMember(id,"NumberOfNames",	0X18,	0x20000400,	-1,	4);
	AddStrucMember(id,"AddressOfFunctions",	0X1C,	0x20000400,	-1,	4);
	AddStrucMember(id,"AddressOfNames",	0X20,	0x20000400,	-1,	4);
	AddStrucMember(id,"AddressOfNameOrdinals",	0X24,	0x20000400,	-1,	4);
	
	id = GetStrucIdByName("_UNICODE_STRING");
	AddStrucMember(id,"Length",	0X0,	0x10000400,	-1,	2);
	AddStrucMember(id,"MaximumLength",	0X2,	0x10000400,	-1,	2);
	AddStrucMember(id,"Buffer",	0X4,	0x25500400,	0XFFFFFFFF,	4);
	
	id = GetStrucIdByName("_ULARGE_INTEGER_u");
	AddStrucMember(id,"LowPart",	0X0,	0x20000400,	-1,	4);
	AddStrucMember(id,"HighPart",	0X4,	0x20000400,	-1,	4);
	
	id = GetStrucIdByName("_ULARGE_INTEGER");
	AddStrucMember(id,"anonymous_0",	0X0,	0x60000400,	GetStrucIdByName("_ULARGE_INTEGER_u"),	8);
	AddStrucMember(id,"u",	0X0,	0x60000400,	GetStrucIdByName("_ULARGE_INTEGER_u"),	8);
	AddStrucMember(id,"QuadPart",	0X0,	0x30000400,	-1,	8);
	
	id = GetStrucIdByName("_LARGE_INTEGER_u");
	AddStrucMember(id,"LowPart",	0X0,	0x20000400,	-1,	4);
	AddStrucMember(id,"HighPart",	0X4,	0x20000400,	-1,	4);
	
	id = GetStrucIdByName("_LARGE_INTEGER");
	AddStrucMember(id,"anonymous_0",	0X0,	0x60000400,	GetStrucIdByName("_LARGE_INTEGER_u"),	8);
	AddStrucMember(id,"u",	0X0,	0x60000400,	GetStrucIdByName("_LARGE_INTEGER_u"),	8);
	AddStrucMember(id,"QuadPart",	0X0,	0x30000400,	-1,	8);
	
	id = GetStrucIdByName("_PEB");
	AddStrucMember(id,"InheritedAddressSpace",	0X0,	0x000400,	-1,	1);
	AddStrucMember(id,"ReadImageFileExecOptions",	0X1,	0x000400,	-1,	1);
	AddStrucMember(id,"BeingDebugged",	0X2,	0x000400,	-1,	1);
	AddStrucMember(id,"SpareBool",	0X3,	0x000400,	-1,	1);
	AddStrucMember(id,"Mutant",	0X4,	0x25500400,	0XFFFFFFFF,	4);
	AddStrucMember(id,"ImageBaseAddress",	0X8,	0x25500400,	0XFFFFFFFF,	4);
	AddStrucMember(id,"Ldr",	0XC,	0x25500400,	0XFFFFFFFF,	4);
	SetMemberComment(id,	0XC,	"_PEB_LDR_DATA",	1);
	AddStrucMember(id,"ProcessParameters",	0X10,	0x25500400,	0XFFFFFFFF,	4);
	AddStrucMember(id,"SubSystemData",	0X14,	0x25500400,	0XFFFFFFFF,	4);
	AddStrucMember(id,"ProcessHeap",	0X18,	0x25500400,	0XFFFFFFFF,	4);
	AddStrucMember(id,"FastPebLock",	0X1C,	0x25500400,	0XFFFFFFFF,	4);
	AddStrucMember(id,"FastPebLockRoutine",	0X20,	0x25500400,	0XFFFFFFFF,	4);
	AddStrucMember(id,"FastPebUnlockRoutine",	0X24,	0x25500400,	0XFFFFFFFF,	4);
	AddStrucMember(id,"EnvironmentUpdateCount",	0X28,	0x20000400,	-1,	4);
	AddStrucMember(id,"KernelCallbackTable",	0X2C,	0x25500400,	0XFFFFFFFF,	4);
	AddStrucMember(id,"SystemReserved",	0X30,	0x20000400,	-1,	4);
	AddStrucMember(id,"AtlThunkSListPtr32",	0X34,	0x20000400,	-1,	4);
	AddStrucMember(id,"FreeList",	0X38,	0x25500400,	0XFFFFFFFF,	4);
	AddStrucMember(id,"TlsExpansionCounter",	0X3C,	0x20000400,	-1,	4);
	AddStrucMember(id,"TlsBitmap",	0X40,	0x25500400,	0XFFFFFFFF,	4);
	AddStrucMember(id,"TlsBitmapBits",	0X44,	0x20000400,	-1,	8);
	AddStrucMember(id,"ReadOnlySharedMemoryBase",	0X4C,	0x25500400,	0XFFFFFFFF,	4);
	AddStrucMember(id,"ReadOnlySharedMemoryHeap",	0X50,	0x25500400,	0XFFFFFFFF,	4);
	AddStrucMember(id,"ReadOnlyStaticServerData",	0X54,	0x25500400,	0XFFFFFFFF,	4);
	AddStrucMember(id,"AnsiCodePageData",	0X58,	0x25500400,	0XFFFFFFFF,	4);
	AddStrucMember(id,"OemCodePageData",	0X5C,	0x25500400,	0XFFFFFFFF,	4);
	AddStrucMember(id,"UnicodeCaseTableData",	0X60,	0x25500400,	0XFFFFFFFF,	4);
	AddStrucMember(id,"NumberOfProcessors",	0X64,	0x20000400,	-1,	4);
	AddStrucMember(id,"NtGlobalFlag",	0X68,	0x20000400,	-1,	4);
	AddStrucMember(id,"CriticalSectionTimeout",	0X6C,	0x60000400,	GetStrucIdByName("_LARGE_INTEGER"),	8);
	AddStrucMember(id,"HeapSegmentReserve",	0X74,	0x20000400,	-1,	4);
	AddStrucMember(id,"HeapSegmentCommit",	0X78,	0x20000400,	-1,	4);
	AddStrucMember(id,"HeapDeCommitTotalFreeThreshold",	0X7C,	0x20000400,	-1,	4);
	AddStrucMember(id,"HeapDeCommitFreeBlockThreshold",	0X80,	0x20000400,	-1,	4);
	AddStrucMember(id,"NumberOfHeaps",	0X84,	0x20000400,	-1,	4);
	AddStrucMember(id,"MaximumNumberOfHeaps",	0X88,	0x20000400,	-1,	4);
	AddStrucMember(id,"ProcessHeaps",	0X8C,	0x25500400,	0XFFFFFFFF,	4);
	AddStrucMember(id,"GdiSharedHandleTable",	0X90,	0x25500400,	0XFFFFFFFF,	4);
	AddStrucMember(id,"ProcessStarterHelper",	0X94,	0x25500400,	0XFFFFFFFF,	4);
	AddStrucMember(id,"GdiDCAttributeList",	0X98,	0x20000400,	-1,	4);
	AddStrucMember(id,"LoaderLock",	0X9C,	0x25500400,	0XFFFFFFFF,	4);
	AddStrucMember(id,"OSMajorVersion",	0XA0,	0x20000400,	-1,	4);
	AddStrucMember(id,"OSMinorVersion",	0XA4,	0x20000400,	-1,	4);
	AddStrucMember(id,"OSBuildNumber",	0XA8,	0x10000400,	-1,	2);
	AddStrucMember(id,"OSCSDVersion",	0XAA,	0x10000400,	-1,	2);
	AddStrucMember(id,"OSPlatformId",	0XAC,	0x20000400,	-1,	4);
	AddStrucMember(id,"ImageSubsystem",	0XB0,	0x20000400,	-1,	4);
	AddStrucMember(id,"ImageSubsystemMajorVersion",	0XB4,	0x20000400,	-1,	4);
	AddStrucMember(id,"ImageSubsystemMinorVersion",	0XB8,	0x20000400,	-1,	4);
	AddStrucMember(id,"ImageProcessAffinityMask",	0XBC,	0x20000400,	-1,	4);
	AddStrucMember(id,"GdiHandleBuffer",	0XC0,	0x20000400,	-1,	136);
	AddStrucMember(id,"PostProcessInitRoutine",	0X148,	0x25500400,	0XFFFFFFFF,	4);
	AddStrucMember(id,"TlsExpansionBitmap",	0X14C,	0x25500400,	0XFFFFFFFF,	4);
	AddStrucMember(id,"TlsExpansionBitmapBits",	0X150,	0x20000400,	-1,	128);
	AddStrucMember(id,"SessionId",	0X1D0,	0x20000400,	-1,	4);
	AddStrucMember(id,"AppCompatFlags",	0X1D4,	0x60000400,	GetStrucIdByName("_ULARGE_INTEGER"),	8);
	AddStrucMember(id,"AppCompatFlagsUser",	0X1DC,	0x60000400,	GetStrucIdByName("_ULARGE_INTEGER"),	8);
	AddStrucMember(id,"pShimData",	0X1E4,	0x25500400,	0XFFFFFFFF,	4);
	AddStrucMember(id,"AppCompatInfo",	0X1E8,	0x25500400,	0XFFFFFFFF,	4);
	AddStrucMember(id,"CSDVersion",	0X1EC,	0x60000400,	GetStrucIdByName("_UNICODE_STRING"),	8);
	AddStrucMember(id,"ActivationContextData",	0X1F4,	0x25500400,	0XFFFFFFFF,	4);
	AddStrucMember(id,"ProcessAssemblyStorageMap",	0X1F8,	0x25500400,	0XFFFFFFFF,	4);
	AddStrucMember(id,"SystemDefaultActivationContextData",	0X1FC,	0x25500400,	0XFFFFFFFF,	4);
	AddStrucMember(id,"SystemAssemblyStorageMap",	0X200,	0x25500400,	0XFFFFFFFF,	4);
	AddStrucMember(id,"MinimumStackCommit",	0X204,	0x20000400,	-1,	4);
	
	id = GetStrucIdByName("_LIST_ENTRY");
	AddStrucMember(id,"Flink",	0X0,	0x25500400,	0XFFFFFFFF,	4);
	SetMemberComment(id,	0X0,	"_LDR_MODULE",	1);
	AddStrucMember(id,"Blink",	0X4,	0x25500400,	0XFFFFFFFF,	4);
	SetMemberComment(id,	0X4,	"_LDR_MODULE",	1);
	
	id = GetStrucIdByName("_PEB_LDR_DATA");
	AddStrucMember(id,"Length",	0X0,	0x20000400,	-1,	4);
	AddStrucMember(id,"Initialized",	0X4,	0x20000400,	-1,	4);
	AddStrucMember(id,"SsHandle",	0X8,	0x25500400,	0XFFFFFFFF,	4);
	AddStrucMember(id,"InLoadOrderModuleList",	0XC,	0x60000400,	GetStrucIdByName("_LIST_ENTRY"),	8);
	SetMemberComment(id,	0XC,	"_LDR_MODULE",	1);
	AddStrucMember(id,"InMemoryOrderModuleList",	0X14,	0x60000400,	GetStrucIdByName("_LIST_ENTRY"),	8);
	SetMemberComment(id,	0X14,	"_LDR_MODULE",	1);
	AddStrucMember(id,"InInitializationOrderModuleList",	0X1C,	0x60000400,	GetStrucIdByName("_LIST_ENTRY"),	8);
	SetMemberComment(id,	0X1C,	"_LDR_MODULE",	1);
	AddStrucMember(id,"EntryInProgress",	0X24,	0x25500400,	0XFFFFFFFF,	4);
	
	id = GetStrucIdByName("IMAGE_DOS_HEADER");
	AddStrucMember(id,"e_magic",	0X0,	0x10000400,	-1,	2);
	SetMemberComment(id,	0X0,	"MZ",	1);
	AddStrucMember(id,"e_cblp",	0X2,	0x10000400,	-1,	2);
	AddStrucMember(id,"e_cp",	0X4,	0x10000400,	-1,	2);
	AddStrucMember(id,"e_crlc",	0X6,	0x10000400,	-1,	2);
	AddStrucMember(id,"e_cparhdr",	0X8,	0x10000400,	-1,	2);
	AddStrucMember(id,"e_minalloc",	0XA,	0x10000400,	-1,	2);
	AddStrucMember(id,"e_maxalloc",	0XC,	0x10000400,	-1,	2);
	AddStrucMember(id,"e_ss",	0XE,	0x10000400,	-1,	2);
	AddStrucMember(id,"e_sp",	0X10,	0x10000400,	-1,	2);
	AddStrucMember(id,"e_csum",	0X12,	0x10000400,	-1,	2);
	AddStrucMember(id,"e_ip",	0X14,	0x10000400,	-1,	2);
	AddStrucMember(id,"e_cs",	0X16,	0x10000400,	-1,	2);
	AddStrucMember(id,"e_lfarlc",	0X18,	0x10000400,	-1,	2);
	AddStrucMember(id,"e_ovno",	0X1A,	0x10000400,	-1,	2);
	AddStrucMember(id,"e_res",	0X1C,	0x10000400,	-1,	8);
	AddStrucMember(id,"e_oemid",	0X24,	0x10000400,	-1,	2);
	AddStrucMember(id,"e_oeminfo",	0X26,	0x10000400,	-1,	2);
	AddStrucMember(id,"e_res2",	0X28,	0x10000400,	-1,	20);
	AddStrucMember(id,"e_lfanew",	0X3C,	0x20000400,	-1,	4);
	SetMemberComment(id,	0X3C,	"_IMAGE_NT_HEADERS",	1);
	
	id = GetStrucIdByName("LIST_ENTRY");
	AddStrucMember(id,"Flink",	0X0,	0x25500400,	0XFFFFFFFF,	4);
	AddStrucMember(id,"Blink",	0X4,	0x25500400,	0XFFFFFFFF,	4);
	
	id = GetStrucIdByName("_TIB_u");
	AddStrucMember(id,"FiberData",	0X0,	0x25500400,	0XFFFFFFFF,	4);
	AddStrucMember(id,"Version",	0X0,	0x20000400,	-1,	4);
	
	id = GetStrucIdByName("_TIB");
	AddStrucMember(id,"ExceptionList",	0X0,	0x25500400,	0XFFFFFFFF,	4);
	AddStrucMember(id,"StackBase",	0X4,	0x25500400,	0XFFFFFFFF,	4);
	AddStrucMember(id,"StackLimit",	0X8,	0x25500400,	0XFFFFFFFF,	4);
	AddStrucMember(id,"SubSystemTib",	0XC,	0x25500400,	0XFFFFFFFF,	4);
	AddStrucMember(id,"anonymous_0",	0X10,	0x60000400,	GetStrucIdByName("_TIB_u"),	4);
	AddStrucMember(id,"ArbitraryUserPointer",	0X14,	0x25500400,	0XFFFFFFFF,	4);
	AddStrucMember(id,"SelfLinear",	0X18,	0x25500400,	0XFFFFFFFF,	4);
	AddStrucMember(id,"EnvPointer",	0X1C,	0x20000400,	-1,	4);
	AddStrucMember(id,"ProcessID",	0X20,	0x20000400,	-1,	4);
	AddStrucMember(id,"ThreadId",	0X24,	0x20000400,	-1,	4);
	AddStrucMember(id,"ActiveRPCHandle",	0X28,	0x20000400,	-1,	4);
	AddStrucMember(id,"Linear_TLS",	0X2C,	0x20000400,	-1,	4);
	AddStrucMember(id,"PebPtr",	0X30,	0x25500400,	0XFFFFFFFF,	4);
	SetMemberComment(id,	0X30,	"_PEB",	1);
	AddStrucMember(id,"LastError",	0X34,	0x20000400,	-1,	4);
	AddStrucMember(id,"CriticalSectionsCount",	0X38,	0x20000400,	-1,	4);
	AddStrucMember(id,"CsrClientThread",	0X3C,	0x20000400,	-1,	4);
	AddStrucMember(id,"Win32ThreadInfo",	0X40,	0x20000400,	-1,	4);
	AddStrucMember(id,"ClientInfo",	0X44,	0x000400,	-1,	124);
	AddStrucMember(id,"RsvdWoW32",	0XC0,	0x20000400,	-1,	4);
	AddStrucMember(id,"CurrentLocale",	0XC4,	0x20000400,	-1,	4);
	AddStrucMember(id,"FpSoftwareStatusReg",	0XC8,	0x20000400,	-1,	4);
	AddStrucMember(id,"Rsvd2",	0XCC,	0x20000400,	-1,	88);
	AddStrucMember(id,"KThreadPtr",	0X124,	0x20000400,	-1,	4);
	AddStrucMember(id,"field_128",	0X128,	0x20000400,	-1,	124);
	AddStrucMember(id,"ExceptionCode",	0X1A4,	0x20000400,	-1,	4);
	AddStrucMember(id,"ActivationCtxStack",	0X1A8,	0x20000400,	-1,	4);
	AddStrucMember(id,"field_1AC",	0X1AC,	0x20000400,	-1,	16);
	AddStrucMember(id,"sparebytes_nt",	0X1BC,	0x000400,	-1,	24);
	AddStrucMember(id,"ntdll_prvdata",	0X1D4,	0x000400,	-1,	40);
	AddStrucMember(id,"field_1FC",	0X1FC,	0x000400,	-1,	1248);
	AddStrucMember(id,"gdi_region",	0X6DC,	0x20000400,	-1,	4);
	AddStrucMember(id,"gdi_pen",	0X6E0,	0x20000400,	-1,	4);
	AddStrucMember(id,"gdi_brush",	0X6E4,	0x20000400,	-1,	4);
	AddStrucMember(id,"real_pid",	0X6E8,	0x20000400,	-1,	4);
	AddStrucMember(id,"real_tid",	0X6EC,	0x20000400,	-1,	4);
	AddStrucMember(id,"gdi_cached_process_handle",	0X6F0,	0x20000400,	-1,	4);
	AddStrucMember(id,"gdi_client_pid",	0X6F4,	0x20000400,	-1,	4);
	AddStrucMember(id,"gdi_client_tid",	0X6F8,	0x20000400,	-1,	4);
	AddStrucMember(id,"gdi_thread_local",	0X6FC,	0x20000400,	-1,	4);
	AddStrucMember(id,"Rsvd3",	0X700,	0x000400,	-1,	20);
	AddStrucMember(id,"rsvd_gl",	0X714,	0x000400,	-1,	1248);
	AddStrucMember(id,"LastStatusValue",	0XBF4,	0x20000400,	-1,	4);
	AddStrucMember(id,"rsvd_avapi32",	0XBF8,	0x000400,	-1,	214);
	AddStrucMember(id,"field_CCE",	0XCCE,	0x000400,	-1,	318);
	AddStrucMember(id,"ptr_deallocation_stack",	0XE0C,	0x20000400,	-1,	4);
	AddStrucMember(id,"tls_slots",	0XE10,	0x000400,	-1,	256);
	AddStrucMember(id,"tls_links",	0XF10,	0x60000400,	GetStrucIdByName("LIST_ENTRY"),	8);
	AddStrucMember(id,"vdm",	0XF18,	0x20000400,	-1,	4);
	AddStrucMember(id,"rsvd_rpc",	0XF1C,	0x20000400,	-1,	4);
	AddStrucMember(id,"field_F20",	0XF20,	0x000400,	-1,	8);
	AddStrucMember(id,"thread_error_mode",	0XF28,	0x20000400,	-1,	4);
	
	id = GetStrucIdByName("IMAGE_DATA_DIRECTORY");
	AddStrucMember(id,"VirtualAddress",	0X0,	0x20000400,	-1,	4);
	SetMemberComment(id,	0X0,	"(RVA)",	1);
	AddStrucMember(id,"Size",	0X4,	0x20000400,	-1,	4);
	
	id = GetStrucIdByName("IMAGE_DIRECTORY_ENTRY_EXPORT");
	AddStrucMember(id,"VirtualAddress",	0X0,	0x20000400,	-1,	4);
	SetMemberComment(id,	0X0,	"IMAGE_EXPORT_DIRECTORY (RVA)",	1);
	AddStrucMember(id,"Size",	0X4,	0x20000400,	-1,	4);
	
	id = GetStrucIdByName("IMAGE_DIRECTORY_ENTRY_IMPORT");
	AddStrucMember(id,"VirtualAddress",	0X0,	0x20000400,	-1,	4);
	SetMemberComment(id,	0X0,	"_IMAGE_IMPORT_DESCRIPTOR (RVA)",	1);
	AddStrucMember(id,"Size",	0X4,	0x20000400,	-1,	4);
	
	id = GetStrucIdByName("IMAGE_DIRECTORY_ENTRY_RESOURCE");
	AddStrucMember(id,"VirtualAddress",	0X0,	0x20000400,	-1,	4);
	SetMemberComment(id,	0X0,	"_IMAGE_RESOURCE_DIRECTORY (RVA)",	1);
	AddStrucMember(id,"Size",	0X4,	0x20000400,	-1,	4);
	
	id = GetStrucIdByName("IMAGE_DIRECTORY_ENTRY_DELAY_IMPORT");
	AddStrucMember(id,"VirtualAddress",	0X0,	0x20000400,	-1,	4);
	SetMemberComment(id,	0X0,	"_IMAGE_DELAY_IMPORT_DESCRIPTOR (RVA)",	1);
	AddStrucMember(id,"Size",	0X4,	0x20000400,	-1,	4);
	
	id = GetStrucIdByName("IMAGE_DIRECTORY_ENTRY_DEBUG");
	AddStrucMember(id,"VirtualAddress",	0X0,	0x20000400,	-1,	4);
	SetMemberComment(id,	0X0,	"_IMAGE_DEBUG_DIRECTORY (RVA)",	1);
	AddStrucMember(id,"Size",	0X4,	0x20000400,	-1,	4);
	
	id = GetStrucIdByName("IMAGE_DIRECTORY_ENTRY_TLS");
	AddStrucMember(id,"VirtualAddress",	0X0,	0x20000400,	-1,	4);
	SetMemberComment(id,	0X0,	"_IMAGE_TLS_DIRECTORY (RVA)",	1);
	AddStrucMember(id,"Size",	0X4,	0x20000400,	-1,	4);
	
	id = GetStrucIdByName("IMAGE_OPTIONAL_HEADER32");
	AddStrucMember(id,"Magic",	0X0,	0x10000400,	-1,	2);
	SetMemberComment(id,	0X0,	"010b",	1);
	AddStrucMember(id,"MajorLinkerVersion",	0X2,	0x000400,	-1,	1);
	AddStrucMember(id,"MinorLinkerVersion",	0X3,	0x000400,	-1,	1);
	AddStrucMember(id,"SizeOfCode",	0X4,	0x20000400,	-1,	4);
	AddStrucMember(id,"SizeOfInitializedData",	0X8,	0x20000400,	-1,	4);
	AddStrucMember(id,"SizeOfUninitializedData",	0XC,	0x20000400,	-1,	4);
	AddStrucMember(id,"AddressOfEntryPoint",	0X10,	0x20500400,	0XFFFFFFFF,	4);
	SetMemberComment(id,	0X10,	"(RVA)",	1);
	AddStrucMember(id,"BaseOfCode",	0X14,	0x20000400,	-1,	4);
	SetMemberComment(id,	0X14,	"(RVA)",	1);
	AddStrucMember(id,"BaseOfData",	0X18,	0x20000400,	-1,	4);
	SetMemberComment(id,	0X18,	"(RVA)",	1);
	AddStrucMember(id,"ImageBase",	0X1C,	0x20500400,	0XFFFFFFFF,	4);
	AddStrucMember(id,"SectionAlignment",	0X20,	0x20000400,	-1,	4);
	AddStrucMember(id,"FileAlignment",	0X24,	0x20000400,	-1,	4);
	AddStrucMember(id,"MajorOperatingSystemVersion",	0X28,	0x10000400,	-1,	2);
	SetMemberComment(id,	0X28,	"4/5",	1);
	AddStrucMember(id,"MinorOperatingSystemVersion",	0X2A,	0x10000400,	-1,	2);
	AddStrucMember(id,"MajorImageVersion",	0X2C,	0x10000400,	-1,	2);
	AddStrucMember(id,"MinorImageVersion",	0X2E,	0x10000400,	-1,	2);
	AddStrucMember(id,"MajorSubsystemVersion",	0X30,	0x10000400,	-1,	2);
	AddStrucMember(id,"MinorSubsystemVersion",	0X32,	0x10000400,	-1,	2);
	AddStrucMember(id,"Win32VersionValue",	0X34,	0x20000400,	-1,	4);
	AddStrucMember(id,"SizeOfImage",	0X38,	0x20000400,	-1,	4);
	AddStrucMember(id,"SizeOfHeaders",	0X3C,	0x20000400,	-1,	4);
	AddStrucMember(id,"CheckSum",	0X40,	0x20000400,	-1,	4);
	AddStrucMember(id,"Subsystem",	0X44,	0x10000400,	-1,	2);
	SetMemberComment(id,	0X44,	"1 driver/2 gui 3/cli",	1);
	AddStrucMember(id,"DllCharacteristics",	0X46,	0x10000400,	-1,	2);
	AddStrucMember(id,"SizeOfStackReserve",	0X48,	0x20000400,	-1,	4);
	AddStrucMember(id,"SizeOfStackCommit",	0X4C,	0x20000400,	-1,	4);
	AddStrucMember(id,"SizeOfHeapReserve",	0X50,	0x20000400,	-1,	4);
	AddStrucMember(id,"SizeOfHeapCommit",	0X54,	0x20000400,	-1,	4);
	AddStrucMember(id,"LoaderFlags",	0X58,	0x20000400,	-1,	4);
	AddStrucMember(id,"NumberOfRvaAndSizes",	0X5C,	0x20000400,	-1,	4);
	AddStrucMember(id,"Exports",	0X60,	0x60000400,	GetStrucIdByName("IMAGE_DIRECTORY_ENTRY_EXPORT"),	8);
	AddStrucMember(id,"Imports",	0X68,	0x60000400,	GetStrucIdByName("IMAGE_DIRECTORY_ENTRY_IMPORT"),	8);
	AddStrucMember(id,"Resources",	0X70,	0x60000400,	GetStrucIdByName("IMAGE_DIRECTORY_ENTRY_RESOURCE"),	8);
	AddStrucMember(id,"Exception",	0X78,	0x60000400,	GetStrucIdByName("IMAGE_DATA_DIRECTORY"),	8);
	AddStrucMember(id,"Security",	0X80,	0x60000400,	GetStrucIdByName("IMAGE_DATA_DIRECTORY"),	8);
	AddStrucMember(id,"BaseReloc",	0X88,	0x60000400,	GetStrucIdByName("IMAGE_DATA_DIRECTORY"),	8);
	AddStrucMember(id,"Debug",	0X90,	0x60000400,	GetStrucIdByName("IMAGE_DIRECTORY_ENTRY_DEBUG"),	8);
	AddStrucMember(id,"Copyright",	0X98,	0x60000400,	GetStrucIdByName("IMAGE_DATA_DIRECTORY"),	8);
	AddStrucMember(id,"GlobalPtr",	0XA0,	0x60000400,	GetStrucIdByName("IMAGE_DATA_DIRECTORY"),	8);
	AddStrucMember(id,"Tls",	0XA8,	0x60000400,	GetStrucIdByName("IMAGE_DIRECTORY_ENTRY_TLS"),	8);
	AddStrucMember(id,"LoadConfig",	0XB0,	0x60000400,	GetStrucIdByName("IMAGE_DATA_DIRECTORY"),	8);
	AddStrucMember(id,"BoundImport",	0XB8,	0x60000400,	GetStrucIdByName("IMAGE_DATA_DIRECTORY"),	8);
	AddStrucMember(id,"IAT",	0XC0,	0x60000400,	GetStrucIdByName("IMAGE_DATA_DIRECTORY"),	8);
	AddStrucMember(id,"DelayImport",	0XC8,	0x60000400,	GetStrucIdByName("IMAGE_DIRECTORY_ENTRY_DELAY_IMPORT"),	8);
	AddStrucMember(id,"ComDescriptor",	0XD0,	0x60000400,	GetStrucIdByName("IMAGE_DATA_DIRECTORY"),	8);
	
	id = GetStrucIdByName("IMAGE_FILE_HEADER");
	AddStrucMember(id,"Machine",	0X0,	0x10000400,	-1,	2);
	AddStrucMember(id,"NumberOfSections",	0X2,	0x10000400,	-1,	2);
	AddStrucMember(id,"TimeDateStamp",	0X4,	0x20000400,	-1,	4);
	AddStrucMember(id,"PointerToSymbolTable",	0X8,	0x20000400,	-1,	4);
	AddStrucMember(id,"NumberOfSymbols",	0XC,	0x20000400,	-1,	4);
	AddStrucMember(id,"SizeOfOptionalHeader",	0X10,	0x10000400,	-1,	2);
	AddStrucMember(id,"Characteristics",	0X12,	0x10000400,	-1,	2);
	
	id = GetStrucIdByName("IMAGE_NT_HEADERS");
	AddStrucMember(id,"Signature",	0X0,	0x20000400,	-1,	4);
	SetMemberComment(id,	0X0,	"PE\\0\\0",	1);
	AddStrucMember(id,"FileHeader",	0X4,	0x60000400,	GetStrucIdByName("IMAGE_FILE_HEADER"),	20);
	AddStrucMember(id,"OptionalHeader",	0X18,	0x60000400,	GetStrucIdByName("IMAGE_OPTIONAL_HEADER32"),	216);
	SetMemberComment(id,	0X18,	"IMAGE_OPTIONAL_HEADER32 / IMAGE_OPTIONAL_HEADER64",	1);
	
	id = GetStrucIdByName("IMAGE_OPTIONAL_HEADER64");
	AddStrucMember(id,"Magic",	0X0,	0x10000400,	-1,	2);
	SetMemberComment(id,	0X0,	"020b",	1);
	AddStrucMember(id,"MajorLinkerVersion",	0X2,	0x000400,	-1,	1);
	AddStrucMember(id,"MinorLinkerVersion",	0X3,	0x000400,	-1,	1);
	AddStrucMember(id,"SizeOfCode",	0X4,	0x20000400,	-1,	4);
	AddStrucMember(id,"SizeOfInitializedData",	0X8,	0x20000400,	-1,	4);
	AddStrucMember(id,"SizeOfUninitializedData",	0XC,	0x20000400,	-1,	4);
	AddStrucMember(id,"AddressOfEntryPoint",	0X10,	0x20000400,	-1,	4);
	AddStrucMember(id,"BaseOfCode",	0X14,	0x20000400,	-1,	4);
	AddStrucMember(id,"ImageBase",	0X18,	0x30000400,	-1,	8);
	AddStrucMember(id,"SectionAlignment",	0X20,	0x20000400,	-1,	4);
	AddStrucMember(id,"FileAlignment",	0X24,	0x20000400,	-1,	4);
	AddStrucMember(id,"MajorOperatingSystemVersion",	0X28,	0x10000400,	-1,	2);
	AddStrucMember(id,"MinorOperatingSystemVersion",	0X2A,	0x10000400,	-1,	2);
	AddStrucMember(id,"MajorImageVersion",	0X2C,	0x10000400,	-1,	2);
	AddStrucMember(id,"MinorImageVersion",	0X2E,	0x10000400,	-1,	2);
	AddStrucMember(id,"MajorSubsystemVersion",	0X30,	0x10000400,	-1,	2);
	AddStrucMember(id,"MinorSubsystemVersion",	0X32,	0x10000400,	-1,	2);
	AddStrucMember(id,"Win32VersionValue",	0X34,	0x20000400,	-1,	4);
	AddStrucMember(id,"SizeOfImage",	0X38,	0x20000400,	-1,	4);
	AddStrucMember(id,"SizeOfHeaders",	0X3C,	0x20000400,	-1,	4);
	AddStrucMember(id,"CheckSum",	0X40,	0x20000400,	-1,	4);
	AddStrucMember(id,"Subsystem",	0X44,	0x10000400,	-1,	2);
	AddStrucMember(id,"DllCharacteristics",	0X46,	0x10000400,	-1,	2);
	AddStrucMember(id,"SizeOfStackReserve",	0X48,	0x30000400,	-1,	8);
	AddStrucMember(id,"SizeOfStackCommit",	0X50,	0x30000400,	-1,	8);
	AddStrucMember(id,"SizeOfHeapReserve",	0X58,	0x30000400,	-1,	8);
	AddStrucMember(id,"SizeOfHeapCommit",	0X60,	0x30000400,	-1,	8);
	AddStrucMember(id,"LoaderFlags",	0X68,	0x20000400,	-1,	4);
	AddStrucMember(id,"NumberOfRvaAndSizes",	0X6C,	0x20000400,	-1,	4);
	AddStrucMember(id,"DataDirectory",	0X70,	0x60000400,	GetStrucIdByName("IMAGE_DATA_DIRECTORY"),	128);
	
	id = GetStrucIdByName("_LDR_MODULE");
	AddStrucMember(id,"InLoadOrderModuleList",	0X0,	0x60000400,	GetStrucIdByName("_LIST_ENTRY"),	8);
	SetMemberComment(id,	0X0,	"_LDR_MODULE",	1);
	AddStrucMember(id,"InMemoryOrderModuleList",	0X8,	0x60000400,	GetStrucIdByName("_LIST_ENTRY"),	8);
	AddStrucMember(id,"InInitializationOrderModuleList",	0X10,	0x60000400,	GetStrucIdByName("_LIST_ENTRY"),	8);
	AddStrucMember(id,"BaseAddress",	0X18,	0x25500400,	0XFFFFFFFF,	4);
	AddStrucMember(id,"EntryPoint",	0X1C,	0x25500400,	0XFFFFFFFF,	4);
	AddStrucMember(id,"SizeOfImage",	0X20,	0x20000400,	-1,	4);
	AddStrucMember(id,"FullDllName",	0X24,	0x60000400,	GetStrucIdByName("_UNICODE_STRING"),	8);
	AddStrucMember(id,"BaseDllName",	0X2C,	0x60000400,	GetStrucIdByName("_UNICODE_STRING"),	8);
	AddStrucMember(id,"Flags",	0X34,	0x20000400,	-1,	4);
	AddStrucMember(id,"LoadCount",	0X38,	0x10000400,	-1,	2);
	AddStrucMember(id,"TlsIndex",	0X3A,	0x10000400,	-1,	2);
	AddStrucMember(id,"HashTableEntry",	0X3C,	0x60000400,	GetStrucIdByName("_LIST_ENTRY"),	8);
	AddStrucMember(id,"TimeDateStamp",	0X44,	0x20000400,	-1,	4);
	return id;
}

//------------------------------------------------------------------------
// Information about structure types

static Structures(void) {
        auto id;
	id = Structures_0(id);
}

// End of file.
