; a simple "Hello World!" ELF

; Ange Albertini, BSD Licence 2013

%include 'common.inc'

_header
    pusha
    _dprint HdrMsg

    rdtsc
    mov eax, 1

    cmp eax, 1

    jnz error_
    _dprint success
    _exit 0
error_:
    _print errormsg
    _exit 42
_d

_dstring HdrMsg, "* TEST start : hello world", 0ah
_dstring success, " success!", 0ah
_string  errormsg, " error!", 0ah
_d

_footer