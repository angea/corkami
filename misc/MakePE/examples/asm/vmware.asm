;vmware asm-based detections
;CPUID Time
;GDT
;LDTR
;RedPill
;VmWare
;deroko
;ldtentries machin
;http://www.trapkit.de/research/vmm/scoopyng/ScoopyNG.zip

%include '../onesec.hdr'

EntryPoint:
    call inVMX
    call _sldt
    call _str
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

;    sidt [_sidt]
_sidt dt 0

%include 'goodbad.inc'
;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!ExitProcess

;%IMPORTS

SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE

;Ange Albertini, Creative Commons BY, 2009-2010
