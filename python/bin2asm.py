"""Prototype of a brutal disassembler"""

from string import printable

def RLE(s):
	""" turn a sequence of char into a [repetition count, char] sequence"""
	l = []
	last_char = None
	counter = 0
	for i, c in enumerate(s):
		if c == last_char:
			counter += 1
		else:
			if last_char is not None:
				l.append([counter, last_char])
			last_char = c
			counter = 1
	if counter > 0 and last_char is not None:
		l.append([counter, last_char])
	return l

def encode_byte(c):
	if c == "\0":
		return "0"
	elif ord(c) < 10 or c in "\n\r'\"":
		return "%i" % ord(c)
	elif c in printable:
		return '"%s"' %  (c)
	else:
		return "0%02Xh" % ord(c)

def make_db_seq(l):
	return "db %s" % (", ".join(encode_byte(c) for c in l))

def make_repetition_seq(counter, c):
	return "times %i db %s" % (counter, encode_byte(c))

def bin2asm(l):
	cur_string = []
	strings = []
	for counter, c in l:
		if counter > 4:
			if len(cur_string) > 0:
				strings.append(make_db_seq(cur_string))
				cur_string = []
			strings.append(make_repetition_seq(counter, c))
		elif counter > 0:
			for i in range(counter):
				cur_string.append(c)
		else:
			cur_string.append(c)

	if len(cur_string) > 0:
		strings.append(make_db_seq(cur_string))

	return "\n".join(strings)

import sys
fn = sys.argv[1]
with open(fn, "rb") as f:
	r = f.read()

with open(fn + ".asm", "wb") as t:
	t.write(bin2asm(RLE(r)))
