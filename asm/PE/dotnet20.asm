;a dissected compiled .NET 2.0 PE

; Ange Albertini BSD Licence 2012

; 623f6e8915fd0d02b2f72b2a4e63990b

%include 'consts.inc'
%include 'dotnet.inc'

CODEDELTA equ 200h - 2000h
RESDELTA equ 400h - 4000h + 200h

SECALIGN equ 2000h
FILEALIGN equ 200h

org 400000h

IMAGEBASE
istruc IMAGE_DOS_HEADER
  at IMAGE_DOS_HEADER.e_magic     , dw 'MZ'
  at IMAGE_DOS_HEADER.e_cblp      , dw 90h
  at IMAGE_DOS_HEADER.e_cp        , dw 3
  at IMAGE_DOS_HEADER.e_cparhdr   , dw 4
  at IMAGE_DOS_HEADER.e_maxalloc  , dw -1
  at IMAGE_DOS_HEADER.e_sp        , dw 0b8h
  at IMAGE_DOS_HEADER.e_lfarlc    , dw 40h
  at IMAGE_DOS_HEADER.e_lfanew    , dd PE_Header - IMAGEBASE
iend

bits 16
Dos_stub:
    push    cs
    pop     ds
    mov     dx, msg - Dos_stub
    mov     ah, 9
    int     21h
    mov     ax, 4C01h
    int     21h
msg db 'This program cannot be run in DOS mode.', 0Dh, 0Dh, 0Ah, '$', 0
align 16, db 0

bits 32

PE_Header
istruc IMAGE_NT_HEADERS
  at IMAGE_NT_HEADERS.Signature , db 'PE', 0, 0
iend
istruc IMAGE_FILE_HEADER
  at IMAGE_FILE_HEADER.Machine              , dw IMAGE_FILE_MACHINE_I386
  at IMAGE_FILE_HEADER.NumberOfSections     , dw 3
  at IMAGE_FILE_HEADER.TimeDateStamp        , dd 4f902380h ; Thu Apr 19 16:38:56 2012
  at IMAGE_FILE_HEADER.SizeOfOptionalHeader , dw 0e0h
  at IMAGE_FILE_HEADER.Characteristics      , dw 102h
iend
istruc IMAGE_OPTIONAL_HEADER32
  at IMAGE_OPTIONAL_HEADER32.Magic                        , dw IMAGE_NT_OPTIONAL_HDR32_MAGIC
  at IMAGE_OPTIONAL_HEADER32.MajorLinkerVersion           , db 8, 0
  at IMAGE_OPTIONAL_HEADER32.SizeOfCode                   , dd 2 * FILEALIGN
  at IMAGE_OPTIONAL_HEADER32.SizeOfInitializedData        , dd 3 * FILEALIGN
  at IMAGE_OPTIONAL_HEADER32.AddressOfEntryPoint          , dd EntryPoint - CODEDELTA - IMAGEBASE
  at IMAGE_OPTIONAL_HEADER32.BaseOfCode                   , dd _CorExeMain - CODEDELTA - IMAGEBASE
  at IMAGE_OPTIONAL_HEADER32.BaseOfData                   , dd resources - RESDELTA - IMAGEBASE
  at IMAGE_OPTIONAL_HEADER32.ImageBase                    , dd IMAGEBASE
  at IMAGE_OPTIONAL_HEADER32.SectionAlignment             , dd SECALIGN
  at IMAGE_OPTIONAL_HEADER32.FileAlignment                , dd FILEALIGN
  at IMAGE_OPTIONAL_HEADER32.MajorOperatingSystemVersion  , dw 4, 0
  at IMAGE_OPTIONAL_HEADER32.MajorSubsystemVersion        , dw 4, 0
  at IMAGE_OPTIONAL_HEADER32.SizeOfImage                  , dd 4 * SECALIGN
  at IMAGE_OPTIONAL_HEADER32.SizeOfHeaders                , dd FILEALIGN
  at IMAGE_OPTIONAL_HEADER32.Subsystem                    , dw IMAGE_SUBSYSTEM_WINDOWS_CUI
  at IMAGE_OPTIONAL_HEADER32.DllCharacteristics           , dw 8540h
  at IMAGE_OPTIONAL_HEADER32.SizeOfStackReserve           , dd 100000h
  at IMAGE_OPTIONAL_HEADER32.SizeOfStackCommit            , dd 1000h
  at IMAGE_OPTIONAL_HEADER32.SizeOfHeapReserve            , dd 100000h
  at IMAGE_OPTIONAL_HEADER32.SizeOfHeapCommit             , dd 1000h
  at IMAGE_OPTIONAL_HEADER32.NumberOfRvaAndSizes          , dd 10h
