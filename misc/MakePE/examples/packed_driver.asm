; minimal hello world driver, crypted

KEY equ 042h

%include '..\standard_hdr.asm'

;%DEFINE IMAGEBASE SUBSYSTEM CHARACTERISTICS

IMAGEBASE EQU 10000H
SUBSYSTEM EQU IMAGE_SUBSYSTEM_NATIVE
CHARACTERISTICS EQU IMAGE_FILE_EXECUTABLE_IMAGE | IMAGE_FILE_32BIT_MACHINE

EntryPoint:
    call decrypt
    nop
buffer:
incbin 'packed_driver.enc'
;    pushad
;nop
;nop
;    call $ + 5
;base:
;    pop ebp
;nop
;nop
;    lea eax, [ebp + helloworld - base]
;    lea ebx, [ebp + __imp__DbgPrint - base]
;    push eax            ; PCHAR  Format
;    call [ebx]          ; DbgPrint
;    add esp, 4     ; readjusting the stack
;nop
;nop
;    popad
;    mov eax, STATUS_DEVICE_CONFIGURATION_ERROR
;    retn 8
;align 16, db 0
;helloworld db "Hello World!", 0
;align 16, db 0

BUFFLEN equ $ - buffer
decrypt:
    pushad
nop
nop
    mov esi, [esp + 20h]
    inc esi
    mov edi, esi
    mov ecx, BUFFLEN
_loop:
    lodsb
    xor al, KEY
    stosb
    loop _loop
nop
nop
    popad
    retn
nop
nop
;%IMPORT ntoskrnl.exe!DbgPrint
;%IMPORTS

%include '..\standard_ftr.asm'

;Ange Albertini, Creative Commons BY, 2010