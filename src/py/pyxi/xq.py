#!/usr/bin/env python
"""xq - Query the Xanadu backend, an exercise
"""
import x88
import sys, getopt, os


def warn(message):
    sys.stderr.write(message + "\n")

def main(argv):
    opts, args = getopt.getopt(argv[1:], "dt:a:")

    # defaults opt values
    tcp_addr = ()
    debug = 0
    doc_addr = "1.1.0.1.0.1"

    for opt in opts:
        if opt[0] == '-d':
            debug = True
        elif opt[0] == '-t':
            host, port = opt[1].split(':')
            tcp_addr = host, int(port)
        elif opt[0] == '-h':
            # todo: usage
            pass
        elif opt[0] == '-a':
            doc_addr = opt[1]

    os.chdir('bin/be')

    # get Xu session
    if debug and tcp_addr:
        ps = x88.DebugWrapper(x88.TcpStream(*tcp_addr), sys.stderr)
        xc = x88.DebugWrapper(x88.XuConn(ps), sys.stderr)
        xs = x88.DebugWrapper(x88.XuSession(xc), sys.stderr)

    elif debug:
        ps = x88.DebugWrapper(x88.PipeStream("./backend"), sys.stderr)
        xc = x88.DebugWrapper(x88.XuConn(ps), sys.stderr)
        xs = x88.DebugWrapper(x88.XuSession(xc), sys.stderr)

    elif tcp_addr:
        xs = x88.tcpconnect(*tcp_addr)

    else:
        xs = x88.pipeconnect("./backend")

    #addr = testcreatelink(xs)
    #tryout(xs, doc_addr)
    test2(xs, doc_addr)

def testcreatelink(xs):
    addr = xs.create_document()
    xs.open_document(
        addr, x88.READ_WRITE, x88.CONFLICT_FAIL)

    vaddr = x88.Address(1, 1)
    xs.insert(addr, vaddr, ["These are the first chars", "And this second string has some more"])

    # link type is a VSpec here, not a set
    srcspan = x88.Span(vaddr, x88.Offset(0, 2))
    #srcspan = x88.VSpan(addr, srcspan)
    srcset = x88.SpecSet(x88.VSpec(addr, [srcspan]))
    trgtspan = x88.Span(x88.Address(1, 5), x88.Offset(0, 2))
    trgtset = x88.SpecSet(x88.VSpec(addr, [trgtspan]))

    typeset = x88.SpecSet(x88.JUMP_TYPE)
    l1 = xs.create_link(addr, srcset, trgtset, typeset)
    print '> 27', addr, srcset, trgtset, typeset
    print '<', l1

    # link type is a document
    type = x88.SpecSet(x88.VSpec(x88.Address("1.1.0.1.0.1"), []))
    l2 = xs.create_link(addr, srcset, trgtset, type)
    print '> 27', addr, srcset, trgtset, type
    print '<', l2

    trgtset = x88.SpecSet(x88.VSpec(addr))
    l3 = xs.create_link(addr, srcset, trgtset, type)
    print '> 27', addr, srcset, trgtset, type
    print '<', l3

    xs.close_document(addr)

    return addr

