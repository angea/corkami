#!/usr/bin/env python3

# a dumb hex dumper

#> FTR XXD output:
#> 00000000: 2369 6e63 6c75 6465 203c 7374 6469 6f2e  #include <stdio.
#> 00000010: 683e 0a69 6e74 206d 6169 6e28 766f 6964  h>.int main(void
#> 00000020: 290a 7b0a 0970 7269 6e74 6628 2268 656c  ).{..printf("hel
#> 00000030: 6c6f 2077 6f72 6c64 5c6e 2229 3b0a 0972  lo world\n");..r
#> 00000040: 6574 7572 6e20 303b 0a7d 0a0a            eturn 0;.}..

import sys
import argparse
import codepages


def reporblnk(idx, map, blank="."):
	if map[idx] is not None:
		return chr(map[idx])
	else:
		return blank


parser = argparse.ArgumentParser(description="Hex viewer that uses codepages.")
parser.add_argument('file',
    help="input file(s).")
parser.add_argument('-cp', '--codepage', default="ASCII",
    help="codepages: %s." % ", ".join(sorted(codepages.codepages)))
parser.add_argument('--out', default=None,
    help="output to a file.")

args = parser.parse_args()
codepage = args.codepage.lower()
out = args.out
if codepage not in codepages.codepages:
    print("Error: unknown codepage %s (known: %s), aborting." % (
    	repr(codepage), ", ".join(sorted(codepages.codepages))))
    sys.exit()
codepage = codepages.codepages[codepage]


fn = args.file
with open(fn, "rb") as f:
	d = f.read()

i = 0
l = len(d)

output = []
while i < l:
	line = d[i:i+16]
	h = ["%02x" % i for i in line]
	h += ["  "] * (16 - len(h))
	a = [reporblnk(i, codepage) for i in line]
	a += [" "] * (16 - len(h))

	output += ["%08X: %s %s" % (i, " ".join(h), "".join(a))]
	i += 16

if out is None:
	for line in output:
		print(line)
else:
	with open(out, "w", encoding="utf8") as f:
		output = "\n".join(output)
		f.write(output)
