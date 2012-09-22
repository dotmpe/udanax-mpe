Branches
---------
master
    general development
dev_tcpbuffer
    When running pyxi over TCP with the backed tcp wrapper script, it fails to
    return the entire contents but finishes halfway and the rest only reaches
    the frontend upon the next comment.
    My guess is class XuProxy needs some flushing or other options to open the
    sockets, but I do not know what yet. 

    This branch contains a temporary fix that simply loops until the text
    contents are read, even though perhaps the problem could occur with large
    amounts of other data?