iend

istruc IMAGE_DATA_DIRECTORY_16
    at IMAGE_DATA_DIRECTORY_16.ImportsVA,   dd 22e4h, 57h
    at IMAGE_DATA_DIRECTORY_16.ResourceVA,  dd resources - RESDELTA - IMAGEBASE, 290h
    at IMAGE_DATA_DIRECTORY_16.FixupsVA,    dd 3 * SECALIGN, 0Ch
    at IMAGE_DATA_DIRECTORY_16.IATVA,       dd _CorExeMain - CODEDELTA - IMAGEBASE, 8
    at IMAGE_DATA_DIRECTORY_16.COM,         dd 2008h, 48h
iend

istruc IMAGE_SECTION_HEADER
    at IMAGE_SECTION_HEADER.Name                    , db '.text'
    at IMAGE_SECTION_HEADER.VirtualSize             , dd 344h
    at IMAGE_SECTION_HEADER.VirtualAddress          , dd _CorExeMain - CODEDELTA - IMAGEBASE
    at IMAGE_SECTION_HEADER.SizeOfRawData           , dd 2 * FILEALIGN
    at IMAGE_SECTION_HEADER.PointerToRawData        , dd FILEALIGN
    at IMAGE_SECTION_HEADER.Characteristics         , dd 60000020h
iend
istruc IMAGE_SECTION_HEADER
    at IMAGE_SECTION_HEADER.Name                    , db '.rsrc'
    at IMAGE_SECTION_HEADER.VirtualSize             , dd 290h
    at IMAGE_SECTION_HEADER.VirtualAddress          , dd 2 * SECALIGN
    at IMAGE_SECTION_HEADER.SizeOfRawData           , dd 2 * FILEALIGN
    at IMAGE_SECTION_HEADER.PointerToRawData        , dd 3 * FILEALIGN
    at IMAGE_SECTION_HEADER.Characteristics         , dd 40000040h
iend
istruc IMAGE_SECTION_HEADER
    at IMAGE_SECTION_HEADER.Name                    , db '.reloc'
    at IMAGE_SECTION_HEADER.VirtualSize             , dd 0ch
    at IMAGE_SECTION_HEADER.VirtualAddress          , dd 3 * SECALIGN
    at IMAGE_SECTION_HEADER.SizeOfRawData           , dd FILEALIGN
    at IMAGE_SECTION_HEADER.PointerToRawData        , dd 5 * FILEALIGN
    at IMAGE_SECTION_HEADER.Characteristics         , dd 42000040h
iend

align FILEALIGN, db 0

_CorExeMain db" #"
    align 8, db 0
;IMAGE_COR20_HEADER
    .size                    dd 48h
    .major                   dw 2
    .minor                   dw 5
    .MetaDataRVA             dd 2068h, 27Ch
    .Flags                   dd COMIMAGE_FLAGS_ILONLY
    .EntryPointToken         dd 6000001h
    .Resources               dd 0, 0
    .StrongNameSignature     dd 0,0
    .CodeManagerTable        dd 0,0
    .VTableFixups            dd 0,0
    .ExportAddressTableJumps dd 0,0
    .ManagedNativeHeader     dd 0,0

; bytecode
db 36h ; unknown ? length ?
db NOP_
db LDSTR, 1, 0, 0, 70h ;ldstr " * a .NET 2.0 PE"
db CALL_, 3, 0, 0, 0Ah ;call void [mscorlib]System.Console::WriteLine(string)
db NOP_
db RET_

db 1Eh ; unk ?
db LDARG_0
db CALL_, 4, 0, 0, 0Ah ; call instance void [mscorlib]System.Object::.ctor()
db RET_

dw 0

