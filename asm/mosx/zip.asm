; a working ZIP with a JAR and a minimalist MANIFEST.MF
; Ange Albertini, BSD licence 2012

CRC32class equ 0 
CRC32manifest equ 0

%macro __filename 0
db 'corkamosx.class'
%endmacro


header:
    db 'PK', 3, 4
    dw 0ah ; version_needed
    dw 0 ; flags
    dw 0 ; compression
    dd 0 ; LASTMOD
    dd 0 ; crc32
    dd 0 ; compressed size
    dd 0 ; uncompressed size
    dw DIRLEN
    dw 0 ; extra_length
    dir:
        db 'META-INF/'
    DIRLEN equ $ - dir

file1:
    db 'PK', 3, 4
    dw 0ah ; version_needed
    dw 0 ; flags
    dw 0 ; compression
    dd 0 ; LASTMOD
    dd CRC32manifest ; crc32
    dd FILESIZE1 ; compressed size
    dd FILESIZE1 ; uncompressed size
    dw FILENAMELEN1
    dw 0 ; extra_length
    filename1:
        db 'META-INF/MANIFEST.MF'
    FILENAMELEN1 equ $ - filename1

    data1:
        db 'Created-By: 1', 0dh, 0ah
        db 'Main-Class: corkamosx', 0dh, 0ah
    FILESIZE1 equ $ - data1

file2:
    db 'PK', 3, 4
    dw 0ah ; version_needed
    dw 0 ; flags
    dw 0 ; compression
    dd 0 ; LASTMOD
    dd CRC32class ; crc32
    dd FILESIZE2 ; compressed size
    dd FILESIZE2 ; uncompressed size
    dw FILENAMELEN2
    dw 0 ; extra_length
    filename2:
        __filename
    FILENAMELEN2 equ $ - filename2

    data2:
        %include 'class.asm'
    FILESIZE2 equ $ - data2

central_directory:
    db 'PK', 1, 2
    dw 014h ; version_made_by
    dw 0ah ; version_needed
    dw 0 ; flags
    dw 0 ; compression
    dd 0 ; last_mod time/date
    dd 0 ; crc32
    dd 0 ; compressed_size
    dd 0 ; uncompressed_size
    dw DIRLEN
    dw 0 ; extra_length
    dw 0 ; comment_length
    dw 0 ; disk_number_start
    dw 0   ; internal_attr
    dd 10h ; external_attr
    dd 0   ; offset_header
        db 'META-INF/'

    db 'PK', 1, 2
    dw 014h ; version_made_by
    dw 0ah ; version_needed
    dw 0 ; flags
    dw 0 ; compression
    dd 0 ; last_mod time/date
    dd CRC32manifest ; crc32
    dd FILESIZE1 ; compressed_size
    dd FILESIZE1 ; uncompressed_size
    dw FILENAMELEN1
    dw 0 ; extra_length
    dw 0 ; comment_length
    dw 0 ; disk_number_start
    dw 0   ; internal_attr
    dd 20h ; external_attr
    dd file1 - header  ; offset_header
        db 'META-INF/MANIFEST.MF'

    db 'PK', 1, 2
    dw 014h ; version_made_by
    dw 0ah ; version_needed
    dw 0 ; flags
    dw 0 ; compression
    dd 0 ; last_mod time/date
    dd CRC32class ; crc32
    dd FILESIZE2 ; compressed_size
    dd FILESIZE2 ; uncompressed_size
    dw FILENAMELEN2
    dw 0 ; extra_length
    dw 0 ; comment_length
    dw 0 ; disk_number_start
    dw 0   ; internal_attr
    dd 20h ; external_attr
    dd file2 - header ; offset_header
        __filename

end_central_directory:
    db 'PK', 5, 6
    number_disk dw 0
    number_disk2 dw 0
    total_number_disk dw 3
    total_number_disk2 dw 3
    dd end_central_directory - central_directory;size
    dd central_directory - header ;offset
    dw 0 ; comment_length
