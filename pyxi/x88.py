"""An object-based API to the Udanax 88.1 FeBe protocol."""

# Copyright 1999 by Ka-Ping Yee.  All rights reserved.
# This file is part of the Udanax Green distribution.
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions: 
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software. 
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL Ka-Ping Yee OR Udanax.com BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
# OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR
# THE USE OR OTHER DEALINGS IN THE SOFTWARE. 
# 
# Except as contained in this notice, "Udanax", "Udanax.com", and the
# transcluded-U logo shall not be used in advertising or otherwise to
# promote the sale, use or other dealings in this Software without
# prior written authorization from Udanax.com.

import sys, os, string, socket

# ==================================================== OBJECT TYPES AND I/O

# -------------------------------------------------- helpers for comparison
def cmpid(a, b):
    """Compare two objects by their Python id."""
    if id(a) > id(b): return 1
    if id(a) < id(b): return -1
    return 0

def istype(klass, object):
    """Return whether an object is a member of a given class."""
    try: raise object
    except klass: return 1
    except: return 0

# ------------------------------------------------------------- basic types
def Number_write(data, stream):
    """Write a number to an 88.1 protocol stream."""
    stream.write("%d~" % data)

def Number_read(stream):
    """Read a number from an 88.1 protocol stream."""
    number = 0
    chunk = stream.readchunk()
    return string.atoi(chunk)

def String_write(data, stream):
    """Write a string to an 88.1 protocol stream."""
    stream.write("t%d~" % len(data))
    stream.write(data)

def String_read(stream):
    """Read a string from an 88.1 protocol stream."""
    ch = stream.read(1)
    if ch != "t":
        raise ValueError, "starting flag missing in string read"
    length = Number_read(stream)
    return stream.read(length)

def Content_read(stream):
    """Read a string or a link from an 88.1 protocol stream."""
    ch = stream.read(1)
    if ch == "t":
        length = Number_read(stream)
        return stream.read(length)
    elif ch in string.digits:
        return Address_read(stream, ch)
    else:
        raise ValueError, "bad char \\x%x in content read" % ord(ch)

# ----------------------------------------------------------------- Tumbler
def strl(longnum):
    """Convert a long integer to a string without the trailing L."""
    return str(longnum)[:-1]

class Tumbler:
    """A numbering system that permits addressing within documents
    so that material may be inserted at any point without renumbering."""

    def __init__(self, *args):
        """Construct from a list of tumbler digits or a string."""
        if len(args) == 1 and type(args[0]) is type("a"):
            self.digits = map(string.atol, string.split(args[0], "."))
        else:
            if len(args) == 1 and type(args[0]) is type([]):
                digits = args[0]
            else:
                digits = list(args)
            for digit in digits:
                if type(digit) not in [type(1), type(1L)]:
                    raise TypeError, repr(digits) + \
                        "is not a string or list of integers"
            self.digits = map(long, digits)

    def __repr__(self):
        """Return a Python expression which will reconstruct this tumbler."""
        return self.__class__.__name__ + \
            "(" + string.join(map(repr, self.digits), ", ") + ")"

    def __str__(self):
        """Return the period-separated string representation of the tumbler."""
        return string.join(map(strl, self.digits), ".")

    def __getitem__(self, index):
        return self.digits[index]

    def __len__(self):
        return len(self.digits)

    def __nonzero__(self):
        for digit in self.digits:
            if digit != 0: return 1
        return 0

    def __add__(self, other):
        for i in range(len(self)):
            if other[i] != 0:
                return Tumbler(self.digits[:i] +
                               [self[i] + other[i]] +
                               other.digits[i+1:])
        for i in range(len(self), len(other)):
            if other[i] != 0:
                return Tumbler(self.digits + other.digits[len(self):])
        return Tumbler(self.digits)

    def __sub__(self, other):
        for i in range(min(len(self), len(other))):
            if self[i] < other[i]:
                raise ValueError, "%s is larger than %s" % (other, self)
            if self[i] > other[i]:
                return Tumbler([0] * i +
                               [self[i] - other[i]] +
                               self.digits[i+1:])
        if len(self) < len(other):
            raise ValueError, "%s is larger than %s" % (other, self)
        if len(self) > len(other):
            return Tumbler([0] * len(other) +
                           self.digits[len(other):])
        return NOWIDTH

    def __cmp__(self, other):
        """Compare two address tumblers or offset tumblers."""
        if not istype(Tumbler, other): return cmpid(self, other)
        for i in range(min(len(self), len(other))):
            if self[i] > other[i]: return 1
            if self[i] < other[i]: return -1
        if len(other) > len(self): return 1
        if len(other) < len(self): return -1
        return 0

    def __hash__(self):
        return hash(str(self))

    def write(self, stream):
        """Write a tumbler to an 88.1 protocol stream."""
        exp = 0
        for exp in range(len(self.digits)):
            if self.digits[exp] != 0: break
        dump = "%d" % exp
        for digit in self.digits[exp:]:
            dump = dump + "." + strl(digit)
        stream.write(dump + "~")

