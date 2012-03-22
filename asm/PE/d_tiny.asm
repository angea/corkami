; a tiny data PE
; Ange Albertini, BSD Licence, 2012

%include 'consts.inc'

istruc IMAGE_DOS_HEADER
    at IMAGE_DOS_HEADER.e_magic, db 'MZ'
NT_SIGNATURE:
	db 'PE'
    at IMAGE_DOS_HEADER.e_lfanew, dd NT_SIGNATURE
iend
