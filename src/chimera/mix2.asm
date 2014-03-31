; a JPG/ZIP/PDF chimera
; (where all formats share the same image data)

; Ange Albertini, BSD Licence 2014

BITS 32
%include "../../doc/zip101/zip.inc"

; for JPEG segment lengths
%macro _dw 1
        db (%1 >> 8 * 1) & 0ffh
        db (%1 >> 8 * 0) & 0ffh
%endmacro

DATA_CRC32 equ 02a142635h

; header for JPG format
incbin 'jpg1-hdr.bin'

; 1st JPEG comment
db 0xff, 0xfe
    _dw JPGCMT_END1 - $

; PDF body
db '%PDF-1.4', 0ah
db 0ah

db '1 0 obj', 0ah
    db '<</Pages 2 0 R>>', 0ah
db 'endobj', 0ah
db 0ah

db '2 0 obj', 0ah
    db '<</Type /Pages /Count 1 /Kids [3 0 R]>>', 0ah
db 'endobj', 0ah
db 0ah

db '3 0 obj', 0ah
    db '<</Type /Page /Parent 2 0 R /MediaBox [0 0 400 400] /Contents 4 0 R /Resources<</XObject <</Im0 5 0 R>>>>>>', 0ah
db 'endobj', 0ah
db 0ah

db '4 0 obj', 0ah
db '<</Length 30>>', 0ah
db 'stream', 0ah
db 'q 400 0 0 400 0 0 cm /Im0 Do Q', 0ah
db 'endstream', 0ah
db 'endobj', 0ah
db 0ah

; let's start a dummy object for our ZIP start
db '20 0 obj', 0ah
db '<</Length 69786>>', 0ah
db 'stream', 0ah

localfile:
istruc filerecord
    at filerecord.frSignature,        db "PK", 3, 4
    at filerecord.frVersion,          dw 0ah
    at filerecord.frCompression,      dw COMP_STORED
    at filerecord.frCrc,              dd DATA_CRC32
    at filerecord.frCompressedSize,   dd DATA_SIZE
    at filerecord.frUncompressedSize, dd DATA_SIZE
    ;we'll use a fake filename so that our file data starts exactly with the PDF stream
    at filerecord.frFileNameLength,   dw JpgStart - FNStart
iend
FNStart:
db 'endstream', 0ah
db 'endobj', 0ah
db 0ah

; our JPG image object in the PDF

db '5 0 obj', 0ah
db '<</Width 400 /Height 400 /ColorSpace /DeviceRGB /Subtype /Image /Filter [/DCTDecode] /Type /XObject /BitsPerComponent 8>>', 0ah
db 'stream', 0ah

; we finish the ZIP filename, and start ZIP data with the PDF image
JpgStart:
incbin 'jpg1-hdr.bin'
    JPGCMT_END1

;now the JPEG comment is over - we include JPEG data

incbin 'jpg2-data.bin'
DATA_SIZE equ $ - JpgStart

; the 'real' JPEG is over, we resume and end the PDF
; 2nd JPEG comment, for ending the PDF
; (not required but more elegant)
db 0xff, 0xfe
    _dw JPGCMT_END2 - $

db 0ah, 'endstream', 0ah
db 'endobj', 0ah

; now another PDF dummy object, for the other ZIP structures
db 0ah
db '24 0 obj', 0ah
db 'stream', 0ah

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
filename db 'corkami.jpg'
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

db 0ah, 'endstream', 0ah
db 'endobj', 0ah
db 0ah

;dummy xref for increased compatibility
db 0ah
db 'xref', 0ah
db '0 1', 0ah
db '0000000000 65535 f', 0ah
db '0000000010 00000 n', 0ah

;actual trailers
db 0ah
db 'trailer', 0ah
db '<</Root 1 0 R>>', 0ah

;dummy EOF for compatibility
db 0ah
db 'startxref', 0ah
db '70488', 0ah
db '%%EOF', 0ah

    JPGCMT_END2

; (not required but more elegant)
db '%' ; PDF comment
db 0ffh, 0d9h ; JPG 2nd's EOI

    CMT_SIZE equ $ - CmtStart
