# a generator for a PE with maximum number of section
# 199 sections confirmed working

SEC_NUMB = 199

SECTIONS_VSTART = 0x02000
f = open("max_sec.asm", "wt")

f.write("""; PE file with a maximum of sections

%include '..\..\consts.asm'

FILEALIGN equ 200h
SECTIONALIGN equ 1000h
org IMAGEBASE

istruc IMAGE_DOS_HEADER
    at IMAGE_DOS_HEADER.e_magic, db 'MZ'
    at IMAGE_DOS_HEADER.e_lfanew, dd nt_header - IMAGEBASE
iend

nt_header:
istruc IMAGE_NT_HEADERS
    at IMAGE_NT_HEADERS.Signature, db 'PE',0,0
iend
istruc IMAGE_FILE_HEADER
    at IMAGE_FILE_HEADER.Machine,               dw IMAGE_FILE_MACHINE_I386
    at IMAGE_FILE_HEADER.NumberOfSections,      dw NUMBEROFSECTIONS
    at IMAGE_FILE_HEADER.SizeOfOptionalHeader,  dw SIZEOFOPTIONALHEADER
    at IMAGE_FILE_HEADER.Characteristics,       dw CHARACTERISTICS
iend

OptionalHeader:
istruc IMAGE_OPTIONAL_HEADER32
    at IMAGE_OPTIONAL_HEADER32.Magic,                     dw IMAGE_NT_OPTIONAL_HDR32_MAGIC
    at IMAGE_OPTIONAL_HEADER32.AddressOfEntryPoint,       dd EntryPoint - IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.ImageBase,                 dd IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.SectionAlignment,          dd SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER32.FileAlignment,             dd FILEALIGN
    at IMAGE_OPTIONAL_HEADER32.MajorSubsystemVersion,     dw 4
    at IMAGE_OPTIONAL_HEADER32.SizeOfImage,               dd SIZEOFIMAGE
    at IMAGE_OPTIONAL_HEADER32.SizeOfHeaders,             dd SIZEOFHEADERS  ; can be 0 in some circumstances
    at IMAGE_OPTIONAL_HEADER32.Subsystem,                 dw IMAGE_SUBSYSTEM_WINDOWS_GUI
    at IMAGE_OPTIONAL_HEADER32.NumberOfRvaAndSizes,       dd NUMBEROFRVAANDSIZES
iend

DataDirectory:
istruc IMAGE_DATA_DIRECTORY2
    at ExportsVA,   dd Exports_Directory - IMAGEBASE
    at ImportsVA,   dd IMPORT_DESCRIPTOR - IMAGEBASE
iend

NUMBEROFRVAANDSIZES equ ($ - DataDirectory) / IMAGE_DATA_DIRECTORY_size

SIZEOFOPTIONALHEADER equ $ - OptionalHeader

SectionHeader:
""")

for i in xrange(SEC_NUMB):
    f.write("""istruc IMAGE_SECTION_HEADER
    at IMAGE_SECTION_HEADER.Name, db ".sec%(counter)02X",0
    at IMAGE_SECTION_HEADER.VirtualSize, dd SECTION%(counter)iVSIZE
    at IMAGE_SECTION_HEADER.VirtualAddress, dd Section%(counter)iStart - IMAGEBASE
    at IMAGE_SECTION_HEADER.SizeOfRawData, dd SECTION%(counter)iSIZE
    at IMAGE_SECTION_HEADER.PointerToRawData, dd %(pstart)08xh
    at IMAGE_SECTION_HEADER.Characteristics, dd IMAGE_SCN_MEM_EXECUTE ; necessary under Win7 (with DEP?)
iend
""" % {"counter":i, "pstart":(i * 0x200 + SECTIONS_VSTART)})

f.write(
"""
NUMBEROFSECTIONS equ ($ - SectionHeader) / IMAGE_SECTION_HEADER_size

align 400h, db 0
bits 32
EntryPoint equ 0c8000h + IMAGEBASE
""")

f.write("""
SECTION .0 align=200h valign=1000h
Section0PStart equ 0%(SECTIONS_VSTART)08Xh
SIZEOFHEADERS equ $ - IMAGEBASE
Section0Start:
    push MB_ICONINFORMATION ; UINT uType
    push tada               ; LPCTSTR lpCaption
    push helloworld         ; LPCTSTR lpText
    push 0                  ; HWND hWnd
    call MessageBoxA
    push 0                  ; UINT uExitCode
    call ExitProcess

tada db "Tada!", 0
helloworld db "Hello World!", 0

MessageBoxA:
    jmp [__imp__MessageBoxA]
VirtualAlloc:
    jmp [__imp__VirtualAlloc]
ExitProcess:
    jmp [__imp__ExitProcess]

ImportAddressTable:
;align 2, db 0
kernel32.dll_iat:

__imp__VirtualAlloc:
    DD hnVirtualAlloc - IMAGEBASE
__imp__ExitProcess:
    DD hnExitProcess - IMAGEBASE
    DD 0

;align 2, db 0
user32.dll_iat:

__imp__MessageBoxA:
    DD hnMessageBoxA - IMAGEBASE
    DD 0

IAT_size equ $ - ImportAddressTable
IMPORT_DESCRIPTOR: ; replace with imports:
kernel32.dll_DESCRIPTOR:
    dd kernel32.dll_hintnames - IMAGEBASE
    dd 0                                ; TimeDateStamp
    dd 0                                ; ForwarderChain
    dd kernel32.dll - IMAGEBASE              ; Name
    dd kernel32.dll_iat - IMAGEBASE          ; FirstThunk


user32.dll_DESCRIPTOR:
    dd user32.dll_hintnames - IMAGEBASE
    dd 0                                ; TimeDateStamp
    dd 0                                ; ForwarderChain
    dd user32.dll - IMAGEBASE              ; Name
    dd user32.dll_iat - IMAGEBASE          ; FirstThunk

    times 5 dd 0

HintNames:
;align 2, db 0
kernel32.dll_hintnames:
    DD hnVirtualAlloc - IMAGEBASE
    DD hnExitProcess - IMAGEBASE
    DD 0

;align 2, db 0
user32.dll_hintnames:
    DD hnMessageBoxA - IMAGEBASE
    DD 0

;align 2, db 0
hnVirtualAlloc:
    dw 0            ; Hint
    db 'VirtualAlloc',0  ; Name

;align 2, db 0
hnExitProcess:
    dw 0            ; Hint
    db 'ExitProcess',0  ; Name

;align 2, db 0
hnMessageBoxA:
    dw 0            ; Hint
    db 'MessageBoxA',0  ; Name

;align 2, db 0
kernel32.dll  DB 'kernel32.dll',0

;align 2, db 0
user32.dll  DB 'user32.dll',0

DIRECTORY_ENTRY_IMPORT_SIZE EQU $ - IMPORT_DESCRIPTOR

SECTION0VSIZE equ $ - Section0Start


end_:

align 200h, db 0
SECTION0SIZE equ $ - Section0Start
""" % locals())

for i in xrange(SEC_NUMB - 1):
    f.write("""Section%(counter)iStart equ %(RVA)i + IMAGEBASE
SECTION%(counter)iSIZE equ 0200h
SECTION%(counter)iVSIZE equ 1000h
jmp $ - 01000h

db 0h
align 200h, db 0
""" % {"counter":i + 1, "RVA": (i + 3)* 0x1000})
f.write("""
SIZEOFIMAGE equ %(sizeofimage)08Xh
;Ange Albertini, BSD Licence, 2011
""" % {"sizeofimage": SECTIONS_VSTART + SEC_NUMB * 0x1000})

f.close()
