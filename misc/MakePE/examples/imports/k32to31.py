#brutal patch to make use of kernel31 for XP SP3 backward compatibility

import os
import pefile
import sys

for root, dirs, files in os.walk('.'):
    for file in files:
    if file.startswith("kernel31.dll"):
        continue
        fn = root + '\\' + file
        try:
        with open(fn, "rb") as f:
        r = f.read()
            pe = pefile.PE(data=r)
        except pefile.PEFormatError,s:
            continue

    r = r.replace("kernel32", "kernel31").replace("KERNEL32", "KERNEL31")

    os.rename(fn, fn + ".bak32")
    with open(fn, "wb") as f:
        f.write(r)
    continue
    
    # removed: pseudo-smart import patching, not working for on the fly loading.