def Tumbler_read(stream, prefix=""):
    """Read a tumbler from an 88.1 protocol stream."""
    chunk = prefix + stream.readchunk()
    digits = map(string.atol, string.split(chunk, "."))
    if not digits:
        raise ValueError, "exponent missing in tumbler read"
    digits[:1] = [0L] * int(digits[0])
    return Tumbler(digits)

# ----------------------------------------------------------------- Address
class Address(Tumbler):
    """An address within the Udanax object space.  Immutable."""

    def __add__(self, offset):
        """Add an offset to a tumbler."""
        if not istype(Offset, offset):
            raise TypeError, "%s is not an offset" % repr(offset)
        return Address(Tumbler.__add__(self, offset).digits)

    def __sub__(self, address):
        """Subtract a tumbler from another tumbler to get an offset."""
        if not istype(Address, address):
            raise TypeError, "%s is not an address" % repr(address)
        return Offset(Tumbler.__sub__(self, address).digits)

    def split(self):
        """For a global address, return the docid and local components."""
        delim = len(self.digits) - 1
        while self.digits[delim] != 0: delim = delim - 1
        return Address(self.digits[:delim]), Address(self.digits[delim+1:])

    def globalize(self, other):
        """Return an global address given a local address into this one, a
        global width given a local width, or global span given a local span."""
        if istype(Address, other):
            return Address(self.digits + [0] + other.digits)
        if istype(Offset, other):
            return Offset([0] * len(self.digits) + [0] + other.digits)
        if istype(Span, other):
            return Span(self.globalize(other.start),
                        self.globalize(other.width))
        raise TypeError, "%s is not an address, offset, or span" % repr(other)

    def localize(self, other):
        """Return a local address given a global address under this one, a
        local width given a global width, or local span given a global span."""
        if istype(Address, other):
            if len(other) > len(self) and \
               self.digits[:len(self)] + [0] == other.digits[:len(self)+1]:
                return Address(other.digits[len(self)+1:])
            else:
                raise ValueError, "%s is not within %s" % (other, self)
        if istype(Offset, other):
            if [0] * len(self) + [0] == other.digits[:len(self)+1]:
                return Offset(other.digits[len(self)+1:])
            else:
                raise ValueError, "%s extends outside of %s" % (other, self)
        if istype(Span, other):
            return Span(self.localize(other.start),
                        self.localize(other.width))
        raise TypeError, "%s is not an address, offset, or span" % repr(other)

def Address_read(stream, prefix=""):
    """Read a tumbler address from an 88.1 protocol stream."""
    return Address(Tumbler_read(stream, prefix).digits)