istruc MetadataHeader
    at MetadataHeader.Signature, db 'BSJB'
    at MetadataHeader.Major,     dw 1
    at MetadataHeader.Minor,     dw 1
    at MetadataHeader.Reserved,  dd 0
iend

    dd VERSIONLENGTH
Version:
	db 'v2.0.50727',0,0
	VERSIONLENGTH equ $ - Version

flags dw 0
NumbersOfStreams dw 5

	dd 6Ch, 0E4h
	db '#~',0
		align 4, db 0

	dd 150h, 0B4h
	db '#Strings',0
        align 4, db 0

	dd 204h, 24h
	db '#US',0
        align 4, db 0

	dd 228h, 10h
	db '#GUID',0
        align 4, db 0

	dd 238h, 44h
	db '#Blob',0
        align 4, db 0

istruc TablesHdr
    at TablesHdr.Reserved1       , dd 0
    at TablesHdr.MajorVersion    , db 2
    at TablesHdr.Minor           , db 0
    at TablesHdr.HeapOffsetSizes , db 0
    at TablesHdr.Reserved2       , db 1
    at TablesHdr.MaskValid       , dd 1447h, 9
    at TablesHdr.MaskSorted      , dd 3301FA00h, 1600h
iend

istruc Tables
    at Tables.ModuleCount          , dd 1
    at Tables.TypeRefCount         , dd 4
    at Tables.TypeDefCount         , dd 2
    at Tables.MethodCount          , dd 2
    at Tables.MemberRefCount       , dd 4
    at Tables.CustomAttributeCount , dd 2
    at Tables.AssemblyCount        , dd 1
    at Tables.AssemblyRefCount     , dd 1
iend

istruc sModule
    at sModule.Generation , dw 0
    at sModule.Name       , dw 0ah
    at sModule.Mvid       , dw 1
    at sModule.EncId      , dw 0
    at sModule.EncBaseID  , dw 0
iend

istruc TypeRef
    at TypeRef.ResolutionScope , dw 6
    at TypeRef.Name            , dw 2ch
    at TypeRef.Namespace       , dw 25h
iend
istruc TypeRef
    at TypeRef.ResolutionScope , dw 6
    at TypeRef.Name            , dw 5eh
    at TypeRef.Namespace       , dw 3eh
iend
istruc TypeRef
    at TypeRef.ResolutionScope , dw 6
    at TypeRef.Name            , dw 7eh
    at TypeRef.Namespace       , dw 3eh
iend
istruc TypeRef
    at TypeRef.ResolutionScope , dw 6
    at TypeRef.Name            , dw 9fh
    at TypeRef.Namespace       , dw 25h
iend

istruc TypeDef
    at TypeDef.Flags      , dd 0
    at TypeDef.Name       , dw 1
    at TypeDef.NameSpace  , dw 0
    at TypeDef.Extends    , dw 0
    at TypeDef.FieldList  , dw 1
    at TypeDef.MethodList , dw 1
iend
istruc TypeDef
    at TypeDef.Flags      , dd 100001h
    at TypeDef.Name       , dw 11h
    at TypeDef.NameSpace  , dw 0
    at TypeDef.Extends    , dw 5
    at TypeDef.FieldList  , dw 1
    at TypeDef.MethodList , dw 1
iend

istruc Method
    at Method.RVA       , dd 2050h
    at Method.ImplFlags , dw 0
    at Method.Flags_1   , dw 96h
    at Method.Name      , dw 33h
    at Method.Signature , dw 0ah
    at Method.ParamList , dw 1
iend
istruc Method
    at Method.RVA       , dd 205Eh
    at Method.ImplFlags , dw 0
    at Method.Flags_1   , dw 1886h
    at Method.Name      , dw 38h
    at Method.Signature , dw 0eh
    at Method.ParamList , dw 1
iend

istruc MemberRef
    at MemberRef.Class     , dw 11h
    at MemberRef.Name      , dw 38h
    at MemberRef.Signature , dw 12h
iend
istruc MemberRef
    at MemberRef.Class     , dw 19h
    at MemberRef.Name      , dw 38h
    at MemberRef.Signature , dw 0eh
