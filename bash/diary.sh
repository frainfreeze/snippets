#!/bin/bash
#---License---
#This is free and unencumbered software released into the public domain.

#Anyone is free to copy, modify, publish, use, compile, sell, or
#distribute this software, either in source code form or as a compiled
#binary, for any purpose, commercial or non-commercial, and by any
#means.

#---Description---
# CLI diary using vim or nano in combination with sponge
diary() {
    local fpath=$HOME/diary
       
    if [ "$1" == "vim" ]; then
        touch tmp.diary    
        export EDITOR="vim"
        base64 -d "$fpath" | vipe | base64 | sponge tmp.diary
        mv tmp.diary "$fpath"
    elif [ "$1" == "nano" ]; then
        touch tmp.diary    
        export EDITOR="nano"
        base64 -d "$fpath" | vipe | base64 | sponge tmp.diary
        mv tmp.diary "$fpath"
    elif [ "$1" == "date" ]; then
        echo -e "$(base64 -d "$fpath") \n $(date +"%d-%m-%Y %T")" | base64 | sponge "$fpath"
    elif [ "$1" == "" ]; then
        base64 -d "$fpath" | less
    else
        echo -e "$(base64 -d "$fpath") \n $*" | base64 | sponge "$fpath"
    fi
}
