;@echo off
;echo expected md5 6f6295e83222fb05887b0193097d2b6c
;yasm -o traceless.exe traceless.bat
;md5sum traceless.exe
;exit /B

; this is a 'rewrite' of Traceless' header (1k demo by TBC for Assembly 2012)
; with authorization from Mentor

; PE header dissection by Ange Albertini,  2012

; beautiful example of a PE header used extensively
; read in parallel with http://pferrie.host22.com/misc/pehdr.htm

; TODO: document the (un)packer part

IMAGEBASE EQU 400000h
TARGET EQU 410000h

org IMAGEBASE
bits 32

db 'MZ' ;fixed

aRa	db 'RA' ; ugly pun :p

aPe	db 'PE',0,0 ; Signature ; fixed
    dw 14Ch			; Machine ; fixed
    dw 0			; NumberOfSections ; controlled, better if 0

loc_01:
    bt	[dat], ebp	; timestamp ; fully controlled
    adc	esi, esi
    inc	ebp
    jmp	loc_04

    dw 8			; SizeOfOptionalHeader ; almost fixed
    dw 2			; characteristics ; almost fixed ; FILE_IS_EXECUTABLE
    dw 10Bh			; Magic ; fixed

loc_02:
    xor	ecx, ecx	; majorlinker ; fully controlled
    shr	bl, 1		; Code  ; fully controlled
    jb	l_91
    jnz	l_99 ; initData  ; fully controlled

loc_03:
    popa
    jnz	l_A1 ; unitialized data is in the middle ;  fully controlled
    inc	eax
    inc	edx
    mov	ebp, EntryPoint - IMAGEBASE	; bogus operation on EBP to encode EntryPoint ; very strict
    ror	byte [esi],	cl ; BaseCode  ; fully controlled
    jb	l_9D
    shr	edx, 1	 ; BaseData  ; fully controlled
    jmp l_9F

    dd IMAGEBASE ; IMAGEBASE ; very strict
    dd 4   ; SectionAlig ; very strict
    dd 4   ; FileAlig ; very strict ; also serves as DOS_HEADER.e_lfanew

loc_04:
    add eax, eax ; MajorOS ; fully controlled

