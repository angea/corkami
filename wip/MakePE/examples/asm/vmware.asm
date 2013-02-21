; vmware asm-based detections


; TODO better output
;CPUID Time
;GDT
;LDTR
;RedPill
;VmWare
;deroko
;ldtentries machin
;http://www.trapkit.de/research/vmm/scoopyng/ScoopyNG.zip

;Ange Albertini, BSD Licence, 2009-2011

%include '..\..\onesec.hdr'

EntryPoint:
    call inVMX
    call _sldt
    call _str
    call _sidt
    jmp good

inVMX:
    push next
    push dword [fs:0]
    mov [fs:0], esp

    mov eax, 'hXMV'                         ; YASM strings are not reversed
;    mov ebx, 0
    mov ecx, 10                             ; parameter to get the Version
    mov dx, 'XV'
    in eax, dx

                                            ; eax = version
    cmp ebx, 'hXMV'                         ; 'in eax' modified ebx :p
    jz bad
next:
    mov esp, [esp + 8]
    pop dword [fs:0]
    add esp, 4
    retn

_sldt:
    sldt [ldt]
    cmp word [ldt], 0
    jnz bad
    retn
ldt
    dd 0
    dw 0

_str:
    str [strdd]
    cmp word [strdd], 4000h
    jz bad
    retn
strdd dd 0

_sidt:
    sidt [__sidt]
    mov al, [__sidt + 5]
    cmp al, 0e8h
    jz bad
    cmp al, 0ffh
    jz bad
    retn

__sidt:
    dd 0
    dw 0

%include '..\goodbad.inc'

;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess

;%IMPORTS

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE
