#!/bin/bash

if [ ! -d "$HOME/.python/" ]; then
    mkdir ~/.python/
fi

if [ ! -L "$HOME/.python/pycc" ] && [ ! -e "$HOME/.python/pycc" ]; then
    ln -s $(pwd) ~/.python/
fi

sudo find /usr/local/bin/ -maxdepth 1 -iname "pycc" -type l -delete
sudo ln -s $(pwd)/driver.sh /usr/local/bin/pycc