# ------------------------------------------------------------------ Offset
class Offset(Tumbler):
    """An offset between addresses in the Udanax object space.  Immutable."""

    def __add__(self, offset):
        """Add an offset to an offset."""
        if not istype(Offset, offset):
            raise TypeError, "%s is not an offset" % repr(offset)
        return Offset(Tumbler.__add__(self, offset).digits)

    def __sub__(self, offset):
        """Subtract a tumbler from another tumbler to get an offset."""
        if not istype(Offset, offset):
            raise TypeError, "%s is not an offset" % repr(offset)
        return Offset(Tumbler.__sub__(self, offset).digits)

def Offset_read(stream):
    """Read a tumbler offset from an 88.1 protocol stream."""
    return Offset(Tumbler_read(stream).digits)

# -------------------------------------------------------------------- Span
class Span:
    """A range of Udanax objects in the global address space.  Immutable."""

    def __init__(self, start, other):
        """Construct from either a starting and ending address, or
        a starting address and a width offset."""
        if not istype(Address, start):
            raise TypeError, "%s is not an address" % repr(start)
        self.start = start
        if istype(Address, other):
            self.width = other - start
        elif istype(Offset, other):
            self.width = other
        else:
            raise TypeError, "%s is not an address or offset" % repr(other)

    def __repr__(self):
        return "Span(" + repr(self.start) + ", " + repr(self.width) + ")"

    def __str__(self):
        return "<Span at " + str(self.start) + " for " + str(self.width) + ">"

    def __len__(self):  
        return self.width

    def __nonzero__(self):
        return self.width and 1 or 0

    def __cmp__(self, other):
        """Compare two spans (first by starting address, then by width)."""
        if not istype(Span, other): return cmpid(self, other)
        cmp = self.start.__cmp__(other.start)
        if cmp != 0: return cmp
        return self.width.__cmp__(other.width)

    def __hash__(self):
        return hash((self.start, self.width))

    def __and__(self, span):
        """Return the intersection of this span with another span."""
        if istype(VSpan, span):
            span = span.globalize()
        elif not istype(Span, span):
            raise TypeError, "%s is not a span" % repr(span)
        if self.start in span:
            if self.end in span:
                return Span(self.start, self.width)
            else:
                return Span(self.start, span.end())
        elif self.end() in span:
            return Span(span.start, self.end())
        elif span.start in self:
            return Span(span.start, span.width)
        else:
            return Span(NOWHERE, NOWIDTH)

    def contains(self, spec):
        """Return true if the given spec lies entirely within this span."""
        if istype(Address, spec):
            return self.start <= spec < self.end()
        elif istype(Span, spec):
            return self.start <= spec.start <= spec.end() <= self.end()
        elif istype(VSpan, spec):
            return self.contains(spec.globalize())
        else:
            raise TypeError, "%s is not an address or span" % repr(spec)

    def write(self, stream):
        """Write a span to an 88.1 protocol stream."""
        self.start.write(stream)
        self.width.write(stream)

    def end(self):
        """Return the first address after the start not in this span."""
        return self.start + self.width

    def localize(self):
        """Return this span as a vspan within one document."""
        docid, local = self.start.split()
        return VSpan(docid, docid.localize(self))

def Span_read(stream):
    """Read a span from an 88.1 protocol stream."""
    start = Address_read(stream)
    width = Offset_read(stream)
    return Span(start, width)

