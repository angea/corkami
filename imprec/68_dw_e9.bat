;GOTO Batch:
;Adapted from ImportReconstructor TeLock Example (c) MackT/uCF
;Add your code and run this .bat
;
; this one catches 0x68 PUSH <apiVA> / 0xe9 JMP <apichecker&loader>
;
;Ange 10/2007
; #########################################################################

    .386
    .model flat, stdcall
    option casemap :none   ; case sensitive

; #########################################################################

    include \masm32\include\windows.inc
    include \masm32\include\user32.inc
    include \masm32\include\kernel32.inc

    includelib \masm32\lib\user32.lib
    includelib \masm32\lib\kernel32.lib

; #########################################################################

.code

; ##########################################################################

LibMain proc hInstDLL:DWORD, reason:DWORD, unused:DWORD

    ret

LibMain Endp

; Exported function to use
;
; Parameters:
; -----------
; <hFileMap>    : HANDLE of the mapped file
; <dwSizeMap>   : Size of that mapped file
; <dwTimeOut>   : TimeOut of ImpREC in Options
; <dwToTrace>   : Pointer to trace (in VA)
; <dwExactCall> : EIP of the exact call (in VA)
;
; Returned value (in eax):
; ------------------------
; Use a value greater or equal to 200. It will be shown by ImpREC if no output were created

; ##########################################################################

Trace proc hFileMap:DWORD, dwSizeMap:DWORD, dwTimeOut:DWORD, dwToTrace:DWORD, dwExactCall:DWORD

    LOCAL dwPtrOutput : DWORD
    LOCAL dwErrorCode : DWORD

    push ebx

    ; Map the view of the file (3rd parameter : 6 = FILE_MAP_READ | FILE_MAP_WRITE)
    invoke MapViewOfFile, hFileMap, 6, 0, 0, 0
    test eax, eax
    jnz map_ok

    mov eax, 201                ; Can't map the view
    pop ebx
    ret

map_ok:

    mov dwPtrOutput, eax                ; Get the returned address of the mapped file

    cmp dwSizeMap, 4
    jae map_ok2;

    mov dwErrorCode, 203                ; Invalid map size
    jmp end2

map_ok2:

    ; Check if the given pointer to trace is a valid address
    ; ------------------------------------------------------

    mov ebx, dwToTrace
    invoke IsBadReadPtr, ebx, 4
    test eax, eax
    jz ptr_ok1

    mov dwErrorCode, 205                ; Invalid pointer
    jmp end2

ptr_ok1:

    ; add your code here.
    ; Check if we have a push [XXXXXXXX] at this pointer to trace address (opcode: 0FFh, 035H)
    ; ----------------------------------------------------------------------------------------

    cmp byte ptr[ebx], 068h
    jnz end_ok
    cmp byte ptr[ebx+5], 0e9h
    jnz end_ok

    ; Check if this [XXXXXXXX] is a valid address
    ; -------------------------------------------

    mov ebx, [ebx+1]
    invoke IsBadReadPtr, ebx, 4
    test eax, eax
    jz ptr_ok2

    mov dwErrorCode, 205                ; Invalid pointer
    jmp end2

ptr_ok2:

    ; Now write in the mapped file the found pointer
    ; ----------------------------------------------
    mov eax, dwPtrOutput;
    mov [eax], ebx;

end_ok:

    mov dwErrorCode, 200                ; All seems to be OK

end2:
    invoke UnmapViewOfFile, dwPtrOutput ; Unmap the view
    invoke CloseHandle, hFileMap;       ; Close the handle of the mapped file
    mov eax, dwErrorCode                ; Set error code as returned value

    pop ebx
    ret

Trace endp

; ##########################################################################

End LibMain
:Batch
@echo off

if exist %~n0.obj del %~n0.obj
if exist %~n0.dll del %~n0.dll

\masm32\bin\ml /c /coff %~n0.bat

\masm32\bin\Link /SUBSYSTEM:WINDOWS /DLL /EXPORT:Trace %~n0.obj

dir %~n0.*
pause