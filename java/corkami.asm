; a Java CLASS in assembly

; Ange Albertini, BSD Licence 2012

%macro GETSTATIC 1
        db 0b2h
        _dw %1
%endmacro

%macro LDC 1
        db 012h
        db %1
%endmacro

%macro INVOKEVIRTUAL 1
        db 0b6h
        _dw %1
%endmacro

%macro RETURN 0
        db 0b1h
%endmacro

%macro _dd 1
        db (%1 >> 8 * 3) & 0ffh
        db (%1 >> 8 * 2) & 0ffh
        db (%1 >> 8 * 1) & 0ffh
        db (%1 >> 8 * 0) & 0ffh
%endmacro

%macro _dw 1
        db (%1 >> 8 * 1) & 0ffh
        db (%1 >> 8 * 0) & 0ffh
%endmacro

%macro lbuffer 1
_dw %%end - 1 -$
        db %1
%%end:
%endmacro

%macro utf8 1
        db 1
        lbuffer %1
%endmacro

%macro nat 2
        db 0ch
        _dw %1
        _dw %2
%endmacro

%macro string 1
        db 8
        _dw %1
%endmacro

%macro classref 1
        db 7
        _dw %1
%endmacro

%macro fieldref 2
        db 9
        _dw %1
        _dw %2
%endmacro

%macro metref 2
        db 0ah
        _dw %1
        _dw %2
%endmacro

_dd 0CAFEBABEh ; signature
_dw  3         ; major version
_dw 2dh        ; minor version

_dw 018h       ;constant pool count
        nat 14h, 17h                     ; 01
        utf8 '([Ljava/lang/String;)V'    ; 02
        utf8 'java/lang/Object'          ; 03
        classref 3                       ; 04
        utf8 'Hello World!'              ; 05
        classref 10h                     ; 06
        utf8 ''                          ; 07
        utf8 'corkami'                   ; 08
        string 5                         ; 09
        classref 12h                     ; 0A
        utf8 'Code'                      ; 0B
        utf8 'main'                      ; 0C
        fieldref 0ah, 1                  ; 0D
        utf8 'SourceFile'                ; 0E
        nat 11h, 15h                     ; 0F
        utf8 'java/io/PrintStream'       ; 10
        utf8 'println'                   ; 11
        utf8 'java/lang/System'          ; 12
        metref 6, 0fh                    ; 13
        utf8 'out'                       ; 14
        utf8 '(Ljava/lang/String;)V'     ; 15
        classref 8                       ; 16
        utf8 'Ljava/io/PrintStream;'     ; 17
_dw 33  ;access_flag

_dw 16h ;this_class
_dw 4   ;superclass

_dw 0   ;interfaces_count
;fields_count
_dw 0
;methods_count
_dw 1
        _dw 9
        _dw 0ch
        _dw 2
        _dw 1
                _dw 0bh
                _dd 15h
                _dw 2
                _dw 1
                _dd 9
                        GETSTATIC 0dh
                        LDC 9
                        INVOKEVIRTUAL 13h
                        RETURN 
                _dd 0
;attributes_count 0
_dw 0