# ------------------------------------------------------------------- VSpan
class VSpan:
    """A range within a given document.  Immutable."""

    def __init__(self, docid, span):
        """Construct from a document id and a local span."""
        if not istype(Address, docid):
            raise TypeError, "%s is not a document address" % repr(docid)
        if not istype(Span, span):
            raise TypeError, "%s is not a span" % repr(span)
        self.docid = docid
        self.span = span

    def __repr__(self):
        return "VSpan(" + repr(self.docid) + ", " + repr(self.span) + ")"

    def __str__(self):
        return "<VSpan in %s at %s for %s>" % (
            self.docid, self.span.start, self.span.width)

    def __cmp__(self, other):
        """Compare two vspans (first by document address, then by span)."""
        if not istype(VSpan, other): return cmpid(self, other)
        cmp = self.docid.__cmp__(other.docid)
        if cmp != 0: return cmp
        return self.span.__cmp__(other.span)

    def __hash__(self):
        return hash((self.docid, self.span))

    def __and__(self, span):
        """Return the intersection of this span with another span."""
        return self.globalize() & span
    
    def start(self):
        return self.docid.globalize(self.span.start)

    def end(self):
        return self.docid.globalize(self.span.end())

    def contains(self, spec):
        """Return true if the given spec lies entirely within this span."""
        return self.globalize().contains(spec)

    def globalize(self):
        """Return this vspan as a span with a global starting address
        and width within this document."""
        return Span(self.docid.globalize(self.span.start),
                    self.docid.globalize(self.span.width))

# ------------------------------------------------------------------- VSpec
class VSpec:
    """A set of ranges within a given document.  Immutable."""

    def __init__(self, docid, spans):
        """Construct from a document address and a list of spans."""
        if not istype(Address, docid):
            raise TypeError, "%s is not a tumbler address" % repr(docid)
        if type(spans) not in (type([]), type(())):
            raise TypeError, "%s is not a sequence of spans" % repr(spans)
        for span in spans:
            if not istype(Span, span):
                raise TypeError, "%s is not a sequence of spans" % repr(spans)
        self.docid = docid
        spanlist = list(spans)
        spanlist.sort()
        self.spans = tuple(spanlist)

    def __repr__(self):
        return "VSpec(" + repr(self.docid) + ", " + repr(self.spans) + ")"

    def __str__(self):
        spans = []
        for span in self.spans:
            spans.append(", at %s for %s" % (span.start, span.width))
        return "<VSpec in " + str(self.docid) + string.join(spans, "") + ">"

    def __getitem__(self, index):
        return VSpan(self.docid, self.spans[index])

    def __len__(self):
        return len(self.spans)

    def __cmp__(self, other):
        """Compare two vspans (first by document address, then by span)."""
        cmp = self.docid.__cmp__(other.docid)
        if cmp != 0: return cmp
        for i in range(min(len(self), len(other))):
            cmp = self.spans[i].__cmp__(other.spans[i])
            if cmp != 0: return cmp
        if len(self) > len(other): return 1
        if len(self) < len(other): return -1
        return 0

    def __hash__(self):
        return hash((self.docid, self.spans))

    def contains(self, spec):
        """Return true if the given spec lies entirely within this spec."""
        for vspan in self:
            if vspan.contains(spec): return 1
        return 0

    def write(self, stream):
        """Write a vspec to an 88.1 protocol stream."""
        self.docid.write(stream)
        Number_write(len(self.spans), stream)
        for span in self.spans:
            span.write(stream)

def VSpec_read(stream):
    """Read a vspec from an 88.1 protocol stream."""
    docid = Address_read(stream)
    nspans = Number_read(stream)
    spans = []
    for j in range(nspans):
        spans.append(Span_read(stream))
    return VSpec(docid, spans)

