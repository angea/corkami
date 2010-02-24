%include '..\standard_hdr.asm'

EntryPoint:
    push 0                      ; BOOL bRebootAfterShutdown *fake*
    push MB_ICONINFORMATION     ; BOOL bForceAppsClosed
    push tada                   ; DWORD dwTimeout
    push helloworld             ; LPTSTR lpMessage
    push 0                      ; LPTSTR lpMachineName
    call InitiateSystemShutdownA
    add esp, 4

    push 0      ; LPCTSTR lpFileName
    call DeleteFileA

tada db "Tada!", 0
helloworld db "Hello World!", 0

;%IMPORT forwarder.dll!DeleteFileA
;%IMPORT forwarder.dll!InitiateSystemShutdownA

;%IMPORTS

%include '..\standard_ftr.asm'

;Ange Albertini, Creative Commons BY, 2010