iend
istruc MemberRef
    at MemberRef.Class     , dw 21h
    at MemberRef.Name      , dw 0a7h
    at MemberRef.Signature , dw 17h
iend
istruc MemberRef
    at MemberRef.Class     , dw 9h
    at MemberRef.Name      , dw 38h
    at MemberRef.Signature , dw 0eh
iend

istruc CustomAttribute
    at CustomAttribute.Parent , dw 2eh
    at CustomAttribute.Type   , dw 0bh
    at CustomAttribute.Value  , dw 1ch
iend
istruc CustomAttribute
    at CustomAttribute.Parent , dw 2eh
    at CustomAttribute.Type   , dw 13h
    at CustomAttribute.Value  , dw 25h
iend

istruc Assembly
    at Assembly.HashAlgId      , dd 8004h
    at Assembly.MajorVersion   , dw 0
    at Assembly.MinorVersion   , dw 0
    at Assembly.BuildNumber    , dw 0
    at Assembly.RevisionNumber , dw 0
    at Assembly.Flags          , dd 0
    at Assembly.PublicKey      , dw 0
    at Assembly.Name           , dw 9ch
    at Assembly.Culture        , dw 0
iend
istruc Assembly
    at Assembly.HashAlgId      , dd 2
    at Assembly.MajorVersion   , dw 0
    at Assembly.MinorVersion   , dw 0
    at Assembly.BuildNumber    , dw 0
    at Assembly.RevisionNumber , dw 0
    at Assembly.Flags          , dd 1C0001h
    at Assembly.PublicKey      , dw 0
    at Assembly.Name           , dw 0
    at Assembly.Culture        , dw 0
iend

align 4, db 0

Strings     db 0
aModule     db '<Module>',0
aHw_exe     db 'hw.exe',0
aHelloworld db 'HelloWorld',0
aMscorlib   db 'mscorlib',0
aSystem     db 'System',0
aObject     db 'Object',0
aMain       db 'Main',0
a_ctor      db '.ctor',0
aSystem_runtime_compile db 'System.Runtime.CompilerServices',0
aCompilationrelaxations db 'CompilationRelaxationsAttribute',0
aRuntimecompatibilityat db 'RuntimeCompatibilityAttribute',0
aHw           db 'hw',0
aConsole      db 'Console',0
aWriteline    db 'WriteLine',0

align 4, db 0


US dw 2100h
aA_net2_0Pe:
        WIDE " * a .NET 2.0 PE"

guid dd 0AC552BF4h, 4E97319Ch, 1D91D898h, 0D58F925Dh

blob_start db 0, 8
    publickeytoken db 0B7h, 7Ah, 5Ch, 56h, 19h, 34h, 0E0h, 89h,
    db 3,0,0
            db 1, 3, 20h, 0, 1, 4, 20h, 1, 1, 8, 4, 0, 1, 1
            db 0Eh, 8, 1, 0, 8, 0,0,0,0,0, 1Eh, 1, 0, 1, 0, 54h, 2
    aWrapnonexceptionthrows db 22,'WrapNonExceptionThrows'
blob_end    db 1


__IMPORT_DESCRIPTOR_mscoree:
istruc IMPORT_IMAGE_DESCRIPTOR
    at IMPORT_IMAGE_DESCRIPTOR.INT,     dd mscoreeINT - CODEDELTA - IMAGEBASE
    at IMPORT_IMAGE_DESCRIPTOR.DllName, dd aMscoree_dll - CODEDELTA - IMAGEBASE
    at IMPORT_IMAGE_DESCRIPTOR.IAT,     dd _CorExeMain - CODEDELTA - IMAGEBASE
iend
istruc IMPORT_IMAGE_DESCRIPTOR ;terminator
iend

mscoreeINT dd hn_CoreExeMain - IMAGEBASE - CODEDELTA
    dd 0
align 16, db 0

hn_CoreExeMain:
    dw 0
    db '_CorExeMain',0

aMscoree_dll db 'mscoree.dll',0
    align 4, db 0

    db 0,0

EntryPoint:
    jmp [_CorExeMain - CODEDELTA]

align 200h, db 0

