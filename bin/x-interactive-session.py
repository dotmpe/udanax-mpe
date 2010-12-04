#!/usr/bin/env python
"""
"""
import os
import sys
from pyxi.x88 import *
from pyxi.udxutil import DOC_CONTENTS, DOC_LINKS, ENTIRE_DOC


if __name__ == "__main__":
    backend = os.path.join('be', 'backend')
    host = "localhost"
    port = 55146
    log = False

    # Parse argv
    import getopt
    opts, extra = getopt.getopt(sys.argv[1:], "t:b:l")
    for o in opts:
        if '-b' in o: # -b <backend-path>
            backend = o[1]
        elif '-l' in o: # -l(ogging) 
            log = True
        elif '-t' in o: # -t <host:port>
            tcp_addr = o[1].split(':')
            host, port = tcp_addr[0], int(tcp_addr[1])

    # Check existence of backend, enfilade
    if not os.path.exists(backend):
        print "There is no file at %s." % (backend,)
        print "Please put a copy or a link to the server executable there."
        sys.exit(1)

    be_dir = os.path.dirname(backend)
    be = os.path.basename(backend)

    # Work from backend dir
    cwd = os.getcwd()
    os.chdir(be_dir)

    enf = 'enf.enf'
    if not os.path.exists(enf):
        print "No enfilade file at %s; trying to copy default..." % \
            (os.path.join(be_dir, enf))
        sample_enf = "../../enfs/sample.enf"
        os.system("cp -f %s %s" % (sample_enf, enf.encode('string-escape')))
        if not os.path.exists(enf):
            print "Unable copy enfilade from %s;" % (sample_enf)
            print "please copy one from the udanax dist to %s." % os.path.realpath(enf)
            sys.exit(2)

    print "Using backend at\n  \x1b[33m<%s>\x1b[0m\nwith enfilade from\n  \x1b[33m<%s>\x1b[0m" % tuple(map(os.path.realpath, (be, enf)))


    # Start Xu88.1 session

    print ""

    ps = PipeStream(be)
    print "\x1b[36mps\x1b[0m = \x1b[32m%s \x1b[33m(fifo: %s)\x1b[0m" % (ps, ps.outpipe)
    print "Created FIFO to backend using named pipe."
    print ""

    if log:
        stream= StreamDebug(ps, sys.stderr)
        print "\x1b[36mstream\x1b[0m = \x1b[32m%s \x1b[33m(log: %s)\x1b[0m" % (stream,
                sys.stderr)
        print "Wrapped FIFO stream IO with for visual protocol chatter."
        print ""
    else:
        stream = ps

    be = XuConn(stream)
    print "\x1b[36mbe\x1b[0m = \x1b[32m%s\x1b[0m" % (be,)
    print "Initialized Xu88 connection to server."

    print ""

    print "Starting session now, handshaking with backend:"
    xs = XuSession(be)
    #be.handshake()
    print "\x1b[36mxs\x1b[0m = \x1b[32m%s\x1b[0m" % (xs,)
    print "Xu88 session ready."

    def example_session():
        doc_addr = Address('1.1.0.1.0.1')
        xs.open_document(doc_addr, READ_ONLY, CONFLICT_FAIL)
        stream.flush()
        print "Opened document", doc_addr
        docspecset = SpecSet(VSpec(doc_addr, [ENTIRE_DOC]))
        content = xs.retrieve_contents(docspecset)
        stream.flush()
        print "Retrieved content", content
        print
        docspec2 = xs.retrieve_vspanset(doc_addr)
        stream.flush()
        print "Retrieved vspanset", docspec2
        print
        content = xs.retrieve_contents(SpecSet(docspec2))
        stream.flush()
        print "Retrieved content ", content
        print
        docvspan = xs.retrieve_vspan(doc_addr)
        stream.flush()
        print "Retrieved vspan", docvspan
        print

    print """
----

Now for example to open a document, and get its contents both data and links::
    
    >>> doc_addr = Address('1.1.0.1.0.1')
    >>> xs.open_document(doc_addr, READ_ONLY, CONFLICT_FAIL)
    Address(1L, 1L, 0L, 1L, 0L, 1L)
    >>> docspecset = SpecSet(VSpec(doc_addr, [ENTIRE_DOC]))
    >>> xs.retrieve_contents(docspecset)
    ['contents...']

One could also request the spec-set for the data/link space.

    >>> docspec2 = xs.retrieve_vspanset(doc_addr)
    >>> docspec2
    <SpecSet [<VSpec in 1.1.0.1.0.1, at 0.0 for 2.0>]>
    >>> xs.retrieve_contents(SpecSet(docspec2))
    ['contents...']

But that always (afaik) is the span of 1.
This example is provided by function example_session().

When using the '-l' flag you may want to use stream.flush() regularly.


For further reference, see FEBE protocol specification for Xu88.1 [1] and 
read the source, in particulary x88.py

[1] http://www.udanax.com/green/febe/protocol.html

----
"""

# vim:set et:
