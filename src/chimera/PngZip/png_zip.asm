; a PNG/ZIP chimera
; a 41708 bytes PNG, as itself and as a ZIP containing itself, in a 41874 bytes file

; Ange Albertini BSD Licence 2014

;*******************************************************************************
; Png structures

%macro PNG_SIG 0
 db 89h, 'PNG', 0dh, 0ah, 1ah, 0ah
%endmacro

struc chunk
  .Length    resd 1
  .ChunkType resd 1
; .ChunkData resd ?
; .CRC       resd 1
endstruc

%macro _dd 1
 db (%1 >> 8 * 3) & 0ffh
 db (%1 >> 8 * 2) & 0ffh
 db (%1 >> 8 * 1) & 0ffh
 db (%1 >> 8 * 0) & 0ffh
%endmacro

struc IHDR
 .Width              resd 1
 .Height             resd 1
 .Bit_depth          resb 1
 .Color_type         resb 1
 .Compression_method resb 1
 .Filter_method      resb 1
 .Interlace_method   resb 1
endstruc

;*******************************************************************************
; zip structures

COMP_STORED equ 0

struc filerecord
    .frSignature        resb 4 ; db "PK", 3, 4
    .frVersion          resw 1
    .frFlags            resw 1
    .frCompression      resw 1
    .frFileTime         resw 1
    .frFileDate         resw 1
    .frCrc              resd 1
    .frCompressedSize   resd 1
    .frUncompressedSize resd 1
    .frFileNameLength   resw 1
    .frExtraFieldLength resw 1
    ;.frFileName        resb frFileNameLength
    ;.frExtraField      resb frExtraFieldLength
    ;.frData            resb frCompressedSize
endstruc

struc direntry
    .deSignature          resb 4 ; db "PK", 1, 2
    .deVersionMadeBy      resw 1
    .deVersionToExtract   resw 1
    .deFlags              resw 1
    .deCompression        resw 1
    .deFileTime           resw 1
    .deFileDate           resw 1
    .deCrc                resd 1
    .deCompressedSize     resd 1
    .deUncompressedSize   resd 1
    .deFileNameLength     resw 1
    .deExtraFieldLength   resw 1
    .deFileCommentLength  resw 1
    .deDiskNumberStart    resw 1
    .deInternalAttributes resw 1
    .deExternalAttributes resd 1
    .deHeaderOffset       resd 1
    ;.deFileName          resb deFileNameLength
    ;.deExtraField        resb deExtraFieldLength
    ;.deData              resb deCompressedSize
endstruc

struc endlocator
    .elSignature          resb 4 ;db "PK", 5, 6
    .elDiskNumber         resw 1
    .elStartDiskNumber    resw 1
    .elEntriesOnDisk      resw 1
    .elEntriesInDirectory resw 1
    .elDirectorySize      resd 1
    .elDirectoryOffset    resd 1
    .elCommentLength      resw 1
    ;.elComment           resb elCommentLength
endstruc

;*******************************************************************************

DATA_CRC32 equ 0960d7f8ch

BITS 32

;*******************************************************************************
; start with a valid PNG

%include 'png-hdr.asm'
_dd 0x71E3B900 ;IHDR CRC

;*******************************************************************************
; now let's start another chunk to cover the ZIP headers
istruc chunk
    at chunk.Length,   _dd CHUNK1_LEN
    at chunk.ChunkType, db 'lFhH'
iend
chunk1_start:

;*******************************************************************************
; we're now in our dummy chunk, we can start the ZIP headers

localfile:
istruc filerecord
    at filerecord.frSignature,        db "PK", 3, 4
    at filerecord.frVersion,          dw 0ah
    at filerecord.frCompression,      dw COMP_STORED
    at filerecord.frCrc,              dd DATA_CRC32
    at filerecord.frCompressedSize,   dd DATA_SIZE
    at filerecord.frUncompressedSize, dd DATA_SIZE
    at filerecord.frFileNameLength,   dw PngStart - FNStart
iend
FNStart:
; we could actually put genuine information here...

; placeholder to collide CRCs of Chunk1 with IHDR's (not strictly required)
db 0xD8, 0x49, 0xB5, 0xA9

PngStart:

;*******************************************************************************
; duplicate PNG header
%include 'png-hdr.asm'

;*******************************************************************************
;end of LFH's chunk
CHUNK1_LEN equ $ - chunk1_start
_dd 0x71E3B900 ;CRC32 for (2nd copy of) IHDR and Chunk1's

;*******************************************************************************
; Image Data

istruc chunk
    at chunk.Length,   _dd IDAT_LEN
    at chunk.ChunkType, db 'IDAT'
iend
;ChunkData
idat_start:
    incbin 'idat.bin' ; it's our data in an uncompressed ZLIB stream
    IDAT_LEN equ $ - idat_start
;IDAT CRC
_dd 0x8cfe37c8


; Image End
istruc chunk
    at chunk.Length,    dd 0
    at chunk.ChunkType, db 'IEND'
iend
;IEND CRC
_dd 0ae426082h
DATA_SIZE equ $ - PngStart

;*******************************************************************************
; our PNG is finished, let's create a 2nd chunk to cover remaining zip structures
; (not strictly required)

istruc chunk
    at chunk.Length,   _dd CHUNK2_LEN
    at chunk.ChunkType, db 'eOcD'
iend
chunk2_start:

;*******************************************************************************
; now the ZIP structures

central_directory:
istruc direntry
    at direntry.deSignature,        db "PK", 1, 2
    at direntry.deVersionToExtract, dw 0ah
    at direntry.deCrc,              dd DATA_CRC32
    at direntry.deCompressedSize,   dd DATA_SIZE
    at direntry.deUncompressedSize, dd DATA_SIZE
    at direntry.deFileNameLength,   dw FILENAME_LEN
    at direntry.deHeaderOffset,     dd localfile
iend
filename db 'corkami.png' ; the actual name, this time
    FILENAME_LEN equ $ - filename

CENTRAL_DIRECTORY_SIZE equ $ - central_directory

istruc endlocator
    at endlocator.elSignature,          db "PK", 5, 6
    at endlocator.elEntriesInDirectory, db 1
    at endlocator.elDirectorySize,      dd CENTRAL_DIRECTORY_SIZE
    at endlocator.elDirectoryOffset,    dd central_directory
    at endlocator.elCommentLength,      dw CMT_SIZE
iend
CmtStart:

;*******************************************************************************
; and the end of the 2nd extra chunk, as ZIP comment (not striclty required)

CHUNK2_LEN equ $ - chunk2_start
_dd 0xbc708add ; CRC32 of extra chunk
    CMT_SIZE equ $ - CmtStart