resources:
res_root:
istruc IMAGE_RESOURCE_DIRECTORY
    at IMAGE_RESOURCE_DIRECTORY.Characteristics      , dd 0
    at IMAGE_RESOURCE_DIRECTORY.TimeDateStamp        , dd 0
    at IMAGE_RESOURCE_DIRECTORY.MajorVersion         , dw 0
    at IMAGE_RESOURCE_DIRECTORY.MinorVersion         , dw 0
    at IMAGE_RESOURCE_DIRECTORY.NumberOfNamedEntries , dw 0
    at IMAGE_RESOURCE_DIRECTORY.NumberOfIdEntries    , dw 1
iend
dd 10h, 80000000h + res_type - resources

res_type:
istruc IMAGE_RESOURCE_DIRECTORY
    at IMAGE_RESOURCE_DIRECTORY.Characteristics      , dd 0
    at IMAGE_RESOURCE_DIRECTORY.TimeDateStamp        , dd 0
    at IMAGE_RESOURCE_DIRECTORY.MajorVersion         , dw 0
    at IMAGE_RESOURCE_DIRECTORY.MinorVersion         , dw 0
    at IMAGE_RESOURCE_DIRECTORY.NumberOfNamedEntries , dw 0
    at IMAGE_RESOURCE_DIRECTORY.NumberOfIdEntries    , dw 1
iend
dd 1, 80000000h + res_lang - resources

res_lang:
istruc IMAGE_RESOURCE_DIRECTORY
    at IMAGE_RESOURCE_DIRECTORY.Characteristics      , dd 0
    at IMAGE_RESOURCE_DIRECTORY.TimeDateStamp        , dd 0
    at IMAGE_RESOURCE_DIRECTORY.MajorVersion         , dw 0
    at IMAGE_RESOURCE_DIRECTORY.MinorVersion         , dw 0
    at IMAGE_RESOURCE_DIRECTORY.NumberOfNamedEntries , dw 0
    at IMAGE_RESOURCE_DIRECTORY.NumberOfIdEntries    , dw 1
iend
dd 0, 48h
resource_data:
istruc IMAGE_RESOURCE_DATA_ENTRY
    at IMAGE_RESOURCE_DATA_ENTRY.OffsetToData, dd resource_start - IMAGEBASE - RESDELTA
    at IMAGE_RESOURCE_DATA_ENTRY.Size1, dd RES_LENGTH
iend

resource_start:
.length dw RES_LENGTH
dw 034h ; valuelength
dw 0 ; type bin
WIDE 'VS_VERSION_INFO'
    align 4, db 0
	Value:
		istruc VS_FIXEDFILEINFO
			at VS_FIXEDFILEINFO.dwSignature,      dd 0FEEF04BDh
            at VS_FIXEDFILEINFO.dwStrucVersion ,  dd 10000h
            at VS_FIXEDFILEINFO.dwFileFlagsMask , db 3Fh
            at VS_FIXEDFILEINFO.dwFileOS,         db 4
            at VS_FIXEDFILEINFO.dwFileType,       db 1
		iend
        dw 44h ; length
        dw 0 ; value length
        dw 1 ; type text
WIDE 'VarFileInfo'
    align 4, db 0
        dw 24h ; length
        dw 4h ; value length
        dw 0 ; type bin
WIDE 'Translation'
    align 4, db 0
        dd 4b0h << 16 + 0
        dw 194h
        dw 0
        dw 1
WIDE 'StringFileInfo'
        dw 170h
        dw 0
        dw 1
WIDE '000004b0'
__string 'FileDescription', ' '
__string 'FileVersion', '0.0.0.0'
__string 'InternalName', 'hw.exe'
__string 'LegalCopyright', ' '
__string 'OriginalFilename', 'hw.exe'
__string 'ProductVersion', '0.0.0.0'
__string 'Assembly Version', '0.0.0.0'

RES_LENGTH equ $ - resource_start

align 200h, db 0

Relocs
    block_start:
    dd 2000h ; rva
    dd BLOCKSIZE  ; size
        dw (IMAGE_REL_BASED_HIGHLOW << 12) | 2340h
        dw (IMAGE_REL_BASED_ABSOLUTE << 12) | 0
    BLOCKSIZE equ $ - block_start

align 200h, db 0
