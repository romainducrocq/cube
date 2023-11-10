#!/bin/bash

if [ ! -d "$HOME/.python/" ]; then
    mkdir ~/.python/
fi

find ~/.python/ -maxdepth 1 -name "pycc" -type l -delete
ln -s $(pwd) ~/.python/

sudo find /usr/local/bin/ -maxdepth 1 -name "pycc" -type l -delete
sudo ln -s $(pwd)/driver.sh /usr/local/bin/pycc

exit 0
