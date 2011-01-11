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
