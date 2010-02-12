; minimal hello world driver

%include '..\standard_hdr.asm'

IMAGEBASE EQU 10000H
SUBSYSTEM EQU IMAGE_SUBSYSTEM_NATIVE
CHARACTERISTICS EQU IMAGE_FILE_EXECUTABLE_IMAGE | IMAGE_FILE_32BIT_MACHINE

STATUS_DEVICE_CONFIGURATION_ERROR equ 0C0000182h

EntryPoint:
reloc1_1:
    push helloworld     ; PCHAR  Format
    call DbgPrint
    add esp, 4

    mov eax, STATUS_DEVICE_CONFIGURATION_ERROR
    retn 8

helloworld db "Hello World!", 0

reloc2_2:
;%IMPORT ntoskrnl.exe!DbgPrint
;%IMPORTS

;relocations start
DIRECTORY_ENTRY_BASERELOC:
base_reloc:
; relocation block start
    .VirtualAddress dd Section0Start - IMAGEBASE
    .SizeOfBlock dd base_reloc_size_of_block
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc1_1 + 1 - Section0Start)
    dw (IMAGE_REL_BASED_HIGHLOW << 12) | (reloc2_2 + 2 - Section0Start)
    base_reloc_size_of_block equ $ - base_reloc
;relocation block end

;relocations end

DIRECTORY_ENTRY_BASERELOC_SIZE equ $ - DIRECTORY_ENTRY_BASERELOC

%include '..\standard_ftr.asm'

; Ange Albertini 2009-2010