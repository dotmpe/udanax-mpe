"""Experiment wrapping pipestream in TCP server to circumvent backenddeamon bug

limitation: only one pipestream possible at a time.

todo: reinit pipestream after discon
"""

import os
import sys
from x88 import *
import SocketServer


def Protocol_read(stream):
    proto = None
    while 1:
        c = stream.read(1)
        if c in '~\n':
            if proto and len(proto)>1:
                return proto
        elif c == 'P':
            proto = c
        else:
            proto += c

def Protocol_write(stream, p):
    stream.write('\n')
    stream.write(p)
    stream.write('~')

class XuProxy(XuConn):

    def forward_handshake(self):
        str = self.stream
        p = Protocol_read(str)
        if p != "P0":
            raise ValueError, "back-end does not speak 88.1 prototype protocol"
        def perform(be):
            Protocol_write(be.stream, p)
            r = Protocol_read(be.stream)
            Protocol_write(str, r)
        return perform

    def forward_command(self):
        cmd = self.Number()

        if cmd == 0:
            docid = self.Address()
            vaddr = Tumbler_read(self.stream)
            strs = []
            for i in range(self.Number()):
                strs.append(self.Content())
            def perform(be):
                be.command(cmd, docid, vaddr, strs)
                self.write(cmd)

        elif cmd == 1: # retrieve_vspanset
            docid = self.Address()
            def perform(be):
                be.command(cmd, docid)
                spans = []
                for i in range(be.Number()):
                    spans.append(be.Span())

                self.write(cmd)
                self.write(spans)

        elif cmd == 2: # copy
            docid = self.Address()
            vaddr = Tumbler_read(self.stream)
            specset = self.SpecSet()
            def perform(be):
                be.command(cmd, docid, vaddr, specset)
                self.write(cmd)

        elif cmd == 3: # rearrange
            docid = self.Address()
            data = []
            for i in range(self.Number()):
                data.append(Tumbler_read(self.stream))
            def perform(be):
                be.command(cmd, docid, data)
                self.write(cmd)

        elif cmd == 5: # retrieve_contents
            specset = self.SpecSet()
            def perform(be):
                be.command(cmd, specset)
                data = []
                for i in range(be.Number()):
                    data.append(be.Content())
                self.write(cmd)
                self.write(data)

        elif cmd == 10: # show-relations-of-2-versions
            specseta = self.SpecSet()
            specsetb = self.SpecSet()
            def perform(be):
                be.command(cmd, specseta, specsetb)

                self.write(cmd)
                for i in range(be.Number()):
                    starta, startb = be.Address(), be.Address()
                    width = be.Offset()

                    self.write(starta)
                    self.write(startb)
                    self.write(width)

        elif cmd == 11: # create_document
            def perform(be):
                be.command(cmd)
                a = be.Address()
                self.write(cmd)
                self.write(a)

        elif cmd == 12: # remove / delete-vspan
            docid = be.Address()
            span = be.Span()

            vspan = VSpan(docid, span)
            def perform(be):
                be.command(cmd, docid, vspan)
                self.write(cmd)

        elif cmd == 13: # create_version
            docid = self.Address()
            def perform(be):
                be.command(cmd, docid)
                a = be.Address()
                self.write(cmd)
                self.write(a)

        elif cmd == 14: # retrieve_vspan
            docid = self.Address()
            def perform(be):
                be.command(cmd, docid)
                span = be.Span()

                vspan = VSpan(docid, span)
                self.write(cmd)
                vspan.write(self.stream)

        elif cmd == 16: # quit
            def perform(be):
                be.command(cmd)
                self.write(cmd)
                return True

        elif cmd == 18: # follow-link
            linkend = self.Number()
            linkid = self.Address()
            def perform(be):
                try:
                    be.command(cmd, linkend, linkid)
                except XuError:
                    self.write('')
                else:
                    specset = be.SpecSet()
                    self.write(cmd)
                    self.write(specset)

        elif cmd == 22: # find-docs-containing
            specset = self.SpecSet()
            def perform(be):
                be.command(cmd, specset)
                docids = []
                for i in range(be.Number()):
                    docids.append(be.Address())
                self.write(cmd)
                self.write(docids)

        elif cmd == 27: # create_link
            docid = self.Address()
            srcspecs = self.SpecSet()
            trgtspecs = self.SpecSet()
            tpspecs = self.SpecSet()
            def perform(be):
                be.command(cmd, docid, srcspecs, trgtspecs, tpspecs)
                a = be.Address()
                self.write(cmd)
                self.write(a)

        elif cmd == 28: # retrieve-endsets
            specset = self.SpecSet()
            def perform(be):
                be.command(cmd, specset)
                srcspecs = be.SpecSet()
                trgtspecs = be.SpecSet()
                tpspecs = be.SpecSet()
                self.write(cmd)
                self.write(srcspecs)
                self.write(trgtspecs)
                self.write(tpspecs)

        elif cmd == 30: # find-links-from-to-three
            srcspecs = self.SpecSet()
            trgtspecs = self.SpecSet()
            tpspecs = self.SpecSet()
            homedocs = self.SpecSet()
            def perform(be):
                be.command(cmd, srcspecs, trgtspecs, tpspecs, homedocs)
                links = []
                for i in range(be.Number()):
                    links.append(be.Address())
                self.write(cmd)
                self.write(links)

        elif cmd == 34: # x-account
            acctid = self.Address()
            def perform(be):
                be.command(cmd, acctid)
                self.write(cmd)

        elif cmd == 35: # open
            docid = self.Address()
            access = self.Number()
            copy = self.Number()
            def perform(be):
                be.command(cmd, docid, access, copy)
                self.write(cmd)
                self.write(be.Address())

        elif cmd == 36: # close_document
            docid = self.Address()
            def perform(be):
                be.command(cmd, docid)
                self.write(cmd)

        elif cmd == 38: # create-node-or-account
            acctid = self.Address()
            def perform(be):
                be.command(cmd, acctid)
                a = be.Address()

                self.write(cmd)
                self.write(a)

        return perform


