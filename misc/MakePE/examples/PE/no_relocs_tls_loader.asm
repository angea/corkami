; Empty file with TLS in dll code.

%include '..\..\standard_hdr.asm'

EntryPoint:
    retn

;%IMPORT no_relocs.dll!Export

;%IMPORTS

Image_Tls_Directory32:
    StartAddressOfRawData dd Characteristics ; VA, should point to something null
    EndAddressOfRawData   dd Characteristics ; VA, should point to something null
    AddressOfIndex        dd Characteristics ; VA, should point to something null
    AddressOfCallBacks    dd Callbacks
    SizeOfZeroFill        dd 0
    Characteristics       dd 0

Callbacks:
    dd 330200h
    dd 0
DIRECTORY_ENTRY_TLS_SIZE EQU $ - Image_Tls_Directory32

%include '..\..\standard_ftr.asm'

; Ange Albertini, Creative Commons BY, 2009-2010