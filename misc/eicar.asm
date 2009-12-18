; yasm -o eicar.com eicar.asm
KEY equ 097bh

%macro int_21 0  ; encrypted int 21
dw 021cdh + KEY
%endmacro

%macro int_20 0  ; encrypted int 20
dw 020cdh + KEY
%endmacro

org 100h    ; standard for .COM files but not used here.
bits 16

    pop     ax              ; xor ax, ax
    xor     ax, 214Fh
    push    ax
    and     ax, 4140h
    push    ax
    pop     bx              ; mov bx, skip_string (0140h)
    xor     al, 5Ch
    push    ax
    pop     dx              ; mov dx, aString (011ch)
    pop     ax
    xor     ax, 2834h       ; mov ax, KEY
    push    ax
    pop     si              ; mov si, KEY
    sub     [bx], si        ; sub [bx], si
    inc     bx              ; add bx, 2
    inc     bx
    sub     [bx], si        ; sub [bx], si
    jge     skip_string     ; jmp skip_string

aString db 'EICAR-STANDARD-ANTIVIRUS-TEST-FILE!', '$'

skip_string:
    int_21                  ; ah = 09  => display string at ds:dx = ds:aString
    int_20                  ; program terminate

; ; equivalent code
; ; bx, si are used for decryption
;
;org 100h
;    mov dx, aString
;    mov ah, 09h
;    int 021h
;    int 020h
;aString db 'EICAR-STANDARD-ANTIVIRUS-TEST-FILE!', '$'
