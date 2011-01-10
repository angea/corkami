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


def code_to_seq(s):
    """takes a list of string, remove comments, parse byte, replace *byte with None"""
    cleaned = []
    for l in s:
        # a code line should contain a // comment, otherwise skip it
        off = l.find("//")
        if off == -1:
            continue

        # strip unneded chars
        l = l[:off].strip()
        l = l.replace(" ", "")
        cleaned += l.split(',')

    # replace *bytes with None
    for i,j in enumerate(cleaned):
        if j.startswith("*"):
            cleaned[i] = None
    return cleaned

def seq_to_snippets(l):
    """takes a list of bytes, or None, and returns a list of [offset, [bytes]]"""
    offset = 0
    seqs = []

    while offset < len(l):
        # look for a valid char
        if l[offset] is None:
            offset += 1
            continue

        cur = [l[offset]]
        cur_off = offset
        for i in xrange(min(3, len(l) - offset - 1)):
            if l[offset + i + 1] is None:
                break
            cur.append(l[offset + i + 1])
        seqs.append([cur_off, cur])
        offset += len(cur)
    return seqs

def templatize(seqs):
    """turns an [offset, [bytes]] list into a valid C test"""
    text = []
    for off, bytes in seqs:
        len_ = len(bytes)
        if len_ == 4:
            text.append("\t (*(UINT32*)&buffer[i + %02x]             == 0x%s%s%s%s)" % (off, bytes[3], bytes[2], bytes[1], bytes[0]))
        elif len_ == 3:
            text.append("\t((*(UINT32*)&buffer[i + %02x] & 0xFFFFFF) == 0x%s%s%s)" % (off, bytes[2], bytes[1], bytes[0]))
        elif len_ == 2:
            text.append("\t (*(UINT16*)&buffer[i + %02x]             == 0x%s%s)" % (off, bytes[1], bytes[0]))
        elif len_ == 1:
            text.append("\t (*(UINT8*) &buffer[i + %02x]             == 0x%s)" % (off, bytes[0]))

    #enclose the conditions
    template = "if (\n%s\n\t)\n\t{" % " && \n".join(text)

    #tab to spaces
    template = template.replace("\t", " " * 4)
    return template


if __name__=='__main__':
    import sys

    f = open(sys.argv[1], "rt")
    r = f.readlines()
    f.close()

    print templatize(seq_to_snippets(code_to_seq(r)))