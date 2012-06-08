ORIGIN equ 7c00h
NEWBASE equ 600h
MBRLEN equ 200h
SHORTLEN equ 100h
MARKER equ 0aa55h
sMARKER equ 055aah

BOOTABLE equ 80h
NONBOOTABLE equ 0

NTFS equ 7
FAT32 equ 0bh

struc PARTITION
	.state resb 1
	.CHSfirst resb 3
	.type resb 1
	.CHSlast resb 3
	.StartSector resd 1
	.Size resd 1
endstruc

org ORIGIN
bits 16
