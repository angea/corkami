;standard:
    xor ebx, ebx
    mov ebx, [fs:030h]                    ; get a pointer to the PEB
    mov ebx, [ebx + 00Ch]                 ; get PEB->Ldr
    mov ebx, [ebx + 01Ch]                 ; get PEB->Ldr.InInitializationOrderModuleList.Flink (1st entry, ntdll)

    ; variant: esi instead of ebx, then LODSD here
    mov ebx, [ebx]                        ; get the next entry (2nd entry, kernel32.dll)
    mov ebx, [ebx + 008h]                 ; get the 2nd entries base address (kernel32.dll)

;windows7
    xor ebx, ebx
    mov ebx, [fs:030h]                    ; get a pointer to the PEB
    mov ebx, [ebx + 00Ch]                 ; get PEB->Ldr
    mov ebx, [ebx + 014h]                 ; get PEB->Ldr.InMemoryOrderModuleList.Flink (1st entry)
    mov ebx, [ebx]                        ; get the next entry (2nd entry)
    mov ebx, [ebx]                        ; get the next entry (3rd entry)
    mov ebx, [ebx + 010h]                 ; get the 3rd entries base address (kernel32.dll)

;by hash?
    cld ; clear the direction flag for the loop
    xor edx, edx ; zero edx

    mov edx, [fs:edx + 030h]                ; get a pointer to the PEB
    mov edx, [edx + 00Ch]                   ; get PEB->Ldr
    mov edx, [edx + 014h]                   ; get the first module from the InMemoryOrder module list
next_mod:
    mov esi, [edx + 028h]                   ; get pointer to modules name (unicode string)
    push byte 24                            ; push down the length we want to check
    pop ecx                                 ; set ecx to this length for the loop
    xor edi, edi                            ; clear edi which will store the hash of the module name
loop_modname:
    xor eax, eax                            ; clear eax
    lodsb                                   ; read in the next byte of the name
    cmp al, 'a'                             ; some versions of Windows use lower case module names
    jl not_lowercase
    sub al, 020h                            ; if so normalise to uppercase
not_lowercase:
    ror edi, 13                             ; rotate right our hash value
    add edi, eax                            ; add the next byte of the name to the hash
    loop loop_modname                       ; loop until we have read enough
    cmp edi, 06A4ABC5Bh                     ; compare the hash with that of KERNEL32.DLL
    mov ebx, [edx + 010h]                   ; get this modules base address
    mov edx, [edx]                          ; get the next module
    jne next_mod                            ; if it doesnt match, process the next module

; when we get here EBX is the kernel32 base (or change to suit).

;skypher solution since it changed after w7beta
    xor     ecx, ecx                        ; ecx = 0
    mov     esi, [fs:ecx + 030h]            ; esi = &(PEB) ([FS:0x30])
    mov     esi, [esi + 00ch]               ; esi = PEB->Ldr
    mov     esi, [esi + 01ch]               ; esi = PEB->Ldr.InInitOrder
next_module:
    mov     ebp, [esi + 008h]               ; ebp = InInitOrder[X].base_address
    mov     edi, [esi + 020h]               ; ebp = InInitOrder[X].module_name (unicode)
    mov     esi, [esi]                      ; esi = InInitOrder[X].flink (next module)
    cmp     [edi + 2*12], cl                ; modulename[12] == 0 ? ; for Win2k the register hast to be CX
    jne     next_module                     ; No: try next module.


;Dino Dai zovi

    xor   eax, eax
    add   eax, [fs:eax + 30h]
    js    method_9x

method_nt:
    mov   eax, [eax + 0ch]
    mov   esi, [eax + 1ch]
    lodsd
    mov   eax, [eax + 08h]
    jmp   kernel32_ptr_found

method_9x:
    mov   eax, [eax + 34h]
    lea   eax, [eax + 7ch]
    mov   eax, [eax + 3ch]
kernel32_ptr_found:
    mov     eax, [fs:30h]   ; PEB address
    mov     eax, [eax + 0ch]  ; PEB->PEB_LDR_DATA address
    mov     eax, [eax + 0ch]  ; InLoadOrderModuleList

    mov     ecx, 2

@repeat:
    mov  eax, [eax]
loop @repeat
    mov     eax, [eax + 18h]  ; Image Base of KERNEL32

    mov eax, [esp] ; Return address of call to CreateProcess
    and eax, 0FFFF1000h         ; the last four are zeros because
LoopAgain: ; Kernel32.dll is memory 64 aligned
    mov edx, [eax + 3Ch - 1000h]    ; the pointer is 32 bits by definition
    sub eax, 1000h ; rather then dec eax!!!
    cmp edx, 800h
    jae LoopAgain
    cmp eax, [eax + edx + 34h]
    jnz LoopAgain


    xor ebx,ebx
    mov ebx, [fs:ebx]
_1:
    cmp [ebx],-1
    jnz _2
    mov ebx,[ebx + 4]
    retn
_2:
    mov ebx,[ebx]
    jmp _1