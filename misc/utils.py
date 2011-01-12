def get_disassembly(sel, start=None):
    from pydasm import get_instruction, get_instruction_string, MODE_32, FORMAT_INTEL
    if start is None:
        start = 0
    r = []
    offset = 0
    #TODO: get the source offset
    while offset < len(sel):
        instruction = get_instruction(sel[offset:], MODE_32)

        l = instruction.length
        h = []
        for _ in sel[offset: offset + l]:
            h.append("%02X" % ord(_))
        h = ",".join(h)
        asm = get_instruction_string(instruction, FORMAT_INTEL, offset + start)
        r.append([h, asm])
        offset += l
    return r

def getEPdata(fn, length=None):
	import pefile
	if length is None:
		length = 30
	pe = pefile.PE(fn)
	ep = pe.OPTIONAL_HEADER.AddressOfEntryPoint
	data = pe.get_memory_mapped_image()[ep:ep + length]
	return data

def getwildstring(s1,s2):
    """takes 2 strings, returns a string made of the common bytes or question marks"""
    l1 = len(s1)
    l2 = len(s2)
    if l1 < l2:
        s1 = s1 + " " * (l2 - l1)
    elif l1 > l2:
        s2 = s2 + " " * (l1 - l2)

    result = []
    for i, j in enumerate(s1):
        if s2[i] == j:
            result.append(j)
        else:
            result.append("?")
    return "".join(result)

def code_to_seq(s):
    """takes a list of string, remove comments, parse byte, replace *byte with None
    @returns a list of string of hex bytes or None
    """
    cleaned = []
    for l in s:
        # a code line should contain a // comment, otherwise skip it
        off = l.find(":")
        if off == -1:
            continue

        # strip unneded chars
        l = l[2:off].strip()
        l = l.replace(" ", "")
        cleaned += l.split(',')

    # replace *bytes with None
    for i,j in enumerate(cleaned):
        if j.lstrip().startswith("*") or j.lstrip().startswith("?"):
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
            text.append("\t (*(UINT32*)&buffer[i + 0x%02x] == 0x%s%s%s%s)" % (off, bytes[3], bytes[2], bytes[1], bytes[0]))
        elif len_ == 3:
            text.append("\t((*(UINT32*)&buffer[i + 0x%02x] & 0x00FFFFFF) == 0x00%s%s%s)" % (off, bytes[2], bytes[1], bytes[0]))
        elif len_ == 2:
            text.append("\t (*(UINT16*)&buffer[i + 0x%02x] == 0x%s%s)" % (off, bytes[1], bytes[0]))
        elif len_ == 1:
            text.append("\t (*(UINT8*) &buffer[i + 0x%02x] == 0x%s)" % (off, bytes[0]))

    #enclose the conditions
    template = "if (\n%s\n\t)\n\t{" % " && \n".join(text)

    #tab to spaces
    template = template.replace("\t", " " * 4)
    return template
