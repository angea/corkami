; a 97-byte driver, PE (as small as possible), XP-only compatible

;Ange Albertini, BSD Licence, 2011

%include 'consts.inc'

IMAGEBASE equ 400000h

org IMAGEBASE

DOS_HEADER:
.e_magic       dw 'MZ'

align 4, db 0

istruc IMAGE_NT_HEADERS
    at IMAGE_NT_HEADERS.Signature, db 'PE',0,0
iend
istruc IMAGE_FILE_HEADER
    at IMAGE_FILE_HEADER.Machine,               dw IMAGE_FILE_MACHINE_I386
    ; we need to make sure it's not some crazy value in the NumbersOfSections, and the TimeStamp will fit the entrypoint code
    at IMAGE_FILE_HEADER.TimeDateStamp

bits 32
EntryPoint:
    mov eax, 0xC0000182; STATUS_DEVICE_CONFIGURATION_ERROR
    retn 8

    at IMAGE_FILE_HEADER.Characteristics,       dw IMAGE_FILE_EXECUTABLE_IMAGE | IMAGE_FILE_32BIT_MACHINE
iend

;specific to this file, a truncated Optional Header
struc TRUNC_OPTIONAL_HEADER32
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
  .Subsystem                    resb 1  ; truncated as a byte
  ; no more data
endstruc

istruc TRUNC_OPTIONAL_HEADER32
    at TRUNC_OPTIONAL_HEADER32.Magic,                     dw IMAGE_NT_OPTIONAL_HDR32_MAGIC
    at TRUNC_OPTIONAL_HEADER32.AddressOfEntryPoint,       dd EntryPoint - IMAGEBASE
    at TRUNC_OPTIONAL_HEADER32.ImageBase,                 dd IMAGEBASE
    at TRUNC_OPTIONAL_HEADER32.SectionAlignment,          dd 4       ; also sets e_lfanew
    at TRUNC_OPTIONAL_HEADER32.FileAlignment,             dd 4
    at TRUNC_OPTIONAL_HEADER32.MajorSubsystemVersion,     dw 4
    at TRUNC_OPTIONAL_HEADER32.SizeOfImage,               dd 2eh     ; can't be smaller
    at TRUNC_OPTIONAL_HEADER32.SizeOfHeaders,             dd 2ch     ; not necessary on all XP versions
    at TRUNC_OPTIONAL_HEADER32.CheckSum,                  dd 0e98Ch
    at TRUNC_OPTIONAL_HEADER32.Subsystem,                 db 1 ; IMAGE_SUBSYSTEM_NATIVE
iend
