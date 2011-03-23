# showing by example what's new in Python 2.5

# inline conditional expressions ###############################################

doc = ""
contents = ((doc + '\n') if doc else '')

# partial functions with functools.partial #####################################

# absolute and relative imports ################################################
# from . import D
# from ..F import G

# Yield is now an expression ###################################################

# with as a future statement ###################################################

# startswith/endwith with multiple parameters ##################################
print "blah".startswith(("blah", "goin"))
print

# __missing__ method for dicts #################################################
class zerodict (dict):
    def __missing__ (self, key):
        return 0

d = zerodict({1:1, 2:2})
print d[1], d[2]
print d[3], d[4]
print

# partition ####################################################################
print ('http://www.python.org').partition('://')

# max/min have an optional key now #############################################
L = ['medium', 'longest', 'short']
print max(L, key=len), max(L)

# any and all ##################################################################
L = [True, False, False]
print any(L)
print all(L)

# new modules: ctypes, hashlib, sqlite3 ########################################
