; this EICAR file was created by Peter Ferrie @ http://pferrie.tripod.com/misc/eicar.htm

; like the original EICAR file, 
; it prints the official "EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$" string, 
; and is made of printable characters only.
;   5T2)D4)D65Z3PZEICAR-STANDARD-ANTIVIRUS-TEST-FILE!$UX!T!S

; this version is 12 bytes smaller than the original one, which means 18% smaller

; this version actually executes the EICAR string itself

; (but it actually doesn't do anything relevant for the actual execution itself:
; the higher part of BP already contains the correct value, used later in AX, and is left unmodified.)

; yasm -o eicar2.com eicar2.asm

KEY equ 3254h

%macro int_21 0  ; encrypted int 21
dw 021cdh + KEY
%endmacro

%macro int_20 0  ; encrypted int 20
dw 020cdh + KEY
%endmacro

org 100h    ; standard for .COM files but not used here.

bits 16
start:
        ; ax = 0 on start up
    xor ax, KEY
        ; => ax = KEY

        ; si = start = 100h on startup
    sub [si + (patches - start)], ax
    sub [si + (patches - start) + 2], ax

    xor ax, 335ah      ; 335ah = _string ^ KEY
        ; => ax = _string now

    push ax
    pop dx
        ; => dx = _string

; now the string EICAR itself is executed !
; the string is 'EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$'
_string:
        ; bp = 91ch on startup
    inc  bp         ; E
        ; 91dh
    dec  cx         ; I
    inc  bx         ; C
    inc  cx         ; A
    push dx         ; R
    sub  ax, 05453h ; -ST
    inc  cx         ; A
    dec  si         ; N
        ; => si = 0ffh
    inc  sp         ; D
    inc  cx         ; A
    push dx         ; R
    inc  sp         ; D
    sub  ax, 04E41h ; -AN
    push sp         ; T
    dec  cx         ; I
    push si         ; V
    dec  cx         ; I
    push dx         ; R
    push bp         ; U
    push bx         ; S
    sub  ax, 04554h ; -TE
    push bx         ; S
    push sp         ; T
    sub  ax, 04946h ; -FI
    dec  sp         ; L
    inc  bp         ; E
        ; bp = 091eh

        ; useless change at 0ffh
    and  [si], sp   ; !$

    push bp
    pop ax
        ; => ax = 091e (thus, ah = 09h)

patches:
    int_21
    int_20

; ; equivalent code
;
;org 100h
;    mov dx, aString
;    mov ah, 09h
;    int 021h
;    int 020h
;aString db 'EICAR-STANDARD-ANTIVIRUS-TEST-FILE!', '$'

; ASM rewrite done by Ange Albertini in 2011