def tryout(xs, doc_addr):
    if not isinstance(doc_addr, x88.Address):
        doc_addr = x88.Address(doc_addr)

    # try some stuff...
    docid = xs.open_document(doc_addr, x88.READ_WRITE, x88.CONFLICT_COPY)
    print docid

    print
    # first, retrievev on the following two tumblers
    tumbler_start = x88.Address("2.1") # character vaddr's
    tumbler_end = x88.Address("2.2")
    span_1 = x88.Span(tumbler_start, tumbler_end) # adress characters 1,2,3

    # retrievev returns all contents given by the set of spans
    print 'examining span', span_1, 'for doc', doc_addr

    spec_1 = x88.VSpec(doc_addr, [span_1])
    specset = x88.SpecSet(spec_1)
    data = xs.retrieve_contents(specset)
    print '> retrievev', specset
    print '<', data

    # strangeness...
    tumbler_start = x88.Address("0")
    tumbler_end = x88.Address("0")
    span_1 = x88.Span(tumbler_start, tumbler_end)
    spec_1 = x88.VSpec(doc_addr, [span_1])
    specset = x88.SpecSet(spec_1)
    data = xs.retrieve_contents(specset)
    print '> retrievev', specset
    print '<', data

    print
    # another valid retrievev
    tumbler_start = x88.Address("1.0") # character vaddr's... (1.*)
    tumbler_end = x88.Address("2.0") # through link vaddr's (2.*)
    span_1 = x88.Span(tumbler_start, tumbler_end)

    print 'examening span', span_1, 'for doc', doc_addr

    spec_1 = x88.VSpec(doc_addr, [span_1])
    specset = x88.SpecSet(spec_1)
    data = xs.retrieve_contents(specset)
    print '> retrieve-v', specset
    print '<', data

    print
    
    """now retrieve the vspan for the document: """

    vspan = xs.retrieve_vspan(doc_addr)
    print '> retrieve-doc-vspan', doc_addr
    print '<', vspan
    # use it to retrieve document contents
    #specset = x88.SpecSet(x88.VSpec(doc_addr, [vspan.span]))
    #data = xs.retrieve_contents(specset)
    #print '> retrieve-v', specset
    #print '<', data
    # tadaa! same result as before, but no a priori knowledge except of the doc addr

    # previous retrieve-doc-vspan retrieved a span which indicated either only
    # the number of characters or the number of links present in a single vspan
    # retrieve-doc-vspanset returns any one of these vspans seperately in a vspec
    vspec = xs.retrieve_vspanset(doc_addr)
    print '> retrieve-doc-vspanset', doc_addr
    print '<', vspec

    #addr = x88.Address("1.1.0.1")
    #vspan = x88.Span(addr, x88.Offset("2.0"))
    #for vspan in vspec:
    #    print xs.retrieve_contents(x88.SpecSet(x88.VSpec(addr, [vspan.span])))

    # insert and delete spans
    #print
    #tumbler_start = x88.Tumbler("1.8")
    #print xs.insert(doc_addr, tumbler_start, [' '])

    #tumbler_start = x88.Address("1.1")
    #tumbler_end = x88.Address("1.8")
    #vspan = x88.Span(tumbler_start, tumbler_end)
    #print vspan
    #xs.remove(doc_addr, vspan)


    print
    print
    # gitz
    vsp = xs.retrieve_vspanset(docid)
    for vspan in vsp:
        if vspan.span.start[0] == 1:
            textspec = x88.SpecSet(x88.VSpec(docid, [vspan.span]))
            #contents = xs.retrieve_contents(textspec)
            #print contents
            srcspecs, trgtspecs, tpspecs = xs.retrieve_endsets(textspec)
            data = xs.find_links(srcspecs)
            #print '> find-links-from-to-three', srcspecs
            data += xs.find_links(x88.NOSPECS, trgtspecs)
            #print '> find-links-from-to-three', trgtspecs
            data += xs.find_links(x88.NOSPECS, x88.NOSPECS, tpspecs)
            #print '> find-links-from-to-three', tpspecs
            #print '<', data

            for laddr in data:
                srcspecs = xs.follow_link(laddr, x88.LINK_SOURCE)
                trgtspecs = xs.follow_link(laddr, x88.LINK_TARGET)
                tpspecs = xs.follow_link(laddr, x88.LINK_TYPE)
                print '> follow-link', laddr
                print '<', srcspecs
                print '<', trgtspecs
                print '<', tpspecs

        elif vspan.span.start[0] == 2:
            print 'link span', vspan
        else:
            print 'ignoring invalid? span:', vspan

    xs.close_document(docid)

    print
    # find-docs-containing | 22
    # find docs (versions) from 0 through 10 in doc_addr
    tumbler_start = x88.Address("0")
    tumbler_end = x88.Address("10")
    span_1 = x88.Span(tumbler_start, tumbler_end)
    spec_1 = x88.VSpec(docid, [span_1])
    specset = x88.SpecSet(spec_1)
    data = xs.find_documents(specset)
    print '> find-docs-containing', specset
    print '<', data
    print
    for addr in data:
        xs.open_document(addr, x88.READ_ONLY, x88.CONFLICT_FAIL)
        print '> retrieve-doc-vspan', addr
        print '<', xs.retrieve_vspan(addr)
        print
        print '> retrieve-doc-vspanset', addr
        print '<', xs.retrieve_vspanset(addr)
        xs.close_document(addr)


def test2(xs, doc_addr):
    """
    I found these non-documented commands in pyxu/green,
    a list like that turns out to be in green/be_source/requests.h.

    Rush's list is longer, the Green source I have goes to command 38.
    
    Command nr/function maps appears to be in init.c, but it does not list 40 or
    41, which are outside NREQUESTS (=40) anyway.
    The diagnostic commands seem to be unavailable looking at be_source/init.c
    """
    print xs, doc_addr

    # incomplete
    #print xs.xc.stream.read(5) # RETRIEVEV, documented
    #xs.xc.command(4) #
    #xs.xc.command(39) # nullfun -> putrequestfailed
    #xs.xc.command(40) # DUMP_GRAN?
    #xs.xc.command(41) # DUMP_SPAN?
    #xs.xc.command(42) # Green does not go beyond 39..

    # error
    #xs.xc.command(15) # debug
    #xs.xc.command(17) # dump enfilade
    #xs.xc.command(24) # JUSTEXIT
    #xs.xc.command(20) # EXAMINE
    #xs.xc.command(23) # DUMPGRANFWIDS
    #xs.xc.command(25) # IOINFO

    #docid = xs.open_document(x88.Address(doc_addr), x88.READ_WRITE, x88.CONFLICT_COPY)
    #xs.close_document(docid)

if __name__ == '__main__':
    import sys
    sys.exit(main(sys.argv))
