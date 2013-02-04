IMAGE_SCN_MEM_EXECUTE            equ 020000000h
IMAGE_SCN_MEM_WRITE              equ 080000000h

IMAGE_SIZEOF_SHORT_NAME equ 8

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

IMAGE_FILE_MACHINE_I386 equ 014ch
IMAGE_NT_OPTIONAL_HDR32_MAGIC equ 010bh

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

struc IMAGE_DATA_DIRECTORY_16
    .ExportsVA        resd 1
    .ExportsSize      resd 1
    .ImportsVA        resd 1
    .ImportsSize      resd 1
    .ResourceVA       resd 1
    .ResourceSize     resd 1
    .Exception        resd 2
    .Security         resd 2
    .FixupsVA         resd 1
    .FixupsSize       resd 1
    .DebugVA          resd 1
    .DebugSize        resd 1
    .Description      resd 2
    .MIPS             resd 2
    .TLSVA            resd 1
    .TLSSize          resd 1
    .Load             resd 2
    .BoundImportsVA   resd 1
    .BoundImportsSize resd 1
    .IATVA            resd 1
    .IATSize          resd 1
    .DelayImportsVA   resd 1
    .DelayImportsSize resd 1
    .COM              resd 2
    .reserved         resd 2
endstruc

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

IMAGE_SUBSYSTEM_WINDOWS_CUI    equ 3
IMAGE_SUBSYSTEM_WINDOWS_GUI    equ 2

IMAGE_FILE_EXECUTABLE_IMAGE        equ 00002h
IMAGE_FILE_32BIT_MACHINE           equ 00100h

%macro _ 0
    nop
%endmacro

%macro _c 0
    int3
    align 4, int3
%endmacro

%macro _d 0
    db 0
    align 16, db 0
%endmacro

struc IMAGE_IMPORT_DESCRIPTOR
    .OriginalFirstThunk resd 1 ; Characteristics
    .TimeDateStamp      resd 1
    .ForwarderChain     resd 1
    .Name1              resd 1
    .FirstThunk         resd 1
endstruc

%macro _import_descriptor 1
istruc IMAGE_IMPORT_DESCRIPTOR
    at IMAGE_IMPORT_DESCRIPTOR.OriginalFirstThunk, dd %1_hintnames - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.Name1             , dd %1 - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.FirstThunk        , dd %1_iat - IMAGEBASE
iend
%endmacro
