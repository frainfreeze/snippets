#---License---
#This is free and unencumbered software released into the public domain.

#Anyone is free to copy, modify, publish, use, compile, sell, or
#distribute this software, either in source code form or as a compiled
#binary, for any purpose, commercial or non-commercial, and by any
#means.

#---Description---
# $ python stringToMD5.py "the string"
# or import and then stringToMD5("the string")
# returns MD5 of given string

#---code---
import hashlib

def stringToMD5(theString):
    print hashlib.md5(theString).hexdigest()
    
if __name__ == "__main__":
    from sys import argv
    script, theString = argv
    main(theString)
