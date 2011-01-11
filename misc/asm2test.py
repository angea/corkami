# Small code to C-test generator
# BSD Licence, Ange Albertini 2011

# this program generates a C test from a sequence of bytes with ignored entries

# It will turn this:

#  0F, B7, F7                  //movzx esi,di
#  8D, 45, C0                  //lea eax,[ebp-0x40]
#  53                          //push ebx
#  50                          //push eax
#  C7, 45, FC,*05,*40,*00, 80  //mov dword [ebp-0x4],0x80004005
#  89, 7D, F8                  //mov [ebp-0x8],edi
#  03                          //add eax,[eax]


# into this:
# if (
#      (*(UINT32*)&buffer[i + 00]             == 0x8DF7B70F) &&
#      (*(UINT32*)&buffer[i + 04]             == 0x5053C045) &&
#     ((*(UINT32*)&buffer[i + 08] & 0xFFFFFF) == 0xFC45C7) &&
#      (*(UINT32*)&buffer[i + 0e]             == 0xF87D8980) &&
#      (*(UINT8*)&buffer[i + 12]              == 0x03)
#     )
#     {




if __name__=='__main__':
    import sys
    from utils import templatize, seq_to_snippets, code_to_seq
    f = open(sys.argv[1], "rt")
    r = f.readlines()
    f.close()

    print templatize(seq_to_snippets(code_to_seq(r)))