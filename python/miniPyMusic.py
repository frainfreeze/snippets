#!/usr/bin/python
# -*- coding: iso-8859-1 -*-
#---License---
#This is free and unencumbered software released into the public domain.

#Anyone is free to copy, modify, publish, use, compile, sell, or
#distribute this software, either in source code form or as a compiled
#binary, for any purpose, commercial or non-commercial, and by any
#means.

#---Description---
# miniPyMusic - a minimalist music server
# Run me in the directory of your MP3/OGG files
# and point your browser at me.
# Great for a simple LAN music server.
'''
Explanations

The ThreadingTCPServer listens on the given port (8099). Each time a client connects, it spawns a new thread and instanciates a miniMusicServer object which will handle the HTTP request (do_GET()). Therefore each client has its miniMusicServer objet working for him in a separate thread.

buildm3u() simply walks the subdirectories, collecting all .mp3/.ogg files and builds a .m3u file.
m3u files are simple text files containing the URLs of each music file (http://...). Most browsers are configured to open m3u files in media players.
We add EXTINF informations so that the names show up more nicely in audio players. 
We use some quote/replace/encode so that special characters in filenames are not mangled by browsers or mediaplayers.

if self.path == u"/" : The m3u playlist will be served as the default page of our server, otherwise the else will serve the mp3/ogg file itself (with the correct MIME Type: "audio/mpeg" for .mp3 filers, "audio/ogg" for .ogg files.)
If the file does not exist, we let the base class SimpleHTTPServer display the 404 error page.

replace(u"..",u".") is a simple trick to prevent the webserver from serving files outside your music folder.

This server is by no mean secure. Do not run it over the internet or over hostile networks. You are warned.
'''

#---Code---
import os,os.path,BaseHTTPServer,SimpleHTTPServer,SocketServer,socket,mimetypes,urllib

PORT = 8099
HOSTNAME = socket.gethostbyaddr(socket.gethostname())[0]

MIME_TYPES = mimetypes.types_map
MIME_TYPES[".ogg"] = u"audio/ogg"

def buildm3u(directory):
    # Get all .mp3/.ogg files from subdirectories, and built a playlist (.m3u)
    files = [u"#EXTM3U"]
    for dirpath, dirnames, filenames in os.walk(directory):
        for filename in filenames:
            if os.path.splitext(filename)[1].lower() in (u'.mp3',u'.ogg'):
                filepath = os.path.normpath(os.path.join(dirpath,filename))
                files.append(u"#EXTINF:-1,%s" % filename) 
                # urllib.quote does not seem to handle all Unicode strings properly
                data = urllib.quote(filepath.replace(os.path.sep,"/").encode("utf-8","replace"))
                files.append(u"http://%s:%s/%s" % (HOSTNAME,PORT,data))
    return files

class miniMusicServer(SimpleHTTPServer.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == u"/":  # We will return the .m3u file.
            self.send_response(200)
            self.send_header(u'Content-Type',u'audio/x-mpegurl; charset=utf-8')
            self.send_header(u'Content-Disposition',u'attachment; filename="playlist.m3u"')
            self.end_headers()
            self.wfile.write(u"\n".join(buildm3u(u".")).encode("utf-8","replace"))
        else: # Return the music file with proper MIME type.
            localpath = urllib.unquote(self.path).decode("utf-8").replace(u"/",os.path.sep)[1:].replace(u"..",u".")
            if os.path.isfile(localpath):
                ext = os.path.splitext(localpath)[1].lower()
                mimetype = u"application/octet-stream"
                if ext in MIME_TYPES: mimetype=MIME_TYPES[ext]  # Get the correct MIME type for this extension.
                self.send_response(200)
                self.send_header(u'Content-Type',mimetype)
                self.send_header(u'Content-Length',unicode(os.path.getsize(localpath)))
                self.end_headers()
                self.wfile.write(open(localpath,"rb").read())
            else: # File not found ? Will simply return a 404.
                SimpleHTTPServer.SimpleHTTPRequestHandler.do_GET(self)
            
httpd = SocketServer.ThreadingTCPServer(('', PORT), miniMusicServer)
print u"Music server ready at http://%s:%s" % (HOSTNAME,PORT)
httpd.serve_forever()
