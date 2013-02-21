# showing by example what's new in Python 2.7

# ordered dictionary ###########################################################
from collections import OrderedDict
d = OrderedDict([('first', 1),
	('second', 2),
	('third', 3)])
print d.items()
print

# format for thousands separator ###############################################
print '{:20,.2f}'.format(18446744073709551616.0)
print

# argparse #####################################################################

import argparse
parser = argparse.ArgumentParser(description='Command-line example.')

# Add optional switches
parser.add_argument('-v', action='store_true', dest='is_verbose',
                    help='produce verbose output')
parser.add_argument('-o', action='store', dest='output',
                    metavar='FILE',
                    help='direct output to FILE instead of stdout')
parser.add_argument('-C', action='store', type=int, dest='context',
                    metavar='NUM', default=0,
                    help='display NUM lines of added context')

# Allow any number of additional arguments
parser.add_argument(nargs='*', action='store', dest='inputs',
                    help='input filenames (default is stdin)')

args = parser.parse_args()
print args.__dict__
print

# dictionary views #############################################################
d1 = dict((i*10, chr(65+i)) for i in range(26))
d2 = dict((i**.5, i) for i in range(1000))
print d1.viewkeys() & d2.viewkeys()
print d1.viewkeys() | range(0, 30)
print

# memory view ##################################################################
import string
m = memoryview(string.letters)
print m, len(m), m[0], m[25], m[26], m[0:26]
print

# set literals #################################################################
print {1, 2, 3, 4, 5}, set()
print

# dict and set comprehensions ##################################################
print {x: x*x for x in range(6)}, {('a'*x) for x in range(6)}
print

# multiple and nested WITH #####################################################
# with A() as a, B() as b:

# automatic fields format ######################################################
print '{}:{}:{}'.format(2009, 04, 'Sunday'),  '{}:{}:{day}'.format(2009, 4, day='Sunday')
print

# bit length  ##################################################################
print (37).bit_length(), (2**123-1 + 1).bit_length()
print
