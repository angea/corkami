"""extract all records, that might come 
from the moz_logins table of a FireFox signons.sqlite

can be used to recover deleted records

TODO: read sqlite table, compare, and re-insert deleted records"""
import sys
import re

file_ = 'signons.sqlite'
if len(sys.argv) > 1: 
    file_ = sys.argv[1]

f = open(file_, "rb")
r = f.read()
f.close()

URL_RE = "((https?|ftp|gopher|telnet|file|notes|ms-help):((//)|(\\\\))+[\w\d:#@%/;$()~_?\+-=\\\.&]*)" # taken from google

LOWHEX_RE = "[0-9a-f]"
CLSID_RE = "\{%(LOWHEX_RE)s{8}-%(LOWHEX_RE)s{4}-%(LOWHEX_RE)s{4}-%(LOWHEX_RE)s{4}-%(LOWHEX_RE)s{12}\}" % vars()

BASE64_RE = "[A-Za-z0-9\/\+\=]*"
ENCODEDINFO_RE = "M..EEPgAAAAAAAAAAAAAAAAAA" + BASE64_RE

INSERT = "INSERT INTO 'moz_logins' VALUES(" + ", ".join([
    "%(index_)i",
    "'%(url)s'",
    "NULL",
    "'%(url)s'",
    "'%(login)s'",
    "'%(password)s'",
    "'%(encodedlogin)s'",
    "'%(encodedpass)s'",
    "'%(clsid)s'",
    "%(n)i"]) + ");"

SQL_RE = "".join([
    "(?P<index>[\x01-\x10])",
    "(?P<url>%(URL_RE)s)",
    "(?P=url)",
    "(?P<login>(login|username|email))",
    "(?P<password>password)",
    "(?P<encodedlogin>%(ENCODEDINFO_RE)s)",
    "(?P<encodedpass>%(ENCODEDINFO_RE)s)",
    "(?P<clsid>%(CLSID_RE)s)",
    "(?P<n>[\x01-\x10])"]) % vars()

index_, url, login, password, encodedlogin, encodedpass, clsid, n = re.search(SQL_RE, r).group('index', 'url', 'login', 'password', 'encodedlogin', 'encodedpass', 'clsid', 'n')

index_ = ord(index_)
n = ord(n)

print INSERT % vars()