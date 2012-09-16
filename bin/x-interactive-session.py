#!/usr/bin/env python
"""
"""
import os
import time
import sys

from xu88.x88 import *
from xu88.udxutil import DOC_CONTENTS, DOC_LINKS, ENTIRE_DOC


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
    backend = os.path.basename(backend)

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

    print "Using backend at\n  \x1b[33m<%s>\x1b[0m\nwith enfilade from\n \x1b[33m<%s>\x1b[0m" % tuple(map(os.path.realpath, (backend, enf)))

    # Start Xu88.1 session
    def start_session():
        global ps, log, stream, be, xs

        ps = PipeStream(backend)
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
        print ""

    def example_session1():
        global xs, stream
        print
        doc_addr = Address('1.1.0.1.0.1')
        xs.open_document(doc_addr, READ_ONLY, CONFLICT_FAIL)
        stream.flush()
        print "Opened document", doc_addr
        print
        docspecset = SpecSet(VSpec(doc_addr, [ENTIRE_DOC]))
        content = xs.retrieve_contents(docspecset)
        stream.flush()
        print "Retrieved content"
        print "".join(content)[0:20] + '...'
        print
        endsets = xs.retrieve_endsets(docspecset)
        stream.flush()
        print "Retrieved link endsets"
        print endsets
        print 'Closing'
        xs.close_document(doc_addr)
        stream.flush()
        return docspecset, content, endsets

    def example2():
        global xs, stream
        doc_addr = Address('1.1.0.1.0.1')
        xs.open_document(doc_addr, READ_ONLY, CONFLICT_FAIL)
        #docspec2 = xs.retrieve_vspanset(doc_addr)
        #stream.flush()
        #print "Retrieved vspanset", docspec2
        #print
        docvspan = xs.retrieve_vspan(doc_addr)
        stream.flush()
        print "Retrieved vspan", docvspan
        print
        spec = SpecSet(docvspan)
        fromlinks = xs.find_links(spec)
        tolinks = xs.find_links(NOSPECS, spec)
        threelinks = xs.find_links(NOSPECS, NOSPECS, spec)
        xs.find_links(NOSPECS, NOSPECS, NOSPECS, [doc_addr, 0])
        #homeset = xs.find_links(NOSPECS, NOSPECS, NOSPECS, [doc_addr])
        stream.flush()
        print
        #print doc_addr, '<----- fromlinks', fromlinks
        #print doc_addr, 'tolinks ------->', tolinks
        #print doc_addr, '-- threelinks --', threelinks
        #print doc_addr, 'homeset', homeset
        print
        for links in fromlinks, tolinks, threelinks:
            for linkid in links:
                froms = xs.follow_link(linkid, 1)
                tos = xs.follow_link(linkid, 2)
                threes = xs.follow_link(linkid, 3)
                stream.flush()
                print "Link",linkid
                print "From",froms
                print "To", tos
                print "Three",threes
                #time.sleep(1)
        print
        sharedspec = xs.find_documents(spec);
        stream.flush()
        print
        print doc_addr, 'Shared', sharedspec
        print 'Closing'
        xs.close_document(doc_addr)
        stream.flush()

    def experiment():
        print "Finding all links attached to a document or a range of documents"
        print "is easy, but it is not possibly to find links for a given homedocument"
        xs.open_document(Address("1.1.0.1.0.1"), READ_ONLY, CONFLICT_FAIL)
        xs.open_document(Address("1.1.0.1.0.2"), READ_ONLY, CONFLICT_FAIL)
        # address entire  space in docuverse 1 
        vspec = VSpec(Address("1"), [
            Span(Address("0.0"), Address("1.0"))
        ])
