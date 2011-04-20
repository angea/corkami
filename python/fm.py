# family-maker - a parent-child relation builder

# TODO: try to 'decompress' anything, if success, repeat with any smaller file than just decompressed

import os
import sys
import hashlib
import pprint

def getmd5(data_):
    m = hashlib.md5()
    m.update(data_)
    return m.hexdigest()

# todos = {(unique) md5: (filenames), size, first16b}
todos = {}
for root, dirs, files in os.walk('.'):
    for file_ in files[:]:
        fn = root + '\\' + file_

        # get files md5
        with open(fn, "rb") as f:
            r = f.read()

            # extract first 16 bytes of each file
            _16b = r[:16]
        size = len(r)

        # exclude short files
        if size < 16:
            print "ERROR: too small, ignored: ", file_
            continue
        md5 = getmd5("".join(r))
        if md5 in todos:
            print "Warning: %s is a duplicate (MD5=%s)" % (file_, md5)
            todos[md5][0].append(file_)
            continue
        else:
            todos[md5] = [[file_], size, _16b, r]

tree = []
# sort file by filelength
md5s = sorted(todos, key=lambda x:x[2])
# try to look at smaller files in bigger files:

# TODO: better algo
#  match 16 first bytes
#  check checksum on filelength.
for big in range(len(md5s) - 1):
    md5big = md5s[big]
    for small  in range(big + 1,len(md5s)):
        md5small = md5s[small]
        # comparing sizes, if equal, skip
        if todos[md5small][1] == todos[md5big][1]:
            continue
        if todos[md5big][3].find(todos[md5small][3]) > -1:
            print "%s (filenames = %s) contains %s (filenames = %s)" % (md5big, todos[md5big][0], md5small, todos[md5small][0])
