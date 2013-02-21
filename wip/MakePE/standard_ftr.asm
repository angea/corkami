;standard footer for a one-section source

SIZEOFCODE equ $ - base_of_code
align FILEALIGN,db 0

base_of_data:
SIZEOFINITIALIZEDDATA equ $ - base_of_data

uninit_data:
SIZEOFUNINITIALIZEDDATA equ $ - uninit_data

Section0Size EQU $ - Section0Start

SIZEOFIMAGE EQU $ - IMAGEBASE
