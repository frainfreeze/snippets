#---License---
#This is free and unencumbered software released into the public domain.

#Anyone is free to copy, modify, publish, use, compile, sell, or
#distribute this software, either in source code form or as a compiled
#binary, for any purpose, commercial or non-commercial, and by any
#means.

#---Description---
#This webserver will serve files in the current directory. You can use os.chdir() to change the directory.
#This trick is handy to serve or transfer files between computers on a local network.

#Note that this webserver is pretty fast, but can only serve one HTTP request at time. It's not recommended for high-traffic servers.
#If you want better performance, have a look at asynchronous sockets (asyncore, Medusa...) or multi-thread webservers.

#---code---
import BaseHTTPServer, SimpleHTTPServer
server = BaseHTTPServer.HTTPServer(('',80),SimpleHTTPServer.SimpleHTTPRequestHandler)
server.serve_forever()