# ----------------------------------------------------------------- SpecSet
class SpecSet:
    """A possibly discontinuous set of Udanax objects.  Mutable."""

    def __init__(self, *args):
        """Construct from a list of spans or vspecs."""
        if len(args) > 0 and type(args[0]) is type([]):
            specs = args[0]
        else:
            specs = list(args)

        self.specs = []
        for spec in specs:
            if istype(Span, spec) or istype(VSpec, spec):
                self.specs.append(spec)
            elif istype(VSpan, spec):
                self.specs.append(VSpec(spec.docid, [spec.span]))
            else:
                raise TypeError, "%s is not a list of specs" % repr(args)

    def __repr__(self):
        return "SpecSet(" + repr(self.specs) + ")"

    def __str__(self):
        return "<SpecSet [" + string.join(map(str, self.specs), ", ") + "]>"

    def __len__(self):
        return len(self.specs)

    def __getitem__(self, index):
        return self.specs[index]

    def __cmp__(self, other):
        """Compare two specsets (stably, but only useful for equality)."""
        for i in range(min(len(self.specs), len(other.specs))):
            cmp = self[i].__cmp__(other[i])
            if cmp != 0: return cmp
        if len(self) > len(other): return 1
        if len(self) < len(other): return -1
        return 0

    def clear(self):
        self.specs = []

    def append(self, spec):
        if not istype(Span, spec) and not istype(VSpec, spec):
            raise TypeError, "%s is not a span or a vspec" % spec
        self.specs.append(spec)
        
    def write(self, stream):
        """Write a specset to an 88.1 protocol stream."""
        stream.write("%d~" % (len(self.specs)))
        for spec in self.specs:
            if istype(Span, spec):
                stream.write("s~")
                spec.write(stream)
            elif istype(VSpec, spec):
                stream.write("v~")
                spec.write(stream)

def SpecSet_read(stream):
    """Read a specset from an 88.1 protocol stream."""
    nspecs = Number_read(stream)
    specs = []
    for i in range(nspecs):
        ch = stream.read(2)
        if ch[1] not in "~\n":
            raise ValueError, "bad char \\x%x in specset read" % ord(ch[1])
        if ch[0] == "s":
            specs.append(Span_read(stream))
        elif ch[0] == "v":
            specs.append(VSpec_read(stream))
        else:
            raise ValueError, "bad flag \\x%x in specset read" % ord(ch[1])
    return SpecSet(specs)


# ================================================== MAIN SESSION INTERFACE

# --------------------------------------------------------------- constants
# addresses
NOWHERE = Address()

# spans
NOWIDTH = Offset()

# specifiers
NOSPECS = SpecSet([])

# exceptions
XuError = "UdanaxError"

# access modes
(READ_ONLY, READ_WRITE) = (1, 2)

# copy modes
(CONFLICT_FAIL, CONFLICT_COPY, ALWAYS_COPY) = (1, 2, 3)

# link ends
(LINK_SOURCE, LINK_TARGET, LINK_TYPE) = (1, 2, 3)

# conventional link type addresses
LINK_DOCID = Address(1, 1, 0, 1, 0, 2)
JUMP_TYPE = VSpec(LINK_DOCID, [Span(Address(2, 1), Offset(0, 1))])
QUOTE_TYPE = VSpec(LINK_DOCID, [Span(Address(2, 2), Offset(0, 1))])
FOOTNOTE_TYPE = VSpec(LINK_DOCID, [Span(Address(2, 3), Offset(0, 1))])
MARGIN_TYPE = VSpec(LINK_DOCID, [Span(Address(2, 4), Offset(0, 1))])

LINK_TYPES = [JUMP_TYPE, QUOTE_TYPE, FOOTNOTE_TYPE, MARGIN_TYPE]
TYPE_NAMES = {JUMP_TYPE: "jump", QUOTE_TYPE: "quote",
              FOOTNOTE_TYPE: "footnote", MARGIN_TYPE: "margin"}

TYPES_BY_NAME = {}
for spec in LINK_TYPES:
    TYPES_BY_NAME[TYPE_NAMES[spec]] = spec

