#!/bin/bash
#---License---
#This is free and unencumbered software released into the public domain.

#Anyone is free to copy, modify, publish, use, compile, sell, or
#distribute this software, either in source code form or as a compiled
#binary, for any purpose, commercial or non-commercial, and by any
#means.

#---Description---
# Populates markdown file with links to all html files in PWD
OUTPUT="links.md" 
echo "# html pages" > $OUTPUT

for i in `find . -name '*.html'`; do
  fname=`basename $i`
  echo "- [$fname]($i)" >> $OUTPUT
done