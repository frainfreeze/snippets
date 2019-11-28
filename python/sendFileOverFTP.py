#---License---
#This is free and unencumbered software released into the public domain.

#Anyone is free to copy, modify, publish, use, compile, sell, or
#distribute this software, either in source code form or as a compiled
#binary, for any purpose, commercial or non-commercial, and by any
#means.

#by frainfreeze

#---Description---
#sends file over FTP using ftplib


#---code---
import ftplib
session = ftplib.FTP('myserver.com','login','passord')
myfile = open('theFile.txt','rb')
session.storbinary('STOR theFile.txt', myfile)
myfile.close()
session.quit()
