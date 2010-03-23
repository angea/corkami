;TODO: nooby imports, numofrva, baseofcode

%include '..\..\onesec.hdr'

EntryPoint:
    call checkesi

    call fpucrash
    call delayed_fpucrash
    call DbgString
    jmp good

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
checkesi:
    cmp esi, -1
    jz bad
    retn
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

times 100 db 90h
fpucrash:
    fld tword [crashme]
    call fpuclean
    retn
crashme:
    dd -1, -1
    dw 0403dh

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

delayed_fpucrash:
    call patch
times 100 db 90h

    sub dword [patch + 2], 1
    call fpuclean
    retn

patch:
    fld tword [crashmefpu + 1]

times 100 db 90h
    add byte [crashmefpu], 1
    retn

crashmefpu dt 9.2233720368547758075e18 ; in Hex 403D FFFFFFFF FFFFFFFE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

fpuclean;
    fldz
    fldz
    fldz
    fldz
    fldz
    fldz
    fldz
    fldz
    retn

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DbgString:
    push _s_s
    call OutputDebugStringA
    retn

_s_s db "%s%s",0
;%IMPORT kernel32.dll!OutputDebugStringA

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


%include '..\goodbad.inc'

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess

tada db "Tada!", 0
helloworld db "Hello World!", 0

;%IMPORTS

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE

;Ange Albertini, Creative Commons BY, 2010
