; small registers dumper

%include '../header.inc'

%macro printline 1
    push %1
    call printf
    add esp, 4
%endmacro

genregs:
    pusha
    pushf
    push %string:"Flags:%04X", 0dh, 0ah, "EDI:%08X ESI:%08X EBP:%08X ESP:%08X", 0dh, 0ah, "EBX:%08X EDX:%08X ECX:%08X EAX:%08X", 0dh, 0ah, 0
    call printf
    add esp, 10*4
    retn

print_upperbits:
    shr eax, 16
    movzx eax, ax
    push eax
    push %string:"%04X ", 0
    call printf
    add esp, 2 * 4
    retn

EntryPoint:
MB_ICONINFORMATION equ 040h
good:
    call genregs
    smsw eax
    push eax
    
    fnop
    smsw eax
    xchg [esp], eax
    push eax
    
    push %string:0dh, 0ah, "CR0(before):%08X  CR0(after):%08X ", 0dh, 0ah, 0
    call printf
    add esp, 3 * 4
_
    sidt [_sidt]
    sgdt [_sgdt]
    str eax
    push eax
    push dword [_sidt]  
    push dword [_sidt + 4]
    push dword [_sgdt]
    push dword [_sgdt + 4]
    push %string:"GDT:%02X%04X IDT:%02X%04X STR:%08X", 0dh, 0ah, 0
    call printf
    add esp, 6 * 4
    
    push eax
    push gs
    mov word [esp +2], 0
    push ss
    mov word [esp +2], 0
    push fs
    mov word [esp +2], 0
    push es
    mov word [esp +2], 0
    push ds
    mov word [esp +2], 0
    push cs
    mov word [esp +2], 0
    push %string:"CS:%04X DS:%04X ES:%04X FS:%04X SS:%04X GS:%04X", 0dh, 0ah, 0
    call printf
    add esp, 7 * 4

; dumping upper bits that are undefined and potentially different on pentium

    printline %string:0dh, 0ah, "upper bits (10 times):", 0dh, 0ah, 0
    printline %string:"Mov r32, sel", 0dh, 0ah,"   ", 0
    
    mov ecx, 10
movselloop:
    push ecx
    mov eax, ds
    call print_upperbits
    pop ecx
    loop movselloop

    push %string:0dh, 0ah, "sldt", 0dh, 0ah,"   ", 0
    call printf
    add esp, 4
    
    mov ecx, 10
sldtloop:
    push ecx
    sldt eax
    call print_upperbits
    pop ecx
    loop sldtloop

    push %string:0dh, 0ah, "smsw", 0dh, 0ah,"   ", 0
    call printf
    add esp, 4
    
    mov ecx, 10
smswloop:
    push ecx
    smsw eax
    call print_upperbits
    pop ecx
    loop smswloop

    push %string:0dh, 0ah, 0
    call printf
    add esp, 4

    
    mov byte [tls], 0c3h
    push 0
    call ExitProcess
_c

;%IMPORT msvcrt.dll!printf
;%IMPORT kernel32.dll!ExitProcess
_c

dd -1


tls:
    pusha
    pushf
    printline %string:"Register dumper 0.2 - Ange Albertini - BSD Licence 2011", 0dh, 0ah, 0dh, 0ah, 0
    printline %string:"TLS:", 0dh, 0ah, 0
    popf
    popa

    call genregs

    push %string:0dh, 0ah, "EntryPoint", 0dh, 0ah, 0
    call printf
    add esp, 4
    retn

Image_Tls_Directory32:
    StartAddressOfRawData dd Characteristics
    EndAddressOfRawData   dd Characteristics
    AddressOfIndex        dd Characteristics
    AddressOfCallBacks    dd SizeOfZeroFill
    SizeOfZeroFill        dd tls
    Characteristics       dd 0

_sidt dq 0
_sgdt dq 0
_d

;%IMPORTS
;%strings
SECTION0SIZE equ $ - Section0Start
SIZEOFIMAGE equ $ - IMAGEBASE
SUBSYSTEM equ 3
