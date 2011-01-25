; rc4-encrypted helloworld

%include '..\..\standard_hdr.asm'

%macro swap 3
    mov al, byte [%2 + %1]
    xchg al, byte [%3 + %1]
    mov byte [%2 + %1], al
%endmacro

EntryPoint:
    call decrypt
    nop
buffer:
    push MB_ICONINFORMATION ; UINT uType
    push tada               ; LPCTSTR lpCaption
    push helloworld         ; LPCTSTR lpText
    push 0                  ; HWND hWnd
    call MessageBoxA
nop
    push 0                  ; UINT uExitCode
    call ExitProcess
nop
tada db "Tada!", 0
helloworld db "Hello World!", 0

BUFFLEN equ $ - buffer
align 16, db 0
;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess

;%IMPORTS

decrypt:
    call init
    call shuffle
    call crypt
    retn

init:
    mov edi, state
    xor al, al

reset_loop:
    stosb                               ; S[i] = i

    inc al
    jnz reset_loop
    retn

shuffle:
    xor ecx, ecx                        ; i
    xor ebx, ebx                        ; j

shuffle_loop:
    movzx ax, cl                        ; j += key [i % keylen]
    div byte [keylen]                   ; let's hope the key is small :p
    movzx eax, ah
    add bl, byte [eax + keystream]

    add bl, byte [ecx + state]          ; j += S[i]

    swap state, ebx, ecx                ; swap S[j], S[i]

    inc cl
    jnz shuffle_loop
    retn

crypt:
    xor ecx, ecx                        ; i
    xor ebx, ebx                        ; j
    xor edx, edx                        ; b

    mov esi, buffer
    mov ebp, BUFFLEN
crypt_loop:
    inc cl                              ; i ++

    add bl, byte [ecx + state]          ; j += state[i]

    swap state, ebx, ecx                ; swap S[i], S[j]

    mov dl, byte [ebx + state]          ; b = S[S[i] + S[j]]
    add dl, byte [ecx + state]
    mov dl, byte [edx + state]

    xor byte [esi], dl                  ; cipher_char = plaintext_char ^ b
    inc esi

    dec ebp
    jnz crypt_loop
crypt_end:
    retn

align 16, db 0
    keystream db "Key"
        keylen dd $ - keystream
align 16, db 0
; for reference
;     plaintext db "Plaintext"
;         plaintext_len dd $ - plaintext
; align 16, db 0
;     ciphertext db 0bbh, 0f3h, 016h, 0e8h, 0d9h, 040h, 0afh, 00ah, 0d3h
align 16, db 0
    state times 256 db 0

    ; could just define it with:
    ; %assign i 0
    ; %rep    256
    ;         db i
    ; %assign i i+1
    ; %endrep

%include '..\..\standard_ftr.asm'

;Ange Albertini, Creative Commons BY, 2010
