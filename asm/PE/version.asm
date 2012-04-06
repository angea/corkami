; a PE with version info (still broken)

; Ange Albertini, BSD LICENCE 2012

%include 'consts.inc'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; widechar string macro
%macro WIDE 1
%assign %%__i 1
%strlen %%__len %1
%rep %%__len
	%substr %%__c %1 %%__i
		db %%__c
		db 0
	%assign %%__i %%__i + 1
%endrep
	db 0, 0
%endmacro


%macro __string 2
%%string:
dw %%SLEN
dw %%VALLEN / 2 ; dammit !
dw 1 ; text type
WIDE %1
	align 4, db 0
%%val:
	WIDE %2
	%%VALLEN equ $ - %%val
	align 4, db 0
%%SLEN equ $ - %%string
%endmacro

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

IMAGEBASE equ 400000h

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
    at IMAGE_FILE_HEADER.Characteristics,       dw IMAGE_FILE_EXECUTABLE_IMAGE | IMAGE_FILE_32BIT_MACHINE
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

istruc IMAGE_DATA_DIRECTORY_16
;    at IMAGE_DATA_DIRECTORY_16.ImportsVA,   dd Import_Descriptor - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.ResourceVA, dd Directory_Entry_Resource - IMAGEBASE
    at IMAGE_DATA_DIRECTORY_16.ResourceSize, dd RESOURCE_SIZE
	
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section progbits vstart=IMAGEBASE + SECTIONALIGN align=FILEALIGN

;;    push eax
;;    call [__imp__printf]
;;    add esp, 1 * 4
;
;    push 0
;    call [__imp__ExitProcess]
;_c
;
;Import_Descriptor:
;;kernel32.dll_DESCRIPTOR:
;    dd kernel32.dll_hintnames - IMAGEBASE
;    dd 0, 0
;    dd kernel32.dll - IMAGEBASE
;    dd kernel32.dll_iat - IMAGEBASE
;;msvcrt.dll_DESCRIPTOR:
;    dd msvcrt.dll_hintnames - IMAGEBASE
;    dd 0, 0
;    dd msvcrt.dll - IMAGEBASE
;    dd msvcrt.dll_iat - IMAGEBASE
;;terminator
;    dd 0, 0, 0, 0, 0
;_d
;
;kernel32.dll_hintnames:
;    dd hnExitProcess - IMAGEBASE
;    dd 0
;msvcrt.dll_hintnames:
;    dd hnprintf - IMAGEBASE
;    dd 0
;_d
;
;hnExitProcess:
;    dw 0
;    db 'ExitProcess', 0
;hnprintf:
;    dw 0
;    db 'printf', 0
;_d
;
;kernel32.dll_iat:
;__imp__ExitProcess:
;    dd hnExitProcess - IMAGEBASE
;    dd 0
;
;msvcrt.dll_iat:
;__imp__printf:
;    dd hnprintf - IMAGEBASE
;    dd 0
;_d
;
;kernel32.dll db 'kernel32.dll', 0
;msvcrt.dll db 'msvcrt.dll', 0
;_d

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Directory_Entry_Resource:
; root directory
istruc IMAGE_RESOURCE_DIRECTORY
    at IMAGE_RESOURCE_DIRECTORY.NumberOfIdEntries, dw 1
iend
istruc IMAGE_RESOURCE_DIRECTORY_ENTRY
    at IMAGE_RESOURCE_DIRECTORY_ENTRY.NameID, dd RT_VERSION    ; .. resource type of that directory
    at IMAGE_RESOURCE_DIRECTORY_ENTRY.OffsetToData, dd IMAGE_RESOURCE_DATA_IS_DIRECTORY | (resource_directory_type - Directory_Entry_Resource)
iend

resource_directory_type:
istruc IMAGE_RESOURCE_DIRECTORY
    at IMAGE_RESOURCE_DIRECTORY.NumberOfIdEntries, dw 1
iend
istruc IMAGE_RESOURCE_DIRECTORY_ENTRY
    at IMAGE_RESOURCE_DIRECTORY_ENTRY.NameID, dd 1 ; name of the underneath resource
    at IMAGE_RESOURCE_DIRECTORY_ENTRY.OffsetToData, dd IMAGE_RESOURCE_DATA_IS_DIRECTORY | (resource_directory_language - Directory_Entry_Resource)
iend

resource_directory_language:
istruc IMAGE_RESOURCE_DIRECTORY
    at IMAGE_RESOURCE_DIRECTORY.NumberOfIdEntries, dw 1
iend
istruc IMAGE_RESOURCE_DIRECTORY_ENTRY
at IMAGE_RESOURCE_DIRECTORY_ENTRY.OffsetToData, dd resource_entry - Directory_Entry_Resource
iend

resource_entry:
istruc IMAGE_RESOURCE_DATA_ENTRY
    at IMAGE_RESOURCE_DATA_ENTRY.OffsetToData, dd resource_data - IMAGEBASE
    at IMAGE_RESOURCE_DATA_ENTRY.Size1, dd RESOURCE_SIZE
iend


resource_data:
VS_VERSION_INFO:
	.wLength dw VERSIONLENGTH
	.wValueLength dw VALUELENGTH
	.wType dw 0 ; 0 = bin, 1 = text
	WIDE 'VS_VERSION_INFO'
		align 4, db 0
	Value:
		istruc VS_FIXEDFILEINFO
			at VS_FIXEDFILEINFO.dwSignature, dd 0FEEF04BDh
			dd 10000h
		iend
	VALUELENGTH equ $ - Value
		align 4, db 0
	; children
	StringFileInfo:
		dw STRINGFILEINFOLEN
		dw 0 ; no value
		dw 0 ; type
		WIDE 'StringFileInfo'
			align 4, db 0
		; children
		StringTable:
			dw STRINGTABLELEN
			dw 0 ; no value
			dw 0
			WIDE '040904b0'
				align 4, db 0
			;children
			__string 'FileDescription', 'Test'

;StringFileInfo
;Comments
;CompanyName
;FileDescription
;FileVersion
;InternalName
;LegalCopyright
;LegalTrademarks
;OriginalFilename
;PrivateBuild
;ProductName
;ProductVersion
;SpecialBuild

		STRINGTABLELEN equ $ - StringTable
	STRINGFILEINFOLEN equ $ - StringFileInfo

	VarFileInfo:
		dw VARFILEINFOLENGTH
		dw 0 ; no value
		dw 0 ; type
		WIDE 'VarFileInfo'
			align 4, db 0
		; children
		Var1:
			dw VAR1LEN
			dw VAR1VALLEN
			dw 0
			WIDE 'Translation'
				align 4, db 0
			Var1Val:
				dd 04b00409h
			VAR1VALLEN equ $ - Var1Val
				align 4, db 0
		VAR1LEN equ $ - Var1
	VARFILEINFOLENGTH equ $ - VarFileInfo
VERSIONLENGTH equ $ - VS_VERSION_INFO

RESOURCE_SIZE equ $ - resource_data
_d

EntryPoint db 0c3h

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

align FILEALIGN, db 0