# ------------------------------------------------------------------ XuConn
class XuConn:
    """Methods for sending and receiving objects on a stream.  The
    stream must implement the three methods read, write, and close."""

    def __init__(self, stream):
        self.stream = stream

    def __repr__(self):
        return "<XuConn on %s>" % repr(self.stream)

    # protocol

    def handshake(self):
        """Perform the FeBe protocol handshake to open a session."""
        self.stream.write("\nP0~")
        while 1:
            if self.stream.read(1) == "\n": break
        if self.stream.read(2) != "P0":
            raise ValueError, "back-end does not speak 88.1 protocol"
        if self.stream.read(1) not in "~\n":
            raise ValueError, "back-end does not speak 88.1 protocol"

    def close(self):
        self.stream.close()

    # reading and writing objects

    def Number(self): return Number_read(self.stream)
    def String(self): return String_read(self.stream)
    def Content(self): return Content_read(self.stream)
    def Address(self): return Address_read(self.stream)
    def Offset(self): return Offset_read(self.stream)
    def Span(self): return Span_read(self.stream)
    def VSpec(self): return VSpec_read(self.stream)
    def SpecSet(self): return SpecSet_read(self.stream)

    def write(self, object):
        """Write to the connection an integer, string, Address, Offset,
        Span, VSpec, SpecSet, or list of such objects."""
        if type(object) is type(1):
            Number_write(object, self.stream)
        elif type(object) is type("a"):
            String_write(object, self.stream)
        elif type(object) is type([]):
            Number_write(len(object), self.stream)
            for item in object: self.write(item)
        else:
            object.write(self.stream)

    # issuing commands

    def command(self, code, *args):
        """Issue a command with the given order code and arguments."""
        Number_write(code, self.stream)
        for arg in args: self.write(arg)
        try:
            response = self.Number()
        except ValueError:
            raise XuError, "error response to %d from back-end" % code
        if response != code:
            raise XuError, "non-matching response to %d from back-end" % code

# --------------------------------------------------------------- XuSession
class XuSession:
    """A session conversing with an Udanax back-end server across an x88
    connection object.  The XuConn must have been just freshly created.
    (We don't create the XuConn here to allow the application to supply
    an instance of a customized subclass of XuConn if it so desires.)"""

    def __init__(self, conn):
        self.xc = conn
        self.xc.handshake()
        self.open = 1

    def __repr__(self):
        if self.open:
            return "<XuSession on %s>" % repr(self.xc.stream)
        else:
            return "<XuSession terminated>"

    # creation and access

    def create_document(self):
        self.xc.command(11)
        return self.xc.Address()

    def create_version(self, docid):
        self.xc.command(13, docid)
        return self.xc.Address()

    def open_document(self, docid, access, copy):
        self.xc.command(35, docid, access, copy)
        return self.xc.Address()

    def close_document(self, docid):
        self.xc.command(36, docid)

    def create_link(self, docid, sourcespecs, targetspecs, typespecs):
        self.xc.command(27, docid, sourcespecs, targetspecs, typespecs)
        return self.xc.Address()

    # content retrieval

    def retrieve_vspan(self, docid):
        self.xc.command(14, docid)
        return VSpan(docid, self.xc.Span())

    def retrieve_vspanset(self, docid):
        self.xc.command(1, docid)
        spans = []
        for i in range(self.xc.Number()):
            spans.append(self.xc.Span())
        return VSpec(docid, spans)

    def retrieve_contents(self, specset):
        self.xc.command(5, specset)
        data = []
        for i in range(self.xc.Number()):
            data.append(self.xc.Content())
        return data

    def retrieve_endsets(self, specset):
        self.xc.command(28, specset)
        sourcespecs = self.xc.SpecSet()
        targetspecs = self.xc.SpecSet()
        typespecs = self.xc.SpecSet()
        return sourcespecs, targetspecs, typespecs

    # connection retrieval

    def find_links(self, sourcespecs, targetspecs=NOSPECS,
                         typespecs=NOSPECS, homedocids=[]):
        self.xc.command(30, sourcespecs, targetspecs, typespecs, homedocids)
        links = []
        for i in range(self.xc.Number()):
            links.append(self.xc.Address())
        return links
    
    def follow_link(self, linkid, linkend):
        try:
            self.xc.command(18, linkend, linkid)
        except XuError:
            return NOSPECS
        else:
            return self.xc.SpecSet()

    def compare_versions(self, specseta, specsetb):
        self.xc.command(10, specseta, specsetb)
        sharedspans = []
        for i in range(self.xc.Number()):
            starta, startb = self.xc.Address(), self.xc.Address()
            width = self.xc.Offset()
            doca, locala = starta.split()
            docb, localb = startb.split()
            sharedspans.append(VSpan(doca, Span(locala, width)),
                               VSpan(docb, Span(localb, width)))
        return collapse_sharedspans(sharedspans)

    def find_documents(self, specset):
        self.xc.command(22, specset)
        docids = []
        for i in range(self.xc.Number()):
            docids.append(self.xc.Address())
        return docids

    # editing

    def insert(self, docid, vaddr, strings):
        self.xc.command(0, docid, vaddr, strings)

    def vcopy(self, docid, vaddr, specset):
        self.xc.command(2, docid, vaddr, specset)

    def delete(self, docid, start, end):
        self.xc.command(3, docid, [start, end])

    def pivot(self, docid, start, pivot, end):
        self.xc.command(3, docid, [start, pivot, end])

    def swap(self, docid, starta, enda, startb, endb):
        self.xc.command(3, docid, [starta, enda, startb, endb])

    def remove(self, docid, vspan):
        self.xc.command(12, docid, vspan)

    # session control

    def quit(self):
        self.xc.command(16)
        self.xc.close()
        self.open = 0

    # administration

    def account(self, acctid):
        self.xc.command(34, acctid)

    def create_node(self, acctid):
        self.xc.command(38, acctid)
        return self.xc.Address()


def collapse_sharedspans(sharedspans):
    """The results of a comparison are sometimes returned from the back-end
    with several adjacent spans that could be collapsed into a single span.
    This routine tries to work around that limitation."""
    result = []
    enda, endb = None, None
    for spana, spanb in sharedspans:
        starta, startb = spana.start(), spanb.start()
        width = spana.span.width
        doca, locala = spana.docid, spana.span.start
        docb, localb = spanb.docid, spanb.span.start
        if starta == enda and startb == endb: # collapse with last span
            width = lastwidth + width
            spana = VSpan(doca, Span(lastlocala, width))
            spanb = VSpan(docb, Span(lastlocalb, width))
            result[-1:] = [(spana, spanb)]
        else:
            lastlocala, lastlocalb = locala, localb
            spana = VSpan(doca, Span(locala, width))
            spanb = VSpan(docb, Span(localb, width))
            result.append((spana, spanb))
        enda, endb = spana.end(), spanb.end()
        lastwidth = width
    return result

# ================================ STREAMS OVER WHICH TO HOLD FEBE SESSIONS

class XuStream:
    """Abstract class specifying the stream interface."""
    def __init__(self, *args):
        raise TypeError, "abstract class cannot be instantiated"

    def read(self, length): pass
    def write(self, data): pass
    def close(self): pass

    def readchunk(self):
        chars = []
        while 1:
            ch = self.read(1)
            if not ch: raise XuError, "stream closed prematurely"
            if ch in ['', '\n', '~']: break
            if ch == "?": raise XuError, "error response from back-end"
            chars.append(ch)
        return string.join(chars, '')

# -------------------------------------------------------------- FileStream
class FileStream(XuStream):
    """Stream interface to two file descriptors."""

    def __init__(self, input, output=None):
        if not output: output = input
        self.input = input
        self.output = output
        self.open = 1

    def __repr__(self):
        result = self.__class__.__name__
        if self.open:
            if self.input is not self.output:
                result = result + " from %s" % repr(self.input)
            return "<%s to %s>" % (result, repr(self.output))
        else:
            return "<%s closed>" % result

    def read(self, length):
        return self.input.read(length)

    def write(self, data):
        self.output.write(data)

    def close(self):
        self.input.close()
        if self.output is not self.input: self.output.close()
        self.open = 0

