Lets clarify tumbler math and use of various tumbler types a bit.
Xu88.1 uses tumblers in complex structures with addresses, spans and offsets.

The page
http://udanax.com/green/febe/tumblers.html
provides an example, but nothing formal.
There is no formal implementation, and the one from pyxi is buggy.

Tumblers operations are fairly simple. Most of the magic happens in the
enfilades.

Addition (see Udanax.com example)::

        3.5.10.6 + 2.16.3 = 5.16.3

        25.6.46.93 + 0.0.3.1.21 = 25.6.49.1.21

As you can see, only one digit can be changed at once. With that,
the entire range of positions after it changes; the exact specs of which are not
known without a roundtrip to external storage or other some well defined 
restriction. 

In the addition example a prefixed offset can be seen. 
These leading and trailing zeros are only observed in offset type tumblers.

Substraction can operate on only one digit as well,
any following position must be discarded.
Also, the offset tumbler can only contain one nonzero digit in substraction,
since after discaring there is nothing to substract from (without further
explication of the new subrange). Examples::
    
    1.1 - 0.1 = 1
    1.2 - 0.1 = 1.1
    5.3.2 - 0.1 = 5.2
    1.4.5.7.4.8.9 - 0.0.1 = 1.4.4

There do not seem to be other operations useful at this time. 

