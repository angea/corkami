; a 97-byte TinyPE file, but less defined information (sections removed, and minor stuff)

%include '..\..\consts.asm'
%define round(n, r) (((n+(r-1))/r)*r)   ; can't get that working under yasm, have to hardcode values :(

bits 32

SECTIONALIGN EQU 4
FILEALIGN EQU 4
IMAGEBASE equ 400000h

org IMAGEBASE

DOS_HEADER:
.e_magic       dw 'MZ'
times 2 db 0

NT_SIGNATURE:
    db 'PE',0,0
FILE_HEADER:
.Machine                dw IMAGE_FILE_MACHINE_I386
dw 0

EntryPoint:
    push byte 42
    pop eax
    ret
CODESIZE equ $ - EntryPoint

times 0ah db 0
.Characteristics        dw IMAGE_FILE_RELOCS_STRIPPED | IMAGE_FILE_EXECUTABLE_IMAGE| IMAGE_FILE_LINE_NUMS_STRIPPED | IMAGE_FILE_LOCAL_SYMS_STRIPPED | IMAGE_FILE_32BIT_MACHINE
OPTIONAL_HEADER:
.Magic                  dw IMAGE_NT_OPTIONAL_HDR32_MAGIC
times 14 db 0
.AddressOfEntryPoint    dd EntryPoint - IMAGEBASE
times 8 db 0
.ImageBase              dd IMAGEBASE
.SectionAlignment       dd SECTIONALIGN         ; wich defines also e_lfanew, to the right value
.FileAlignment          dd FILEALIGN
times 8 db 0
.MajorSubsystemVersion  dw 4
times 6 db 0
.SizeOfImage            dd 100 + 4  ;rounding not working
.SizeOfHeaders          dd 100      ;rounding not working - not necessary on all XP versions
times 4 db 0
.Subsystem              db IMAGE_SUBSYSTEM_WINDOWS_GUI ; shortened on a byte
SIZEOFHEADER equ $ - IMAGEBASE ; rounding not working

;Original TinyPE @ http://www.phreedom.org/solar/code/tinype/
;Ange Albertini, Creative Commons BY, 2010
