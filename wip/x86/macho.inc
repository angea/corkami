CPU_TYPE_I386 equ 7

CPU_SUBTYPE_I386_ALL equ 3

MH_MAGIC equ 0FEEDFACEh
MH_EXECUTE equ 2
MH_NOUNDEFS equ 1

struc mach_header
    .magic      resd 1
    .cputype    resd 1
    .cpusubtype resd 1
    .filetype   resd 1
    .ncmds      resd 1
    .sizeofcmds resd 1
    .flags      resd 1
endstruc

LC_SEGMENT equ 1
LC_UNIXTHREAD equ 5

x86_THREAD_STATE_32 equ 1

_x equ 1
_w equ 2
_r equ 4

struc segment_command
    .cmd      resd 1
    .cmdsize  resd 1
    .segname  resb 16
    .vmaddr   resd 1
    .vmsize   resd 1
    .fileoff  resd 1
    .filesize resd 1
    .maxprot  resd 1
    .initprot resd 1
    .nsects   resd 1
    .flags    resd 1
endstruc

struc thread_command
    .cmd resd 1
    .cmdsize resd 1
    .flavor resd 1
    .count resd 1
;    .state ; starts here
endstruc

struc i386_thread_state
    .eax    resd 1
    .ebx    resd 1
    .ecx    resd 1
    .edx    resd 1
    .edi    resd 1
    .esi    resd 1
    .ebp    resd 1
    .esp    resd 1
    .ss     resd 1
    .eflags resd 1
    .eip    resd 1
    .cs     resd 1
    .ds     resd 1
    .es     resd 1
    .fs     resd 1
    .gs     resd 1
endstruc

STDOUT equ 1

SC_EXIT equ 1
SC_WRITE equ 4h
