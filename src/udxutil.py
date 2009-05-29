import sys
import x88


# common vaddrs
v_start = x88.Address("0.0") # data vaddr's... (1.*)
v_links = x88.Address("1.0")
v_end = x88.Address("2.0") # through link data vaddr's (2.*)
DOC_CONTENTS= x88.Span(v_start, v_links)
DOC_LINKS = x88.Span(v_links, v_end)
ENTIRE_DOC = x88.Span(v_start, v_end)

chatty = 0
mutter_out = sys.stderr

def mutter(lvl, *msg):
    global chatty
    if lvl <= chatty:
        msg = " ".join(map(str, msg))
        print >>mutter_out, msg


