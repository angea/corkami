# PyReI/O script to extract selection and turn it into a text file, ready for asm2test
# BSD Licence, Ange Albertini 2011

from pyreio import *

sel = getselection()

if sel is None:
    msg("Empty Selection ! aborting...")
else:
    from utils import get_disassembly, templatize, seq_to_snippets, code_to_seq
    r = get_disassembly(sel)

    hlen = max(len(i[0]) for i in r) + 1

    import os
    filename = "temp%s.txt" % os.getpid()
    f = open(filename, "wt")

    f.write("// Add a * in front of the bytes you want to ignore\n")
    f.write("// this file will be deleted at the end of the procedure\n\n")
    f.write("\n".join(("// %s:%s" % (i[0].ljust(hlen), i[1]) for i in r)))
    f.close()

    #hiew.MessageWaitOpen()
    os.system(filename)
    #hiew.MessageWaitClose()

    f = open(filename, "rt")
    r = f.readlines()
    f.close()

    f = open(filename, "wt")
    for i in r:
        f.write(i)
    f.write("\n")
    f.write(templatize(seq_to_snippets(code_to_seq(r))))
    f.close()

    #TODO: make portable hiew.MessageWaitOpen()
    os.system(filename)
    #hiew.MessageWaitClose()

    #hiew.Window.FromString("Success", "Operation successfull! deleting temp file...")
    os.remove(filename)

