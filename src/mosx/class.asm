; a Hello World Java CLASS in YASM
; Ange Albertini, BSD Licence 2012

%include 'java.inc'

_dd 0CAFEBABEh ; signature
_dw 3          ; major version
_dw 2dh        ; minor version

_dw 22        ;constant pool count
; this class
  classref 2                           ; 01
      utf8 'corkamosx'                ; 02
; super class
  classref 4                           ; 03
      utf8 'java/lang/Object'          ; 04
; method name
  utf8 'main'                          ; 05
; method type
  utf8 '([Ljava/lang/String;)V'        ; 06
; attribute name
  utf8 'Code'                          ; 07

; getstatic
  fieldref 9, 11                       ; 08
      classref 10                      ; 09
          utf8 'java/lang/System'      ; 10
      nat 12, 13                       ; 11
          utf8 'out'                   ; 12
          utf8 'Ljava/io/PrintStream;' ; 13

; LDC
  string 15                            ; 14
   utf8 'CorkaM-OsX [Java]'            ; 15

; InvokeVirtual
  metref 17, 19                        ; 16
      classref 18                      ; 17
          utf8 'java/io/PrintStream'   ; 18
      nat 20, 21                       ; 19
          utf8 'println'               ; 20
          utf8 '(Ljava/lang/String;)V' ; 21


_dw 1  ;access_flag: public

_dw 1 ;this class
_dw 3 ;super class

_dw 0 ; interfaces_count

_dw 0 ; fields_count

_dw 1 ; methods_count
    _dw 9  ; flags: public, static
    _dw 5  ; methodname: 'main'
    _dw 6  ; return type: ([Ljava/lang/String;)V
    _dw 1  ; attribute_count
        _dw 7        ; attributename: Code
        _dd CODE_LEN ; length
        _code:
            _dw 2 ; maxlocals
            _dw 1 ; maxstack
            _dd BC_LEN ; length of bytecode
            bc:
                GETSTATIC 8
                LDC 14
                INVOKEVIRTUAL 16
                RETURN
            BC_LEN equ $ - bc
            _dw 0 ; exceptions_count
            _dw 0 ; attributes_count
        CODE_LEN equ $ - _code

_dw 0 ;attributes_count
