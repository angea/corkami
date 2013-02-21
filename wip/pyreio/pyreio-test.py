#Small script to test PyREI/O functionalities

from pyreio import *

msg("Hello")
import sys
msg(sys.version)
msg("Hello\n(%s)" % FRAMEWORK)

sel = getselection()
msg(sel.encode("string-escape") if sel is not None else "Empty")