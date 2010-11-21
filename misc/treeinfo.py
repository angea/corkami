#sometimes TotalCommander cannot itself update \treeinfo.wc,
# and doesn't allow to create it in another directory
# this scripts creates manually a compatible treeinfo.wc

import os.path
dirs = []

def dircb(arg, dirname, names):
	arg += [dirname[1:].replace(':\\', '')]
	return

os.path.walk('\\', dircb, dirs)


#skip the root dir
text = "\n".join('[%s]' % s for s in dirs[1:])

f = open('treeinfo.wc', 'wt')
f.write(text)
f.close()

print('now copy treeinfo.wc to the root directory')