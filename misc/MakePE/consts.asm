
struc IMAGE_DOS_HEADER
  .e_magic      resw 1
  .e_cblp       resw 1
  .e_cp         resw 1
  .e_crlc       resw 1
  .e_cparhdr    resw 1
  .e_minalloc   resw 1
  .e_maxalloc   resw 1
  .e_ss         resw 1
  .e_sp         resw 1
  .e_csum       resw 1
  .e_ip         resw 1
  .e_cs         resw 1
  .e_lfarlc     resw 1
  .e_ovno       resw 1
  .e_res        resw 4
  .e_oemid      resw 1
  .e_oeminfo    resw 1
  .e_res2       resw 10
  .e_lfanew     resd 1
endstruc

struc IMAGE_NT_HEADERS
  .Signature         resd 1
;  .FileHeader        resb IMAGE_FILE_HEADER_size
;  .OptionalHeader    resb IMAGE_OPTIONAL_HEADER32_size
endstruc

struc IMAGE_FILE_HEADER
  .Machine              resw 1
  .NumberOfSections     resw 1
  .TimeDateStamp        resd 1
  .PointerToSymbolTable resd 1
  .NumberOfSymbols      resd 1
  .SizeOfOptionalHeader resw 1
  .Characteristics      resw 1
endstruc

;IMAGE_OPTIONAL_HEADER  equ  <IMAGE_OPTIONAL_HEADER32>
;IMAGE_THUNK_DATA EQU <IMAGE_THUNK_DATA32>
;IMAGE_TLS_DIRECTORY EQU <IMAGE_TLS_DIRECTORY32>

struc IMAGE_OPTIONAL_HEADER32
  .Magic                        resw 1
  .MajorLinkerVersion           resb 1
  .MinorLinkerVersion           resb 1
  .SizeOfCode                   resd 1
  .SizeOfInitializedData        resd 1
  .SizeOfUninitializedData      resd 1
  .AddressOfEntryPoint          resd 1
  .BaseOfCode                   resd 1
  .BaseOfData                   resd 1
  .ImageBase                    resd 1
  .SectionAlignment             resd 1
  .FileAlignment                resd 1
  .MajorOperatingSystemVersion  resw 1
  .MinorOperatingSystemVersion  resw 1
  .MajorImageVersion            resw 1
  .MinorImageVersion            resw 1
  .MajorSubsystemVersion        resw 1
  .MinorSubsystemVersion        resw 1
  .Win32VersionValue            resd 1
  .SizeOfImage                  resd 1
  .SizeOfHeaders                resd 1
  .CheckSum                     resd 1
  .Subsystem                    resw 1
  .DllCharacteristics           resw 1
  .SizeOfStackReserve           resd 1
  .SizeOfStackCommit            resd 1
  .SizeOfHeapReserve            resd 1
  .SizeOfHeapCommit             resd 1
  .LoaderFlags                  resd 1
  .NumberOfRvaAndSizes          resd 1
  .DataDirectory                resb 0
endstruc

struc IMAGE_DATA_DIRECTORY
  VirtualAddress    resd 1
  isize             resd 1
endstruc

struc IMAGE_DATA_DIRECTORY2
  ExportsVA   resd 1
  ExportsSize resd 1
  ImportsVA   resd 1
  ImportsSize resd 1
endstruc

IMAGE_SIZEOF_SHORT_NAME equ 8

struc IMAGE_SECTION_HEADER
    .Name                    resb IMAGE_SIZEOF_SHORT_NAME
    .VirtualSize             resd 1
    .VirtualAddress          resd 1
    .SizeOfRawData           resd 1
    .PointerToRawData        resd 1
    .PointerToRelocations    resd 1
    .PointerToLinenumbers    resd 1
    .NumberOfRelocations     resw 1
    .NumberOfLinenumbers     resw 1
    .Characteristics         resd 1
endstruc

struc IMAGE_IMPORT_DESCRIPTOR
    .OriginalFirstThunk  resd 1   ; Characteristics
    .TimeDateStamp       resd 1
    .ForwarderChain      resd 1
    .Name1               resd 1
    .FirstThunk          resd 1
endstruc

struc IMAGE_RESOURCE_DIRECTORY
    .Characteristics         resd 1
    .TimeDateStamp           resd 1
    .MajorVersion            resw 1
    .MinorVersion            resw 1
    .NumberOfNamedEntries    resw 1
    .NumberOfIdEntries       resw 1
endstruc

;struc IMAGE_RESOURCE_DIRECTORY_ENTRY
;    union
;        rName	RECORD NameIsString:1,NameOffset:31
;        Name1 dd ?
;        Id dw ?
;    ends
;    union
;        OffsetToData dd ?
;		  rDirectory	RECORD DataIsDirectory:1,OffsetToDirectory:31
;    ends
;endstruc
;
;struc IMAGE_IMPORT_BY_NAME
;    Hint    resw 1
;    Name1   resb ?
;IMAGE_IMPORT_BY_NAME ENDS
;
;struc IMAGE_THUNK_DATA32
;    union u1
;        ForwarderString dd  ?
;        Function dd         ?
;        Ordinal dd          ?
;        AddressOfData dd    ?
;    ends
;endstruc

