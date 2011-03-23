# showing by example what's new in Python 2.6

# print as future function #####################################################
from __future__ import print_function
import sys

print('# of entries', 42, file=sys.stderr)

# with operator ################################################################
with open("test.bin", "wt") as f:
    f.write("goin")

# String format ################################################################
print("User ID: {0}".format("root"))
print('{0:15} ${1:>6}'.format('Registration', 35))
print('{0:e}'.format(3.75))


# new exception handling #######################################################
try:
    import goin
except (ImportError, ValueError):
    print(ValueError)

# Byte Arrays ##################################################################
b = bytearray(u'\u21ef\u3244', 'utf-8')
print(b)

# Octal and binary encodings ###################################################
print (oct(42), int ('0o52', 0), int('0b1101', 0))

#function mapping not limited to dict ##########################################
import UserDict
def f(**kw):
    print(sorted(kw))
ud=UserDict.UserDict()
ud['a'] = 1
ud['b'] = 'string'
f(**ud)

# tuple functions ##############################################################
t = (0,1,2,3,4,0,1,2)
print(t.index(3), t.count(0))

# keywords after arguments #####################################################
def f(*args, **kw):
    print(args, kw)
f(1,2,3, *(4,5,6), keyword=13)

#getters and setters ###########################################################
class C(object):
    @property
    def x(self):
        return self._x

    @x.setter
    def x(self, value):
        self._x = value

    @x.deleter
    def x(self):
        del self._x

class D(C):
    @C.x.getter
    def x(self):
        return self._x * 2

    @x.setter
    def x(self, value):
        self._x = value / 2
