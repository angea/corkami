; DLL mimicking basic ntoskrnl functionalities for execution of drivers in user mode

%include '..\standard_hdr.asm'

EntryPoint:
    retn 3 * 4

;%EXPORT DbgPrint
    mov ebx, [esp+4]        ; DbgPrint doesn't clear arguments from the stack
    push MB_ICONINFORMATION ; UINT uType
;%reloc 1
    push Driver             ; LPCTSTR lpCaption
;%reloc 1
    push ebx                ; LPCTSTR lpText
    push 0                  ; HWND hWnd
    call MessageBoxA
    retn                    ; doesn't pop out parameters

;%EXPORT ExAllocatePool
    push PAGE_READWRITE     ; DWORD flProtect
    push MEM_COMMIT         ; DWORD flAllocationType
    push dword [esp + 8]    ; SIZE_T dwSize
    push 0                  ; LPVOID lpAddress
    call VirtualAlloc
    retn 2 * 4

; not handling their parameters correctly yet
;%EXPORT IofCompleteRequest
;%EXPORT IoDeleteDevice
;%EXPORT IoDeleteSymbolicLink
    retn
;   retn 0 * 4

;%EXPORT KeCancelTimer
    retn 1 * 4

;%EXPORT KeInitializeTimerEx
;%EXPORT RtlInitUnicodeString
;%EXPORT MmPageEntireDriver
    retn 2 * 4

;%EXPORT KeInitializeDpc
    retn 3 * 4

;%EXPORT KeSetTimerEx
    retn 4 * 4

;%EXPORT IoCreateDevice
    retn 7 * 4

Driver db "User mode Ntoskrnl", 0

;%reloc 2
;%IMPORT user32.dll!MessageBoxA
;%IMPORT kernel32.dll!VirtualAlloc
;%IMPORTS

;%EXPORTS ntoskrnl.exe

;%relocs

%include '..\standard_ftr.asm'

;Ange Albertini, Creative Commons BY, 2010