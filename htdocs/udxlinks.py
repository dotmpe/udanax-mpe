#!/usr/bin/env python
"""Examine end-sets in a document and print links.
"""
import os
import sys
sys.path.append('../pyxi/')
from pyxi import x88, udxutil
from udxutil import ENTIRE_DOC, mutter


def print_links(xs, addr):
    xs.open_document(addr, x88.READ_ONLY, x88.CONFLICT_FAIL)

    vspec = xs.retrieve_vspanset(addr)

    mutter(1, 'vspans', vspec)

    links= []
    # Get all end sets in given document
    for vspan in vspec:
        if vspan.span.start[0] == 1:
            textspec = x88.SpecSet(x88.VSpec(addr, [vspan.span]))
            srcspecs, trgtspecs, tpspecs = xs.retrieve_endsets(textspec)

            if srcspecs:
                mutter(1, 'found from specs', srcspecs)
                links += xs.find_links(srcspecs)
            else:
                mutter(1, 'no from specs in', vspan)

            if trgtspecs:
                mutter(1, 'found end specs', trgtspecs)
                links += xs.find_links(x88.NOSPECS, trgtspecs)
            else:
                mutter(1, 'no end specs in', vspan)

            if tpspecs:
                mutter(1, 'found three specs', tpspecs)
                links += xs.find_links(x88.NOSPECS, x88.NOSPECS, tpspecs)
            else:
                mutter(1, 'no three specs in', vspan)

        elif vspan.span.start[0] == 2:
            mutter(1, 'linkvspan', vspan)

        else:
            mutter(1, 'ignoring vspan', vspan)

    # Filter out duplicate link addresses
    filtered = []
    for laddr in links:
        if not laddr in filtered:
            filtered.append(laddr)
        else:
            mutter(1, 'ignoring duplicate link', laddr)

    links = filtered

    # output
    print 'Links with endsets in', addr
    print
    for laddr in links:
        print laddr, 'type:',
        srcspecs = xs.follow_link(laddr, x88.LINK_SOURCE)
        trgtspecs = xs.follow_link(laddr, x88.LINK_TARGET)
        tpspecs = xs.follow_link(laddr, x88.LINK_TYPE)
        for spec in tpspecs:
            if spec in x88.TYPE_NAMES:
                print x88.TYPE_NAMES[spec],
            else:
                print spec,
        print
        print '\tsource:', srcspecs
        for spec in srcspecs:
            sourceruns = []
            for vspan in spec:
                if vspan.docid != addr:
                    xs.open_document(vspan.docid, x88.READ_ONLY, x88.CONFLICT_FAIL)
                nspec = x88.SpecSet(x88.VSpec(vspan.docid, [vspan.span]))
                sourceruns += xs.retrieve_contents(nspec)
                if vspan.docid != addr:
                    xs.close_document(vspan.docid)
            print '\t', sourceruns
        print '\ttarget:', trgtspecs
        for spec in trgtspecs:
            targetruns = []
            for vspan in spec:
                if vspan.docid != addr:
                    xs.open_document(vspan.docid, x88.READ_ONLY, x88.CONFLICT_FAIL)
                nspec = x88.SpecSet(x88.VSpec(vspan.docid, [vspan.span]))
                targetruns += xs.retrieve_contents(nspec)
                if vspan.docid != addr:
                    xs.close_document(vspan.docid)
            print '\t', targetruns
        print
    xs.close_document(addr)

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
    doc_list = args

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

    # print links
    if doc_list:
        for addr in doc_list:
            docid = x88.Address(addr)
            print_links(xs, docid)

    xs.quit()
    os.chdir(cwd)

if __name__ == '__main__':
    sys.exit(main(sys.argv))

