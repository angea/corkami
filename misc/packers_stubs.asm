Aspack/Asprotect

EntryPoint:
    pusha
    call  _1
db 0E9h       ; E9 EB045D45 CALL <garbage>
    jmp   _2
_1:
    pop   ebp
    inc   ebp
    push  ebp
    retn

_2:
    call  _3
db 0EBh       ; EB54 JMP <garbage>

_3:
    pop   ebp

PECompact

EntryPoint:
    mov  eax, _1
    push eax
    push dword ptr fs:[0]
    mov  fs:[0], esp
    xor  eax, eax
    mov  [eax], ecx

[...]
_1:
    mov  eax, <random1>
    lea  ecx, [eax + <random2>]
    mov  [ecx + 1], eax
    mov  edx, [esp + 4]
    mov  edx, [edx + c]
    mov  byte ptr [edx], 0e9
    add  edx, 5
    sub  ecx, edx
    mov  [edx - 4], ecx
    xor  eax, eax
    retn

    mov  eax, 12345678
    pop  dword ptr fs:[0]
    add  esp, 4
    push ebp
    push ebx

FSG
EntryPoint:
    xchg  [_1], esp
    popad
    xchg  eax, esp
    push  ebp
_1:
    movsb
    mov   dh, 80
    call  [ebx]
    jnb   _1
    xor   ecx, ecx
    call  [ebx]

UPX
EntryPoint:
    pushad
    mov    esi, upx.<address>
    lea    edi, [esi + <negative>]
    push   edi
    or     ebp, ffffffff ; *
    jmp    $ + 12
    nop
    nop                  ; *
    nop                  ; *
    nop                  ; *
    nop                  ; *
    nop                  ; *
    mov    al, [esi]
    inc    esi
    mov    [edi], al

;* Not in UPX >3


MEW:
_1:
    mov  esi, <address>
    mov  ebx, esi
    lodsd
    lodsd
    push eax
    lodsd
    xchg eax, edi
    mov  dl, 80
_2:
    movsb
    mov  dh, 80
    call [ebx]
    jnb  _2
[...]

EntryPoint:
    jmp _1

Upack:
EntryPoint:
    mov  esi, <address>
    lodsd
    push eax
    push dword ptr [esi+34]
    jmp  short _1
[...]

_1:
    push dword ptr [esi+38]
    lodsd
    push eax
    mov  edi, [esi]
    mov  esi, <address2>


UPX with LZMA
EntryPoint:
    pushad
    mov   esi, <address>
    lea   edi, [esi + <negative>]
    push  edi
    mov   ebp, esp
    lea   ebx, [esp - 3E80]
    xor   eax, eax
_1:
    push  eax
    cmp   esp, ebx
    jnz   _1
    inc   esi
    inc   esi
    push  ebx
    push  0C478
    push  edi
    add   ebx, 4
    push  ebx
    push  534E
    push  esi
    add   ebx, 4
    push  ebx
    push  eax
    mov   dword ptr [ebx], 20003
    nop
    nop
    nop
    nop
    nop
    push  ebp
    push  edi
    push  esi
    push  ebx
    sub   esp, 7C
    mov   edx, [esp + 90]