l_46:
    test eax, eax ; MinorOS ; fully controlled
    jns loc_01 ; MajorImage ; fully controlled
    jmp l_54 ; MinorImage ; fully controlled ; intermediate jump to enable a short jump to l_CF

    dw 3   ; MajorSubsystemVersion  ; very strict
    dw 8000h  ; MinorSubsystemVersion ; strict
    dd 0   ; Win32VersionValue ; could be anything but would break D3D support :(

l_54:
    jmp l_CF ; SizeOfImage ; jmp encoded on the lower word
        dw 100h ; upper word of SizeOfImage

    dd 30h   ; SizeOfHeaders ; strict

l_5C:
    jle l_46 ; Checksum ; fully controlled
    pop eax
    retn

    dw 2   ; subsystem ; fixed
    dw 0   ; characteristics ; almost controlled

EntryPoint:
    nop   ; StackReserve ; almost controlled
    mov edi, TARGET ; stack commit ; almost controlled
    push 1
    pop eax  ; HeapReserve ; almost controlled
    push edi
    push 0
    pop esi  ; HeapCommit ; almost controlled
    push ebx
    push 0
    pop ebp ; loaderflag

l_75:
    push 8
    mov ecx, 0 ; B9 NumOfRVA - fixed to 0
    pop ecx

; from now on, values have no restriction except the debug directory's size
l_7D:
    push 4
    push 5
    mov edx, 5D7575DEh
    mov bl, 1Fh

l_88:
    pusha
    xor eax, eax
    cdq
    mov esi, [esp+2Ch]

l_90:
    pusha

l_91:
    mov al, [esi]
    shr al, cl
    xor al, [edi]
    jnz loc_03

l_99:
    dec esi
    dec edi
    jmp loc_02


l_9D:
    shr eax, 1

l_9F:
    rol byte [esi], cl

l_A1:
    inc esi
    cmp edi, esi
    jg l_90
    mov cl, 4

l_A8:
    add [esp+24h], edx
    test eax, eax
    nop
    mov ebp, 0  ; bogus operation to cover Debug datadirectory Size (has to be null no matter what)
    jz l_BC
    add [esp+20h], eax
    test edx, edx

l_BC:
    loope l_A8
    popa

l_BF:
    dec ebx
    add edx, edx
    jb l_88
    jnz l_BF
    pop ebx
    pop edx
    cmp di, 1492
    jmp l_5C

l_CF:
    add ebx, edx
    push eax
    mul edx
    div ebx
    pop edx
    cmp esi, eax
    jb l_E0
    xchg eax, edx
    sub esi, edx
    sub eax, edx

l_E0:
    rcl byte [edi], 1
    dec ecx
    jnz l_7D
    inc edi
    jmp l_75

dat db 032h, 036h, 071h, 017h, 084h, 0b7h, 025h, 027h, 05fh, 0bbh, 033h, 077h, 042h, 090h, 01eh, 02ah
    db 019h, 088h, 01eh, 058h, 0aeh, 049h, 0f8h, 01eh, 009h, 0a3h, 0c2h, 0bah, 097h, 070h, 0d7h, 03bh,
    db 094h, 03fh, 082h, 00ch, 00dh, 041h, 02ah, 03ah, 00ah, 028h, 099h, 073h, 0e7h, 035h, 027h, 0afh,
    db 02fh, 071h, 00ah, 0a3h, 047h, 00dh, 0ddh, 0e4h, 0b2h, 094h, 0f7h, 0dah, 0d7h, 091h, 01dh, 0dch,
    db 06bh, 077h, 022h, 092h, 041h, 067h, 073h, 038h, 0b4h, 047h, 09bh, 094h, 063h, 01eh, 036h, 052h,
    db 0c0h, 077h, 0efh, 0e1h, 032h, 0b4h, 0dfh, 08ch, 03ah, 0e4h, 025h, 0a3h, 00dh, 07ah, 0cfh, 0e6h,
    db 060h, 0b4h, 06ch, 0eeh, 065h, 016h, 039h, 09fh, 08eh, 0f3h, 098h, 027h, 086h, 036h, 037h, 04eh,
    db 06fh, 068h, 09eh, 032h, 0d4h, 0ceh, 086h, 002h, 04bh, 083h, 032h, 0afh, 0e0h, 0e6h, 05dh, 037h,
    db 048h, 090h, 072h, 0efh, 061h, 076h, 027h, 0afh, 031h, 0d7h, 0b9h, 0c0h, 07dh, 01eh, 036h, 09ah,
    db 0d9h, 0a6h, 039h, 0bbh, 044h, 028h, 07fh, 034h, 0f2h, 0bbh, 0a9h, 0b1h, 0cfh, 02fh, 05bh, 041h,
    db 09dh, 06ch, 076h, 0ceh, 005h, 0aah, 0b4h, 0d5h, 0f6h, 092h, 0f1h, 0e2h, 075h, 02dh, 07eh, 034h,
    db 0e4h, 097h, 036h, 07eh, 013h, 0ebh, 058h, 0b3h, 0b1h, 0eeh, 086h, 066h, 0ceh, 0f4h, 089h, 02eh,
    db 091h, 05eh, 02bh, 0aah, 05bh, 094h, 050h, 07ah, 076h, 0e9h, 08ah, 010h, 018h, 05fh, 028h, 072h,
    db 0b3h, 00ah, 04bh, 04eh, 059h, 01dh, 008h, 0fch, 0b1h, 04dh, 021h, 036h, 03fh, 057h, 087h, 0cfh,
    db 08dh, 0dah, 06fh, 06fh, 081h, 0b8h, 0d9h, 093h, 0f4h, 0f8h, 09dh, 0b7h, 0e7h, 0abh, 077h, 0c2h,
    db 01bh, 014h, 03ch, 0d2h, 048h, 01fh, 0b6h, 082h, 08dh, 027h, 0d9h, 0c5h, 088h, 0d3h, 095h, 01ah,
    db 084h, 077h, 04dh, 0b8h, 057h, 0d2h, 03bh, 006h, 0d8h, 0b8h, 001h, 0b8h, 090h, 0c6h, 0ddh, 033h,
    db 00ah, 04dh, 0c4h, 0edh, 0d1h, 0a7h, 0edh, 0ddh, 04ah, 06eh, 085h, 043h, 01eh, 076h, 0dah, 0c0h,
    db 0bbh, 0f6h, 0a3h, 04ah, 094h, 060h, 0a7h, 0e1h, 086h, 031h, 0e4h, 08fh, 0f3h, 099h, 085h, 04eh,
    db 045h, 021h, 017h, 0e8h, 010h, 066h, 00ah, 076h, 095h, 0ech, 02bh, 058h, 029h, 018h, 085h, 05ch,
    db 031h, 078h, 099h, 0ach, 0e2h, 000h, 0f5h, 04dh, 0c7h, 04eh, 042h, 063h, 06eh, 09bh, 09dh, 080h,
    db 095h, 092h, 008h, 0ceh, 069h, 0c7h, 0a5h, 000h, 06bh, 0f5h, 007h, 0b8h, 085h, 030h, 063h, 031h,
    db 057h, 053h, 06ah, 0f5h, 008h, 082h, 09dh, 0e5h, 0d2h, 013h, 057h, 0d9h, 034h, 0ceh, 0a2h, 0cch,
    db 00dh, 089h, 06bh, 00fh, 0efh, 0fbh, 04bh, 097h, 030h, 0cah, 0c4h, 037h, 056h, 0b4h, 049h, 060h,
    db 042h, 08ah, 00fh, 056h, 0bbh, 097h, 049h, 0e4h, 064h, 099h, 020h, 0bch, 07bh, 0edh, 01dh, 048h,
    db 0c8h, 05dh, 065h, 0beh, 038h, 05ch, 0bfh, 02eh, 099h, 076h, 0ebh, 0c5h, 0dch, 097h, 0b5h, 050h,
    db 095h, 08dh, 0f3h, 069h, 048h, 012h, 0b6h, 0a0h, 069h, 0c9h, 05eh, 0d7h, 04ch, 07ah, 0c3h, 0cbh,
    db 07eh, 0f1h, 03eh, 05bh, 0cfh, 0f3h, 0e3h, 068h, 071h, 0beh, 038h, 090h, 05bh, 087h, 01bh, 06fh,
    db 0e0h, 0e4h, 0a7h, 04dh, 05eh, 050h, 044h, 017h, 0cah, 0dah, 0ceh, 0c0h, 0a9h, 043h, 0a0h, 09fh,
    db 00dh, 0b6h, 014h, 0a5h, 020h, 0d4h, 0e9h, 03eh, 084h, 09ah, 0f8h, 012h, 0cah, 08ah, 0a4h, 0e7h,
    db 06ah, 060h, 0f9h, 08eh, 0ach, 05dh, 0e8h, 07dh, 0d1h, 040h, 0c1h, 0b1h, 0cch, 0eeh, 0d6h, 0edh,
    db 03fh, 050h, 009h, 08eh, 0c8h, 0f6h, 0ech, 0deh, 0fdh, 0a3h, 044h, 0ddh, 08bh, 085h, 051h, 00eh,
    db 029h, 03bh, 0d1h, 0d9h, 0cfh, 056h, 03fh, 066h, 027h, 018h, 0e2h, 0b8h, 065h, 092h, 0c6h, 0c7h,
    db 0d5h, 0abh, 06ah, 083h, 0adh, 048h, 080h, 017h, 06eh, 080h, 0bah, 0e4h, 0f1h, 072h, 034h, 0b1h,
    db 095h, 03fh, 014h, 06fh, 07bh, 065h, 0feh, 06ah, 091h, 0f6h, 086h, 032h, 060h, 0ffh, 026h, 0b9h,
    db 043h, 0e1h, 043h, 019h, 012h, 084h, 060h, 037h, 050h, 0c9h, 0d9h, 00bh, 002h, 002h, 083h, 095h,
    db 0ach, 0ebh, 0a0h, 0f7h, 06ah, 0adh, 0b7h, 06bh, 03ah, 06ch, 0e3h, 0fbh, 0e7h, 095h, 072h, 01dh,
    db 01eh, 0ceh, 057h, 054h, 0b4h, 0aeh, 021h, 0d0h, 00dh, 01bh, 0a4h, 0a9h, 08ah, 0e7h, 04ah, 04bh,
    db 020h, 08ah, 03bh, 088h, 072h, 043h, 0a2h, 096h, 092h, 052h, 016h, 0f8h, 0bbh, 0e6h, 08ah, 02bh,
    db 08fh, 0bdh, 010h, 04dh, 064h, 01ch, 013h, 078h, 05ch, 0bah, 0a5h, 075h, 081h, 02dh, 061h, 026h,
    db 0a8h, 03eh, 064h, 08fh, 061h, 03fh, 0e9h, 057h, 04eh, 0c0h, 0d2h, 03bh, 004h, 075h, 029h, 09bh,
    db 059h, 0c9h, 0bbh, 0feh, 0a0h, 0c6h, 074h, 016h, 000h, 0a6h, 07eh, 009h, 0e0h, 0beh, 0a0h, 06dh,
    db 044h, 086h, 07eh, 0b5h, 0f4h, 0b6h, 0d2h, 05ch, 01eh, 0c5h, 0b4h, 04fh, 00eh, 076h, 018h, 063h,
    db 027h, 0a3h, 0a1h, 078h, 068h, 06eh, 09bh, 041h, 06bh, 034h, 04dh, 093h, 05ah, 084h, 04ch, 0a7h,
    db 034h, 064h, 0f3h, 083h, 04bh, 0f0h, 028h, 06eh, 0d0h, 055h, 0a8h, 043h, 057h, 075h, 072h, 055h,
    db 0cch, 0d5h, 0b7h, 098h, 029h, 03ch, 065h, 037h, 0c0h, 04fh, 0d6h, 0efh, 0b8h, 087h, 04eh, 096h,
    db 06ah, 059h, 0b0h, 0c4h, 07eh, 00dh, 0b0h, 07ah, 030h, 0bch, 0fdh, 0e9h, 07bh, 00ch, 0deh, 03dh,
    db 0a7h, 091h, 06ah, 087h, 04bh, 071h, 0e2h, 08fh, 006h, 06ah, 0e7h, 049h, 014h, 0adh, 078h, 012h,
    db 016h, 092h, 02ah, 07bh, 03ch, 041h, 042h, 0b6h, 097h, 09bh, 054h, 021h, 0deh, 0fah, 03bh, 096h,
    db 01fh, 044h, 026h, 08dh, 095h, 001h