# --------------------------------------------------------------- TcpStream
class TcpStream(XuStream):
    """Stream interface to a TCP connection."""

    def __init__(self, hostname, port):
        self.host = hostname
        self.port = port
        self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.socket.connect(hostname, port)
        self.open = 1

    def __repr__(self):
        result = self.__class__.__name__
        if self.open:
            return "<%s to %s port %d>" % (result, self.host, self.port)
        else:
            return "<%s closed>" % result

    def read(self, length):
        return self.socket.recv(length)

    def write(self, data):
        self.socket.send(data)

    def close(self):
        self.socket.close()
        self.open = 0

# -------------------------------------------------------------- PipeStream
class PipeStream(XuStream):
    """Stream interface to a piped shell command."""

    def __init__(self, command):
        self.fifo = "pyxi.%d" % os.getpid()
        try: os.unlink(self.fifo)
        except: pass
        os.mkfifo(self.fifo)

        self.command = command
        self.inpipe = os.popen(command + " < " + self.fifo)
        self.outpipe = open(self.fifo, "w")
        self.open = 1

    def __repr__(self):
        result = self.__class__.__name__
        if self.open:
            return "<%s to %s>" % (result, self.command)
        else:
            return "<%s closed>" % result

    def __del__(self):
        os.unlink(self.fifo)

    def read(self, length):
        return self.inpipe.read(length)

    def write(self, data):
        self.outpipe.write(data)
        self.outpipe.flush()

    def close(self):
        self.inpipe.close()
        self.outpipe.close()
        try: os.unlink(self.fifo)
        except: pass
        self.open = 0

# ====================================================== DEBUGGING WRAPPERS
def shortrepr(object):
    if type(object) is type([]):
        return "[" + string.join(map(shortrepr, object), ", ") + "]"
    elif type(object) is type(()):
        return "(" + string.join(map(shortrepr, object), ", ") + ")"
    elif type(object) is type(''):
        if len(object) > 20: return repr(object[:20]) + "..."
        else: return repr(object)
    else:
        return str(object)

debugindent = {}
debugmidline = {}

class MethodWrapper:
    def __init__(self, name, method, base, log):
        self.name = name
        self.method = method
        self.base = base
        self.log = log

    def __call__(self, *args):
        indent = debugindent[self.log]
        if debugmidline[self.log]:
            self.log.write("\n")

        self.log.write("%s%s \x1b[32m%s\x1b[0m%s: " %
                       (indent, repr(self.base), self.name, shortrepr(args)))
        self.log.flush()
        debugmidline[self.log] = 1

        debugindent[self.log] = indent + "  "

        try:
            result = apply(self.method, args)

            if not debugmidline[self.log]:
                basename = self.base.__class__.__name__
                self.log.write("%s%s.\x1b[32m%s\x1b[0m: " %
                               (indent, basename, self.name))
            self.log.write("\x1b[36m%s\x1b[0m\n" % shortrepr(result))
            self.log.flush()
            debugmidline[self.log] = 0

        finally:
            debugindent[self.log] = indent
        return result

class DebugWrapper:
    def __init__(self, base, log):
        self.__dict__["__base__"] = base
        self.__dict__["__log__"] = log
        if not debugindent.has_key(log):
            debugindent[log] = ""
            debugmidline[log] = 0

    def __getattr__(self, name):
        base = self.__dict__["__base__"]
        log = self.__dict__["__log__"]
        value = getattr(base, name)
        if callable(value) and name[:2] != "__":
            return MethodWrapper(name, value, base, log)
        else:
            return value

    def __setattr__(self, name, value):
        base = self.__dict__["__base__"]
        setattr(base, name, value)
                
# =============================================================== FUNCTIONS
def tcpconnect(hostname, port):
    return XuSession(XuConn(TcpStream(hostname, port)))

def pipeconnect(command):
    return XuSession(XuConn(PipeStream(command)))
   
def testconnect():
    return XuSession(XuConn(FileStream(sys.stdin, sys.stdout)))