struc IMAGE_TLS_DIRECTORY32
    StartAddressOfRawData   resd 1
    EndAddressOfRawData     resd 1
    AddressOfIndex          resd 1
    AddressOfCallBacks      resd 1
    SizeOfZeroFill          resd 1
    Characteristics         resd 1
endstruc

;Section characteristics
IMAGE_SCN_CNT_CODE               equ 000000020h
IMAGE_SCN_CNT_INITIALIZED_DATA   equ 000000040h
IMAGE_SCN_CNT_UNINITIALIZED_DATA equ 000000080h
IMAGE_SCN_LNK_OTHER              equ 000000100h
IMAGE_SCN_LNK_INFO               equ 000000200h
IMAGE_SCN_LNK_REMOVE             equ 000000800h
IMAGE_SCN_LNK_COMDAT             equ 000001000h
IMAGE_SCN_MEM_FARDATA            equ 000008000h
IMAGE_SCN_MEM_PURGEABLE          equ 000020000h
IMAGE_SCN_MEM_16BIT              equ 000020000h
IMAGE_SCN_MEM_LOCKED             equ 000040000h
IMAGE_SCN_MEM_PRELOAD            equ 000080000h
IMAGE_SCN_ALIGN_1BYTES           equ 000100000h
IMAGE_SCN_ALIGN_2BYTES           equ 000200000h
IMAGE_SCN_ALIGN_4BYTES           equ 000300000h
IMAGE_SCN_ALIGN_8BYTES           equ 000400000h
IMAGE_SCN_ALIGN_16BYTES          equ 000500000h
IMAGE_SCN_ALIGN_32BYTES          equ 000600000h
IMAGE_SCN_ALIGN_64BYTES          equ 000700000h
IMAGE_SCN_ALIGN_128BYTES         equ 000800000h
IMAGE_SCN_ALIGN_256BYTES         equ 000900000h
IMAGE_SCN_ALIGN_512BYTES         equ 000A00000h
IMAGE_SCN_ALIGN_1024BYTES        equ 000B00000h
IMAGE_SCN_ALIGN_2048BYTES        equ 000C00000h
IMAGE_SCN_ALIGN_4096BYTES        equ 000D00000h
IMAGE_SCN_ALIGN_8192BYTES        equ 000E00000h
IMAGE_SCN_ALIGN_MASK             equ 000F00000h
IMAGE_SCN_LNK_NRELOC_OVFL        equ 001000000h
IMAGE_SCN_MEM_DISCARDABLE        equ 002000000h
IMAGE_SCN_MEM_NOT_CACHED         equ 004000000h
IMAGE_SCN_MEM_NOT_PAGED          equ 008000000h
IMAGE_SCN_MEM_SHARED             equ 010000000h
IMAGE_SCN_MEM_EXECUTE            equ 020000000h
IMAGE_SCN_MEM_READ               equ 040000000h
IMAGE_SCN_MEM_WRITE              equ 080000000h

IMAGE_FILE_MACHINE_I386         equ 014ch

IMAGE_FILE_RELOCS_STRIPPED         equ 00001h
IMAGE_FILE_EXECUTABLE_IMAGE        equ 00002h
IMAGE_FILE_LINE_NUMS_STRIPPED      equ 00004h
IMAGE_FILE_LOCAL_SYMS_STRIPPED     equ 00008h
IMAGE_FILE_AGGRESIVE_WS_TRIM       equ 00010h
IMAGE_FILE_LARGE_ADDRESS_AWARE     equ 00020h
IMAGE_FILE_16BIT_MACHINE           equ 00040h
IMAGE_FILE_BYTES_REVERSED_LO       equ 00080h
IMAGE_FILE_32BIT_MACHINE           equ 00100h
IMAGE_FILE_DEBUG_STRIPPED          equ 00200h
IMAGE_FILE_REMOVABLE_RUN_FROM_SWAP equ 00400h
IMAGE_FILE_NET_RUN_FROM_SWAP       equ 00800h
IMAGE_FILE_SYSTEM                  equ 01000h
IMAGE_FILE_DLL                     equ 02000h
IMAGE_FILE_UP_SYSTEM_ONLY          equ 04000h
IMAGE_FILE_BYTES_REVERSED_HI       equ 08000h

IMAGE_SUBSYSTEM_NATIVE         equ 1
IMAGE_SUBSYSTEM_WINDOWS_GUI    equ 2
IMAGE_SUBSYSTEM_WINDOWS_CUI    equ 3

IMAGE_NT_OPTIONAL_HDR32_MAGIC equ 010bh

MB_ICONINFORMATION equ 040h
MB_ICONERROR equ 10h

;Ange Albertini 2009-2010
