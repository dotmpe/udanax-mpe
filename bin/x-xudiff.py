""" XuDiff - File based diff.
 March 2009
 Todo: implementation
"""
import sys, os

fn='test-doc.txt'

tmpf = os.tmpnam() + '.txt'
os.mknod(tmpf)
tmpfl = open(tmpf, 'w+')
tmpfl.write(open(fn,'r').read())
tmpfl.close()

#Let user edit file
mtime = os.stat(tmpf)[8]
v=os.system("%s %s" % (os.environ['EDITOR'], tmpf))

if (v):
    print 'Editor reported error, aborting.'

elif mtime == os.stat(tmpf)[8]:
    print "No changes, aborting."

else:
    stdin,stdout = os.popen3('diff -d "%s" "%s"' % (fn, tmpf))
    print stdin.read()


# TODO: convert diff line-nmbrs to character offsets
# Output xu88.1

