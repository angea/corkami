import pefile
import sys

fn = sys.argv[1]
pe = pefile.PE(fn)
if pe.OPTIONAL_HEADER.CheckSum == 59788: # pefile checksum corrupts can't work on 97 bits files :(
    sys.exit()
pe.OPTIONAL_HEADER.CheckSum = pe.generate_checksum()
pe.write(fn) # pe.write will 'expand' tiny PEs :(