#        print xs.find_links(SpecSet(vspec), NOSPECS, NOSPECS)
#        print xs.find_links(SpecSet(vspec), SpecSet(vspec), SpecSet(VSpec))
        print xs.find_links(SpecSet(vspec), SpecSet(vspec), SpecSet(vspec), [
                Address("1.1.0.1.0.1"),
                Address("1.1.0.1.0.2")
            ])
        xs.close_document(Address("1.1.0.1.0.1"))
        xs.close_document(Address("1.1.0.1.0.2"))

    def experiment():
        print "All docs for first user"
        vspec = VSpec(Address("1.1.0.1"), [
            Span(Address("0.0"), Address("1.0"))
        ])
        print xs.find_documents(SpecSet(vspec))
        #xs.close_document(Address("1.1.0.1.0.1"))
        stream.flush()
        print "All docs for all users"
        vspec = VSpec(Address("1.1"), [
            Span(Address("0.0"), Address("1.0"))
        ])
        print xs.find_documents(SpecSet(vspec))
        stream.flush()
#        spec = VSpec(Span(Address("1.1.0.1"), Offset(0, 2)))
#        print xs.find_documents(spec)
#        stream.flush()
#        spec = VSpec(Address(), Span(Address("1.1"), Offset(0, 2)))
#        print xs.find_documents(spec)
#        stream.flush()

    print ""
    start_session()

    doc = """
----

Now for example to open a document::
    
    >>> doc_addr = Address('1.1.0.1.0.1')
    >>> xs.open_document(doc_addr, READ_ONLY, CONFLICT_FAIL)
    Address(1L, 1L, 0L, 1L, 0L, 1L)

Now we can determin its size, and/or get all contents and link endsets within
its range::

    >>> docspec = xs.retrieve_vspanset(doc_addr)
    >>> docspec
    <VSpec in 1.1.0.1.0.1, at 1.1 for 0.180>
    >>> docspecset = SpecSet(docspec)
    >>> xs.retrieve_contents(docspecset)
    ['contents...']
    >>> xs.retrieve_endsets(docspecset)
    (SpecSet([VSpec(Address(...), Span(...))]))

The entire range may also be created without knowledge of the exact length,
because it is sufficient to select 0.0 to 1.0. Links do not seem to be retrieved
directly like this, so selecting 1.0 to 2.0 is not of much use.
::

    >>> docspecset = SpecSet(VSpec(doc_addr, [ENTIRE_DOC])))
    <SpecSet [<VSpec in 1.1.0.1.0.1, at 0.0 for 2.0>]>

Some methods do the same as others but return different structures.
The both retrieve_vspanset and retrieve_vspan return the same data.
but the vspan seems for suited. The backend always returns a single
span of a single document. Compare to the docspec above:

    >>> docvspan = xs.retrieve_vspan(doc_addr)
    >>> docvspan
    <VSpan in 1.1.0.1.0.1 at 1.1 for 0.180>

The retrieve endsets list either all from, to or three sets in the document.
This gives not the link addresses. 'find_links' does that.
And 'follow_link' may be used to return any endset (1 from; 2 to; 3
three)::

    >>> xs.find_links(sourcespec, targetspec, threespec, homespec)
    >>> xs.follow_link(1, linkid)

The next step is finding shared content. find_documents accepts a spec
of content spans, and returns all documents transcluding that.

For further reference, see FEBE protocol specification for Xu88.1 [1] and 
read the source, in particulary x88.py. The names in the code may be 
different than in de protocol specification, for the same underlying commands.

Experimentation shows that the find-documents-containing function may
also be used to find all of a users documents, or to find all documents of all
users on a node. Equally the find-links-from-to-three may be used to get
linkids *pointing* to ranges of documents (e.g. the entire first docuverse),
but there seems to be a bug in the queries on the homedocument of links.

It is not clear how:
    - The entire length of the link vstream is retrieved, this is because there
      is no working query for link homedocument.

Sometimes the backend will return nonsensical data for nonsensical requests:
    - getting endsets for the entire first vstream of doc 0 worksand strangely
      returns a bunch of 0 spans and specs.

All in all, it looks like the backend has no problem to perform as a single 
threaded hypertext editor storage.

[1] http://www.udanax.com/green/febe/protocol.html

----
"""
    print doc

# vim:set et:
