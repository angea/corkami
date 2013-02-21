import shutil
import os
import subprocess
import re

import sqlite3

files = ["file1", "file2"]

print "ndh 2010 challenge forensic 1 - http://wargame.nuitduhack.com/epreuves/forensic/235RQSDFvd/"
print "Ange Albertini, Public Domain, 2010"

print
print "analysing files:", " ".join(files)

# contents / filename matches
conts = {
"global-salt": "key3.db",
"exmoz_logins_host": "signons.sqlite",
}

for fn in files:

    f = open(fn, "rb")
    r = f.read()
    f.close()
    for text in conts:
        if r.count(text):
            print "\t'%s' contains '%s'\n\t\t => actually '%s', copy created" % (fn, text, conts[text])
            shutil.copy(fn, conts[text])
            break


print
print "bruteforcing masterpassword with FireMaster (http://www.securityxploded.com/firemaster.php)"

for len_ in range(1,5):
    print "\tlength %i (press space if needed)" %  len_
    cmd = "firemaster -q -b -l %i ." % (len_)
    proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, stdin=subprocess.PIPE)
    out, err = proc.communicate(input="aa")

    off = out.find("Your Firefox Master password is" )
    if off > -1 :
        password = out[off + 33:].split()[0]
        print "\t\tmaster password found: '%s'" % password
        break
    proc.wait()


print
print "copy a valid Firefox cert8.db in the current directory"

# not portable :(
for i in os.walk(os.path.expandvars("%APPDATA%\\Mozilla\\Firefox\\Profiles")):
    if 'cert8.db' in i[2]:
        source = os.path.join(i[0], 'cert8.db')
        print "\tfound %s" % source

        shutil.copy(source, ".")
        break

print
print "opening firefox files with FirePassword (http://www.securityxploded.com/firepassword.php) and found masterpassword"

cmd = "FirePassword -m %s ." % password
proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, stdin=subprocess.PIPE)
before = proc.communicate()[0]

print "\tdone (contents hidden)"

print
print "scanning signons.sqlite for hidden record"

f = open('signons.sqlite', "rb")
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

query = INSERT % vars()


print
print "manually recovering hidden records via inserting directly with sqlite"

print "\t query : %s" % query
connection = sqlite3.connect('signons.sqlite')
cursor = connection.cursor()
cursor.execute(query)
connection.commit()


print
print "opening firefox files with FirePassword again, comparing results"

proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, stdin=subprocess.PIPE)
after = proc.communicate()[0]

print
print after.replace(before, "")