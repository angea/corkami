; a tiny data PE
; Ange Albertini, BSD Licence, 2012

%include 'consts.inc'

db 'MZPE'
times 3ch - 4 db 0
db 2