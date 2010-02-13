; minimal hello world driver

%include '..\standard_hdr.asm'

IMAGEBASE EQU 10000H
SUBSYSTEM EQU IMAGE_SUBSYSTEM_NATIVE
CHARACTERISTICS EQU IMAGE_FILE_EXECUTABLE_IMAGE | IMAGE_FILE_32BIT_MACHINE

STATUS_DEVICE_CONFIGURATION_ERROR equ 0C0000182h

EntryPoint:
;%reloc 1
    push helloworld     ; PCHAR  Format
    call DbgPrint
    add esp, 4

    mov eax, STATUS_DEVICE_CONFIGURATION_ERROR
    retn 8

helloworld db "Hello World!", 0

;%reloc 2
;%IMPORT ntoskrnl.exe!DbgPrint
;%IMPORTS

;%relocs
%include '..\standard_ftr.asm'

; Ange Albertini, Creative Commons BY, 2009-2010