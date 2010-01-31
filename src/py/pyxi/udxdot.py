#!/usr/bin/env python
"""udxdot - Create a GraphViz dot file describing the relations in an Udanax
enfi1ade.

First verions: show wether documents are connected. Visualize docids as nodes
with connections in between.

Bugs:
- May show duplicate connections.
"""
import sys
import os
#from udxexp import mutter
import x88, udxutil
from udxutil import DOC_CONTENTS, DOC_LINKS, ENTIRE_DOC


def mutter(lvl, *args):
    print lvl, args

def write_dot(fh, links):
    fh.write("""digraph doc_connections{
rankdir="LR";
node[fontname="Bitstream Vera Sans Mono",color=gray];
edge[fontname="Bitstream Vera Sans Mono"];
edge[color=green]
""")

    nodes = {}

    for addr in links:
        if not addr in nodes:
            nodes[addr] = 'doc_' + str(addr).replace('.', '_')
            fh.write("""%s[label="%s"]; """ % (nodes[addr], addr))
        for to_addr in links[addr]:
            if not to_addr in nodes:
                nodes[to_addr] = 'doc_' + str(to_addr).replace('.', '_')
                fh.write("""%s[label="%s"]; """ % (nodes[to_addr], to_addr))
            fh.write("""%s -> %s; """ % (nodes[addr], nodes[to_addr]))

    fh.write("}")


def doc_connections(xs, doc_addr):
    """Return a list of document ids linked from given document.
    """

    docs = []

    mutter(3, '> open (35)', doc_addr)
    xs.open_document(doc_addr, x88.READ_ONLY, x88.CONFLICT_FAIL)

    ### Find docs targetted from vspans in this document
    textspec = x88.SpecSet(x88.VSpec(doc_addr, [ENTIRE_DOC]))

    # find linked spans
    mutter(2, '> retrieve-endsets (28)', textspec)
    srcspecs, trgtspecs, tpspecs = xs.retrieve_endsets(textspec)
    mutter(2, '<', srcspecs, trgtspecs, tpspecs)

    links = []

    # find links for source spans
    if srcspecs:
        mutter(2, '> find-links-from-to-three (30)', srcspecs)
        links += xs.find_links(srcspecs)
        mutter(2, '<', links)

    # find targets for links
    for laddr in links:
        mutter(1, '> follow-link (18)', laddr, x88.LINK_TARGET)
        trgtspecs = xs.follow_link(laddr, x88.LINK_TARGET)
        mutter(1, '<', trgtspecs)
        for vspec in trgtspecs:
            docs.append(vspec.docid)

    xs.close_document(doc_addr)

    return docs

def find_connections(xs, docs):
    """Return a dictionary where each key is a doc address and
    the value is a list of other doc adresses it is linked to.

    Home sets and link types are ignored.
    """

    links = {}

    while docs:
        addr = docs.pop(0)

        if not addr in links:
            links[addr] = []

        # get docs targetted by links from this doc address
        cdocs = doc_connections(xs, addr)

        for doc in cdocs:

            # add doc as connected to current address
            links[addr].append(doc)

            # queue new docs for their connections
            if not doc in links and not doc in docs:
                docs.append(doc)

    return links

def main(argv):

    backend = 'be/backend'
    first_doc = "1.1.0.1.0.1"
    docs = [] # connected docs
    outf = sys.stdout

    ### Parse argv
    import getopt
    opts, args = getopt.getopt(argv[1:], "a:o:b:dv:")

    for o in opts:
        if '-a' in o:
            first_doc = o[1]
        elif '-o' in o:
            outf = open(o[1], 'w')
        elif '-b' in o:
            backend = o[1]
        elif '-d' in o:
            udxexp.chatty += 1
        elif '-v' in o:
            udxexp.chatty = int(o[1])

    docs = [x88.Address(first_doc)]

    # allow docs added manually
    for a in args:
        docs.append(x88.Address(a))

    be_dir = os.path.dirname(backend)
    backend = os.path.basename(backend)
    cwd = os.getcwd()
    # must run from backend dir or else some request fail
    os.chdir(be_dir)

    ## Get 88.1 session
    if udxexp.chatty > 2:
        xs = x88.pipeconnect_debug(backend, sys.stderr)
    else:
        xs = x88.pipeconnect(backend)

    ### Find connections
    mutter(1, 'starting with', docs)
    links = find_connections(xs, docs)

    ## write dot file
    write_dot(outf, links)

    xs.quit()

if __name__ == '__main__':
    sys.exit(main(sys.argv))
