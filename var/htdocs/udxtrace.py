#!/usr/bin/env python
"""First look at transclusion.

Transcluded pieces do not seem to have a home doc.
Their spans are simply shared amongst docs.

Origin cannot be retraced without keeping track of the first appearance.
"""
import os
import sys
sys.path.append('../pyxi/')
import x88, udxutil
from udxutil import ENTIRE_DOC, mutter


def print_trace2(xs, addr):
    xs.open_document(addr, x88.READ_ONLY, x88.CONFLICT_FAIL)

    specset = xs.retrieve_vspanset(addr)
    print specset
    #specset = x88.SpecSet(x88.VSpec(addr, [ENTIRE_DOC]))
    vspan = xs.retrieve_vspan(addr)
    print vspan
    specset = x88.SpecSet(x88.VSpec(addr, [vspan.span]))

    # find-docs-containing (22)
    print xs.find_documents(specset)

    xs.close_document(addr)

def print_trace(xs, addr1, addr2):

    xs.open_document(addr1, x88.READ_ONLY, x88.CONFLICT_FAIL)
    xs.open_document(addr2, x88.READ_ONLY, x88.CONFLICT_FAIL)

    specset1 = x88.SpecSet(x88.VSpec(addr1, [ENTIRE_DOC]))
    specset2 = x88.SpecSet(x88.VSpec(addr2, [ENTIRE_DOC]))

    #  show-relations-of-2-versions (10)
    print xs.compare_versions(specset1, specset2)

    xs.close_document(addr1)
    xs.close_document(addr2)

def main(argv):
    # parse argv
    import getopt
    opts, args = getopt.getopt(argv[1:], "vd:b:")

    backend = '../pyxi/be/backend'
    doc_list = None
    for o in opts:
        if '-b' in o:
            backend = o[1]
        elif '-d' in o:
            udxutil.chatty = int(o[1])
        elif '-v' in o:
            udxutil.chatty += 1

    # docids to examine
    docs = map(x88.Address, args)

    # backend location sanity...
    assert os.path.exists(backend)
    be_dir = os.path.dirname(backend)
    be = os.path.basename(backend)
    assert os.path.exists(os.path.join(be_dir, 'enf.enf'))

    cwd = os.getcwd()
    os.chdir(be_dir)

    # get x88 session
    if udxutil.chatty>3:
        ps = x88.DebugWrapper(x88.PipeStream(be), sys.stderr)
        xc = x88.DebugWrapper(x88.XuConn(ps), sys.stderr)
        xs = x88.DebugWrapper(x88.XuSession(xc), sys.stderr)
    else:
        xs = x88.pipeconnect(be)

    # trace contents
    for docid in docs:
        print_trace2(xs, docid)

    xs.quit()
    os.chdir(cwd)

if __name__ == '__main__':
    sys.exit(main(sys.argv))
