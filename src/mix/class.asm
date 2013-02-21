; a Java CLASS in assembly

; Ange Albertini, BSD Licence 2012

%include 'java.inc'

_dd 0CAFEBABEh ; signature
_dw 3          ; major version
_dw 2dh        ; minor version

_dw 22        ;constant pool count
; this class
  classref 2                           ; 01
      utf8 'corkamix'                  ; 02
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
   utf8 '[java]'                       ; 15

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
        _dw 7   ; attributename: Code
        _dd 15h ; length
            _dw 2 ; maxlocals
            _dw 1 ; maxstack
            _dd 9 ; length of bytecode
                GETSTATIC 8
                LDC 14
                INVOKEVIRTUAL 16
                RETURN
            _dw 0 ; exceptions_count
            _dw 0 ; attributes_count

_dw 0 ;attributes_count
