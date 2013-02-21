# Minimalist compressor

import mypacklib, pefile
from aplib import compress, decompress

pe, oep, ib, start, size = mypacklib.load()


# read the first section
sect = pe.get_data(start)
# compress it
compressed_data = compress(sect).do()

# blank the original uncompressed data
pe.set_bytes_at_rva(start, "\x00" * size)

# we will inject our code and compressed data at the end of the last section
section = pe.sections[-1]
start, size = section.VirtualAddress, section.SizeOfRawData

my_stub = """
bits 32
section .text valign=1 vstart=0%(start_va)08xh
; http://www.ibsensoftware.com/files/aPLib-1.01.zip, /src/32bit/depack.asm
    mov    esi, compressed_data
    mov    edi, 0%(oep_va)08xh

    cld
    mov    dl, 80h
    xor    ebx,ebx

literal:
    movsb
    mov    bl, 2
nexttag:
    call   getbit
    jnc    literal

    xor    ecx, ecx
    call   getbit
    jnc    codepair
    xor    eax, eax
    call   getbit
    jnc    shortmatch
    mov    bl, 2
    inc    ecx
    mov    al, 10h
  .getmorebits:
    call   getbit
    adc    al, al
    jnc    .getmorebits
    jnz    domatch
    stosb
    jmp    nexttag
codepair:
    call   getgamma_no_ecx
    sub    ecx, ebx
    jnz    normalcodepair
    call   getgamma
    jmp    domatch_lastpos

shortmatch:
    lodsb
    shr    eax, 1
    jz     donedepacking
    adc    ecx, ecx
    jmp    domatch_with_2inc

normalcodepair:
    xchg   eax, ecx
    dec    eax
    shl    eax, 8
    lodsb
    call   getgamma

    cmp    eax, 32000
    jae    domatch_with_2inc
    cmp    ah, 5
    jae    domatch_with_inc
    cmp    eax, 7fh
    ja     domatch_new_lastpos

domatch_with_2inc:
    inc    ecx

domatch_with_inc:
    inc    ecx

domatch_new_lastpos:
    xchg   eax, ebp
domatch_lastpos:
    mov    eax, ebp

    mov    bl, 1

domatch:
    push   esi
    mov    esi, edi
    sub    esi, eax
    rep    movsb
    pop    esi
    jmp    nexttag

getbit:
    add    dl, dl
    jnz    .stillbitsleft
    mov    dl, [esi]
    inc    esi
    adc    dl, dl
  .stillbitsleft:
    ret

getgamma:
    xor    ecx, ecx
getgamma_no_ecx:
    inc    ecx
  .getgammaloop:
    call   getbit
    adc    ecx, ecx
    call   getbit
    jc     .getgammaloop
    ret

donedepacking:
    push 0%(oep_va)08xh
    retn
compressed_data:
"""

# fill fake values to be able to get the stub size
dummy_stub = my_stub % {"start_va":oep + ib, "oep_va":oep + ib}
stub_length = len(mypacklib.build_stub(dummy_stub))

# now we can locate our stub accurately
stub_start = start + size - (stub_length + len(compressed_data))

# and generate it
my_stub = my_stub % {"start_va":stub_start + ib, "oep_va":oep + ib}
stub = mypacklib.build_stub(my_stub)

stub += compressed_data

# we need to make that first section writable
section = pe.sections[mypacklib.getEPsection(pe)]
section.Characteristics |= pefile.SECTION_CHARACTERISTICS["IMAGE_SCN_MEM_WRITE"]

# patch the file with our changes, and modify EntryPoint value
mypacklib.patchas(pe, "compressed.exe", stub_start, stub)

# Ange Albertini, Creative Commons BY, 2009-2010
