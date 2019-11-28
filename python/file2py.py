#---License---
#This is free and unencumbered software released into the public domain.

#Anyone is free to copy, modify, publish, use, compile, sell, or
#distribute this software, either in source code form or as a compiled
#binary, for any purpose, commercial or non-commercial, and by any
#means.

#---Description---
#convert file into an importable module

#---code---
import os
import sys
import getopt

__doc__ = """
convert file into an importable module

file2py.py foobar.dat >foobar.py

extract from python  :

import file2py #foobar
f = file("foobar.dat", "wb")
f.write(foobar.data.decode("base64").decode("zlib"))
"""
def main(args):
    if not args or ("-h" in args):
        print __doc__
        return

    try:
        opts, fileArgs = getopt.getopt(args, "")
    except getopt.GetoptError:
        print __doc__
        return

    f = file(fileArgs[0], "rb")
    buff = f.read()
    print "data = %s%s%s" % ('"""', buff.encode("zlib").encode("base64"), '"""')

if __name__ == "__main__":
    main(sys.argv[1:])