class WrappedPipeHandler(SocketServer.BaseRequestHandler):
    def handle(self):
        print 'conn'

        # Get Xanadu 88.1 session
        ps = PipeStream(self.server.backend)

        server = StreamDebug(ps, sys.stderr)
        client = StreamDebug(FileStream(self.request.makefile(mode='a+')), sys.stderr)

        fe = XuProxy(client)
        be = XuConn(server)

        # prep cmd to read protocol from fe
        p = fe.forward_handshake()
        # write handshake to be and answer to fe
        p(be)
        fe.stream.input.flush()

        while 1:
            c = fe.forward_command()
            try:
                r = c(be)
            except XuError:
                fe.stream.write('?')
            fe.stream.input.flush()
            if r:
                break;

        self.request.close()
        ps.close()
        print 'discon'


class StreamDebug:
    readbuf, writebuf = '', ''
    def __init__(self, base, log):
        self.__dict__["__base__"] = base
        self.__dict__["__log__"] = log

    def read(self, length):
        base = self.__dict__["__base__"]
        if self.writebuf:
            self.flush_writebuf()
        r = base.read(length)
        self.readbuf += r
        return r

    def flush_readbuf(self):
        log = self.__dict__["__log__"]
        log.write("\x1b[36m<\x1b[0m %s" % shortrepr(self.readbuf))
        self.readbuf = ''

    def write(self, data):
        base = self.__dict__["__base__"]
        if self.readbuf:
            self.flush_readbuf()
        r = base.write(data)
        self.writebuf += data
        return r

    def flush_writebuf(self):
        log = self.__dict__["__log__"]
        log.write("\x1b[32m>\x1b[0m %s" % shortrepr(self.writebuf))
        self.writebuf = ''

    def __getattr__(self, name):
        base = self.__dict__["__base__"]
        value = getattr(base, name)
        return value

    def __setattr__(self, name, value):
        base = self.__dict__["__base__"]
        setattr(base, name, value)

"""
        # old
        stream = self.server.pipe
        BUFSIZE = 900 # 65536

        # Handshake
        rx = self.request.recv(BUFSIZE)
        stream.write(rx)
        print "\x1b[32m>\x1b[0m %s" % rx.strip()

        while 1:
            if stream.read(1) == "\n": break
        if stream.read(2) != "P0":
            raise ValueError, "back-end does not speak 88.1 protocol"
        if stream.read(1) not in "~\n":
            raise ValueError, "back-end does not speak 88.1 protocol"
        tx = '\nP0~'
        self.request.send(tx)
        print "\x1b[36m<\x1b[0m %s" % tx.strip()

        # continue...
        while stream:
            rx = self.request.recv(BUFSIZE)
            while rx:
                stream.write(rx)
                print "\x1b[32m>\x1b[0m %s" % rx.strip()
                rx = self.request.recv(BUFSIZE)

            tx = stream.readchunk()
            while tx and tx[-1] != '~':
                self.request.send(tx)
                print "\x1b[36m<\x1b[0m %s" % tx.strip()
                tx = stream.readchunk()
"""

if __name__ == "__main__":
    backend = os.path.join('be', 'backend')
    host = "localhost"
    port = 55146

    # Parse argv
    import getopt
    opts, extra = getopt.getopt(sys.argv[1:], "t:b:")
    for o in opts:
        if '-b' in o:
            backend = o[1]
        elif '-t' in o:
            tcp_addr = o[1].split(':')
            host, port = tcp_addr[0], int(tcp_addr[1])

    pyxi_dir = os.path.dirname(sys.argv[0])
    if not os.path.exists(backend): # try...
        backend = os.path.join(pyxi_dir, backend)

    # Check existence of backend, enfilade
    if not os.path.exists(backend):
        print "There is no file at %s.  Please put a copy or a link" % (backend,)
        print "to the server executable there."
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
            print "please copy one from the udanax dist."
            sys.exit(2)

    srv = SocketServer.ThreadingTCPServer((host, port), WrappedPipeHandler)
    srv.backend = be
    srv.serve_forever()
